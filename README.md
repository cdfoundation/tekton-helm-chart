# tekton-helm-chart

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

CDF official helm chart for [Tekton Pipelines](https://github.com/tektoncd/pipeline).

## Usage

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

See chart [readme](charts/tekton-pipeline/README.md) for install and config options.

## Repository 

You can [browse the chart repository](https://cdfoundation.github.io/tekton-helm-chart/)

Or view the YAML at: [index.yaml](https://cdfoundation.github.io/tekton-helm-chart/index.yaml)





