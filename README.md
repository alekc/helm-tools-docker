# helm-tools-docker

A small image bundling the tools a Helm chart signing/CI pipeline needs, so
a job doesn't have to reinstall them from scratch on every run.

## What's inside

| Tool     | Source                                                | Why                                          |
| -------- | ------------------------------------------------------ | --------------------------------------------- |
| `helm`   | Alpine package (`apk add helm`)                        | package/sign/verify charts                    |
| `gnupg`  | Alpine package (`apk add gnupg`)                        | import a signing key, export a keyring        |
| `expect` | Alpine package (`apk add expect`)                        | drive `helm package --sign`'s interactive passphrase prompt non-interactively |
| `vals`   | pinned GitHub release, checksum-verified ([helmfile/vals](https://github.com/helmfile/vals)) | fetch secrets (Infisical and others) via `ref+<backend>://` URIs |

Base: `alpine:3.20`. Multi-arch: `linux/amd64`, `linux/arm64`.

## Usage

```dockerfile
FROM ghcr.io/alekc/helm-tools-docker:v1.0.0
```

Or directly in a CI job:

```yaml
image: ghcr.io/alekc/helm-tools-docker:v1.0.0
script:
  - helm version
  - vals env -f secrets.yaml
```

Sanity check what a given tag actually contains:

```sh
docker run --rm ghcr.io/alekc/helm-tools-docker:v1.0.0 \
  sh -c 'helm version; gpg --version; expect -v; vals version'
```

## Staying up to date

This image updates itself with no human step:

- Dependabot tracks the `alpine:X.Y` base image in the `Dockerfile`. Since
  `helm`, `gnupg`, and `expect` are installed via `apk add` (not
  version-pinned), a base image bump carries their versions along with it.
- `vals` isn't packaged in stable Alpine, so it's pinned separately by a
  scheduled workflow that checks
  [helmfile/vals releases](https://github.com/helmfile/vals/releases) and
  opens a PR bumping the version and its checksum when a new one ships.
- Every PR from either mechanism auto-merges once a build check confirms
  the Dockerfile still builds, patch, minor, and major bumps alike, no
  review gate.
- [release-please](https://github.com/googleapis/release-please) cuts a
  new version and tag on every change to `main`, including its own Release
  PR, which also auto-merges. A merged dependency bump reaches a published,
  live image with nobody in the loop at any point.

**Practical consequence**: `:latest` (and the newest `:vX.Y.Z` tag) can
change out from under you at any time, including a major Alpine bump.
Pin an exact `:vX.Y.Z` tag anywhere reproducibility matters, and don't
assume today's `:latest` behaves the same next week.
