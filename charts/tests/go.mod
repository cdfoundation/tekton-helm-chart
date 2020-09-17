module github.com/jenkins-x-charts/tekton

go 1.13

require (
	github.com/gophercloud/gophercloud v0.1.0 // indirect
	github.com/jenkins-x/helm-unit-tester v0.0.4
	github.com/jenkins-x/jx v1.3.1119
	github.com/jenkins-x/jx/v2 v2.1.64
	github.com/spf13/cobra v0.0.5
	github.com/stretchr/testify v1.6.0
	k8s.io/client-go v11.0.1-0.20190805182717-6502b5e7b1b5+incompatible
	sigs.k8s.io/yaml v1.1.0
)

replace (
	github.com/spf13/cobra => github.com/spf13/cobra v0.0.5
	k8s.io/api => k8s.io/api v0.0.0-20190528110122-9ad12a4af326
	k8s.io/apimachinery => k8s.io/apimachinery v0.0.0-20190221084156-01f179d85dbc
	k8s.io/client-go => k8s.io/client-go v0.0.0-20190528110200-4f3abb12cae2
)
