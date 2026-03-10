# helm-edgen

Helm chart and CUDA image pipeline for Edgen in the `tensorlabresearch` organization.

## What this repo publishes

- OCI chart (primary): `oci://ghcr.io/tensorlabresearch/charts/edgen`
- GitHub Pages chart repo (mirror): `https://tensorlabresearch.github.io/helm-edgen`
- Container image: `ghcr.io/tensorlabresearch/edgen`

## Install

### From OCI (recommended)

```bash
helm install edgen oci://ghcr.io/tensorlabresearch/charts/edgen \
  --version 0.1.0
```

### From GitHub Pages index

```bash
helm repo add tensorlab-edgen https://tensorlabresearch.github.io/helm-edgen
helm repo update
helm install edgen tensorlab-edgen/edgen --version 0.1.0
```

## Release model

- Push a semver Git tag like `v0.1.0` to build/publish the CUDA image to GHCR.
- Merge chart changes to `main` with bumped `charts/edgen/Chart.yaml` version.
- `chart-release.yml` will lint/template, publish index/releases to `gh-pages`, and push changed chart packages to GHCR OCI.

## Notes

- Default chart values assume CUDA and request `nvidia.com/gpu: 1`.
- Chart renders `edgen.conf.yaml` from values and mounts it in the container.
- Model files can be preloaded via init container and/or auto-downloaded by Edgen at runtime.
