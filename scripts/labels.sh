#!/usr/bin/env bash
# Syncs the repository labels with the set defined below:
#   1. creates or updates every label (name, color, description)
#   2. deletes any existing label that is not part of the set
#
# Requires the GitHub CLI (gh), authenticated: gh auth status
#
# Usage (run from the repository root):
#   ./scripts/labels.sh                    # sync the default repository
#   ./scripts/labels.sh owner/repo         # sync another repository
#   ./scripts/labels.sh --dry-run          # show what would happen, change nothing
#   ./scripts/labels.sh --yes              # delete extra labels without asking
#
# Labels named "autorelease: ..." belong to Release Please and are never deleted.
# GitHub limits label descriptions to 100 characters.
set -euo pipefail

REPO="sca-templates/node-server-core"
DRY_RUN=false
ASSUME_YES=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --yes|-y) ASSUME_YES=true ;;
    */*) REPO="$arg" ;;
    *) echo "Unknown argument: $arg" >&2; exit 1 ;;
  esac
done

# Format: name|color (hex, no #)|description
#
# Area label colors identify the layer of the plan:
#   bfd4f2 foundations     f9d0c4 observability   fef2c0 identity and HTTP layer
#   d4c5f9 integrations    ffcc99 cloud providers bfdadc framework adapters
#   ededed quality
read -r -d '' LABELS <<'EOF' || true
accessibility|f29513|Barrier for people with disabilities, e.g. in docs, Swagger UI or readable error messages
bug|d73a4a|Something is broken: incorrect behavior, crash or regression in a module
documentation|0075ca|Improvements or additions to the README, module docs, API reference or examples
duplicate|cfd3d7|This issue or pull request already exists; link the original and close this one
enhancement|a2eeef|New feature or improvement to an existing module (non-breaking)
good first issue|7057ff|Well-scoped and self-contained; good for newcomers to the codebase
help wanted|008672|Extra attention or an additional reviewer or contributor is needed
invalid|e4e669|Doesn't seem right: not reproducible, out of context or based on a wrong assumption
question|d876e3|Further information is needed, or a usage question about the library
wontfix|ffffff|Acknowledged but intentionally not going to be worked on; reason noted in the thread
breaking change|d93f0b|Incompatible change to the public API; requires a major version bump (feat!/fix!)
security|b60205|Vulnerability, secret exposure or hardening; handle privately if it is sensitive
dependencies|0366d6|Dependency or peer dependency updates, including supported version range changes
tooling|c2e0c6|Build (tsup), CI, Release Please, publishing and developer tooling changes
design|1d76db|Planning, API design or an ADR; produces a decision or spec, not code
needs decision|fbca04|Blocked until an open design decision is made; add the options in the thread
blocked|24292f|Cannot progress: waiting on another issue, PR, external service or person
errors|bfd4f2|Error model: AppError hierarchy, stable codes and RFC 9457 problem details
config|bfd4f2|Configuration loading and validation, environment variables and per-module options
context|bfd4f2|Request context via AsyncLocalStorage: user, tenant and trace data propagation
lifecycle|bfd4f2|Startup order, graceful shutdown on SIGTERM and Kubernetes health checks
logging|f9d0c4|Structured logging with Pino: log interface, redaction and trace correlation
audit|f9d0c4|Audit events: event schema, redaction and pluggable sinks (logs, Kafka, custom)
telemetry|f9d0c4|OpenTelemetry integration: traces, metrics, SDK bootstrap and instrumentation
auth|fef2c0|JWT/OIDC verification via JWKS, claim mapping, roles and permissions guards
validation|fef2c0|Validator factory and Zod schemas: request validation pipes and middlewares
swagger|fef2c0|OpenAPI/Swagger generation from Zod schemas for Express and NestJS
http-client|d4c5f9|Axios client: timeouts, retries, context and token propagation, error mapping
redis|d4c5f9|Redis connection factory, health checks and shared helpers
vault|d4c5f9|HashiCorp Vault: Kubernetes auth, secret fetching, caching and renewal
kafka|d4c5f9|Kafka producers and consumers: serialization, retries, dead letters, shutdown
bullmq|d4c5f9|BullMQ queues and workers: shared Redis connection, retries, context in jobs
cache|d4c5f9|Caching abstraction and providers (Redis): key conventions, TTLs and invalidation helpers
events|d4c5f9|Event publish/consume abstraction and providers (Kafka, cloud brokers), retries and dead letters
secrets|d4c5f9|Secrets abstraction and providers: Vault, AWS Secrets Manager, Azure Key Vault, GCP Secret Manager
aws|ffcc99|AWS support: credentials and region resolution, IAM-based auth and AWS service adapters
azure|ffcc99|Azure support: identity and tenant resolution, managed identity and Azure service adapters
gcp|ffcc99|GCP support: Application Default Credentials, service accounts and Google Cloud adapters
express|bfdadc|Express adapter: app bootstrap, middlewares and error handler
nestjs|bfdadc|NestJS adapter: module, guards, interceptors, filters and decorators
testing|ededed|Test strategy, Testcontainers integration tests and the /testing helpers entry
EOF

declare -A WANTED=()

# Validate the set before touching the repository.
while IFS='|' read -r name color desc; do
  [[ -z "$name" ]] && continue
  if (( ${#desc} > 100 )); then
    echo "Description too long (${#desc} > 100) for label: $name" >&2
    exit 1
  fi
  if [[ ! "$color" =~ ^[0-9a-fA-F]{6}$ ]]; then
    echo "Invalid color '$color' for label: $name" >&2
    exit 1
  fi
  WANTED["${name,,}"]=1
done <<< "$LABELS"

echo "Repository: $REPO"
$DRY_RUN && echo "(dry run: no changes will be made)"

# 1. Create or update.
echo
echo "Creating or updating labels..."
while IFS='|' read -r name color desc; do
  [[ -z "$name" ]] && continue
  if $DRY_RUN; then
    echo "  [dry-run] $name (#$color)"
  else
    gh label create "$name" --repo "$REPO" --color "$color" \
      --description "$desc" --force < /dev/null > /dev/null
    echo "  ok: $name (#$color)"
  fi
done <<< "$LABELS"

# 2. Delete labels that are not part of the set.
echo
mapfile -t EXISTING < <(gh label list --repo "$REPO" --limit 1000 --json name --jq '.[].name')

TO_DELETE=()
for name in "${EXISTING[@]}"; do
  [[ -z "$name" ]] && continue
  [[ "$name" == autorelease:* ]] && continue
  [[ -n "${WANTED[${name,,}]:-}" ]] && continue
  TO_DELETE+=("$name")
done

if (( ${#TO_DELETE[@]} == 0 )); then
  echo "No extra labels to delete."
  echo "Done."
  exit 0
fi

echo "Labels outside the set (${#TO_DELETE[@]}):"
printf '  - %s\n' "${TO_DELETE[@]}"

if $DRY_RUN; then
  echo "  [dry-run] nothing deleted"
  exit 0
fi

if ! $ASSUME_YES; then
  read -r -p "Delete these ${#TO_DELETE[@]} label(s)? They will be removed from issues and PRs. [y/N] " answer
  if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    echo "Skipped deletion."
    exit 0
  fi
fi

for name in "${TO_DELETE[@]}"; do
  gh label delete "$name" --repo "$REPO" --yes < /dev/null
  echo "  deleted: $name"
done

echo "Done."
