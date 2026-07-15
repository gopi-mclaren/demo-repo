# demo-repo

A working demonstration of the ProviderPlus (`mmes-cms-prv`) branching, versioning, and
release strategy, implemented against three illustrative microservices.

## Services

Three independent .NET 10 minimal APIs live under `components/`, each a standalone,
buildable project with its own `Dockerfile`:

| Service | Path | Sample endpoint |
|---|---|---|
| `enrollment` | `components/enrollment/` | `GET /enrollments/{id}` |
| `filemanagement` | `components/filemanagement/` | `GET /files/{id}` |
| `reporting` | `components/reporting/` | `GET /reports/{id}` |

Each exposes `GET /` and `GET /health` for a quick liveness check.

## How the pipeline works

**`dev.yml`** — fires automatically on every push to `main`. A change-detection step
compares the diff against each service's folder and only builds the service(s) actually
touched; each is pushed to GitHub Container Registry as `<service>:dev-<commit-sha>` and
"deployed" to dev (simulated — no real infrastructure is targeted by this demo). The
service's entry in `manifests/dev.yaml` is updated as the final step.

**`release-cut.yml`** — triggered manually with a single version number (for example,
`1.0.0`). It cuts one `release/x.y.z` branch across the whole repository, then builds
**every** service under that same version number, regardless of whether each one
individually changed — matching the synced-versioning strategy this repository
demonstrates. Each image is pushed and (as a simulated step) signed, then sanity-checked
by a simulated deploy to dev before `manifests/dev.yaml` is updated for all three
services.

**`qa.yml`** — triggered manually, selecting one service and the version to promote.
It never rebuilds: it pulls the existing release image, retags it as
`qa-<service>-<version>`, pushes that tag, simulates a deploy to qa, and updates
`manifests/qa.yaml` for that one service only. The job runs under the `qa` GitHub
Environment, so environment protection rules (for example, required reviewers) can be
attached directly in repository settings without changing the workflow itself.

All three workflows share `_reusable-build.yml` for the actual `docker build` step —
it is the only workflow in this repository that ever builds an image; every promotion
after that is a relabeling of an image `_reusable-build.yml` already produced.

## Manifests

`manifests/dev.yaml` and `manifests/qa.yaml` each record, per service, the version and
digest currently deployed to that environment. They are written only by the workflows
above, as the final step of every build or promotion — never edited by hand.

## Infrastructure (illustrative only)

`iac/terraform/` shows the intended shape of the supporting AWS infrastructure — one
container registry per service, a shared network, and per-environment service
definitions. These files are illustrative: there is no backend configuration or real
account behind them, and they are not intended to be run with `terraform plan` or
`terraform apply` as they stand.

## Trying it out

1. Push a change to any file under `components/enrollment/`, `components/filemanagement/`,
   or `components/reporting/` on `main` — only the touched service will build and deploy
   to dev.
2. Run **Release Cut** from the Actions tab, supplying a version such as `1.0.0`.
3. Run **Promote to QA**, selecting a service and the version just cut.
