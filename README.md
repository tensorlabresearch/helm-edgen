# helm-edgen

Helm chart wrapper for the [Edgen project](https://github.com/edgenai/edgen), maintained in the `tensorlabresearch` organization.

## What this repo publishes

- OCI chart (primary): `oci://ghcr.io/tensorlabresearch/charts/edgen`
- GitHub Pages chart repo (mirror): `https://tensorlabresearch.github.io/helm-edgen`
- Container image: `ghcr.io/tensorlabresearch/edgen`

## Install

### From OCI (recommended)

```bash
helm install edgen oci://ghcr.io/tensorlabresearch/charts/edgen \
  --version 0.1.3
```

### From GitHub Pages index

```bash
helm repo add tensorlab-edgen https://tensorlabresearch.github.io/helm-edgen
helm repo update
helm install edgen tensorlab-edgen/edgen --version 0.1.3
```

## Quickstart Values

Create a values override to preload extra models into the chart-managed models PVC:

```yaml
gpu:
  enabled: true
  count: 1
  resourceKey: nvidia.com/gpu

modelPreload:
  enabled: true
  continueOnError: false
  items:
    - id: custom-chat-gguf
      url: https://example.com/models/chat.gguf
      filename: chat.gguf
      targetSubdir: edgen/chat/completions
      sha256: ""
```

Install with:

```bash
helm install edgen oci://ghcr.io/tensorlabresearch/charts/edgen \
  --version 0.1.3 \
  -f values-preload.yaml
```

## Argo CD Examples

- Pages chart repo app: `examples/argocd/pages-application.yaml`
- OCI chart repo app:
  - repository secret: `examples/argocd/oci-repository-secret.yaml`
  - application: `examples/argocd/oci-application.yaml`

## Release model

- Push a semver Git tag like `v0.1.0` to build/publish the image to GHCR.
- Merge chart changes to `main` with bumped `charts/edgen/Chart.yaml` version.
- `chart-release.yml` will lint/template, publish index/releases to `gh-pages`, and push changed chart packages to GHCR OCI.

## Notes

- Default chart values assume CUDA and request `nvidia.com/gpu: 1`.
- Chart renders `edgen.conf.yaml` from values and mounts it in the container.
- Model files can be preloaded via init container and/or auto-downloaded by Edgen at runtime.
- If OCI chart pulls return `403`, set GHCR package visibility to public for `charts/edgen` in the `tensorlabresearch` org packages settings.
