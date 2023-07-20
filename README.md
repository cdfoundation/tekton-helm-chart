# tekton-helm-chart

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

CDF official helm chart for [Tekton Pipelines](https://github.com/tektoncd/pipeline).

## Usage

## Prerequisites

The following tools need to be installed locally:

- [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/)
- [yq](https://github.com/mikefarah/yq/#install)
- [jx-release-version](https://github.com/jenkins-x-plugins/jx-release-version)

### Jenkins X

If you are creating a template to be used in Jenkins X version, you can run the following command:

```bash
make fetch
```

This will fetch the latest version.
To fetch a specific version (say 0.32.0), use CHART_VERSION

```bash
make CHART_VERSION=0.32.0 fetch
```

```bash
make release
```
This will check the current version in Chart.yaml and increment the minor version by 0.0.1.
Please use this command when making changes to the charts.

The `app_version` will be set to the `CHART_VERSION` automatically by the makefile if a `CHART_VERSION` is specified.
For latest set `app_version` to the latest tekton version from the [tekton release page](https://github.com/tektoncd/pipeline/releases) and not `latest`.

### Other use cases

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```bash
helm repo add cdf https://cdfoundation.github.io/tekton-helm-chart/
```

you can then do

```bash
helm search repo tekton
```

The chart installs resources into the `tekton-pipelines` namespace

## Configuration

See chart [readme](charts/tekton-pipeline/README.md) and [values.yaml](charts/tekton-pipeline/values.yaml) for install and config options.

## Repository

You can view the YAML at [index.yaml](https://cdfoundation.github.io/tekton-helm-chart/index.yaml).
