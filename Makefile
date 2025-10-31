NAME := tekton-pipeline
CHART_DIR := charts/${NAME}
CHART_VERSION ?= latest
RELEASE_VERSION := $(shell jx release version -previous-version=from-file:charts/tekton-pipeline/Chart.yaml)

CHART_REPO := gs://jenkinsxio/charts

fetch:
	rm -f ${CHART_DIR}/templates/*.yaml
	rm -f ${CHART_DIR}/crds/*.yaml
	mkdir -p ${CHART_DIR}/templates
	mkdir -p $(CHART_DIR)/crds
ifeq ($(CHART_VERSION),latest)
	curl -sS https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml > ${CHART_DIR}/templates/resource.yaml
else
	curl -sS https://storage.googleapis.com/tekton-releases/pipeline/previous/v${CHART_VERSION}/release.yaml > ${CHART_DIR}/templates/resource.yaml
endif
	jx gitops split -d ${CHART_DIR}/templates
	jx gitops rename -d ${CHART_DIR}/templates
    # Remove tekton-pipelines-resolvers-ns
	rm -r $(CHART_DIR)/templates/tekton-pipelines-resolvers-ns.yaml
	# Amend subjects.namespace with release.namespace
	find $(CHART_DIR)/templates -type f \( -name "*-crb.yaml" -o -name "*-rb.yaml" \) -exec yq -i '(.subjects[] | select(has("namespace"))).namespace = "{{ .Release.Namespace }}"' "{}" \;
	# Remove namespace from metadata to force with helm install
	find $(CHART_DIR)/templates -type f -name "*.yaml" -exec yq -i eval 'del(.metadata.namespace)' "{}" \;
	# Move content of containers.resources from tekton-pipelines-remote-resolvers-deploy.yaml to remoteresolver.resources
	yq -i '.remoteresolver.resources = load("$(CHART_DIR)/templates/tekton-pipelines-remote-resolvers-deploy.yaml").spec.template.spec.containers[].resources' $(CHART_DIR)/values.yaml
	yq e -i 'del(.spec.template.spec.containers[].resources)' $(CHART_DIR)/templates/tekton-pipelines-remote-resolvers-deploy.yaml
	# Move content of data: from feature-slags-cm.yaml to featureFlags: in values.yaml
	yq -i '.featureFlags = load("$(CHART_DIR)/templates/feature-flags-cm.yaml").data' $(CHART_DIR)/values.yaml
	yq -i '.data = null' $(CHART_DIR)/templates/feature-flags-cm.yaml
	# Move content of data: from config-defaults-cm.yaml to configDefaults: in values.yaml
	yq -i '.configDefaults = load("$(CHART_DIR)/templates/config-defaults-cm.yaml").data' $(CHART_DIR)/values.yaml
	yq -i '.data = null' $(CHART_DIR)/templates/config-defaults-cm.yaml
	# Move content of data: from git-resolver-config-cm.yaml to gitResolverConfig: in values.yaml
	yq -i '.gitResolverConfig = load("$(CHART_DIR)/templates/git-resolver-config-cm.yaml").data' $(CHART_DIR)/values.yaml
	yq -i '.data = null' $(CHART_DIR)/templates/git-resolver-config-cm.yaml
	# Remove image: from tekton-pipelines-controller-deploy
	yq -i 'del(.spec.template.spec.containers[].image)' $(CHART_DIR)/templates/tekton-pipelines-controller-deploy.yaml
	# Make node affinity configurable
	yq -i '.webhook.affinity.nodeAffinity = load("$(CHART_DIR)/templates/tekton-pipelines-webhook-deploy.yaml").spec.template.spec.affinity.nodeAffinity' $(CHART_DIR)/values.yaml
	yq -i 'del(.spec.template.spec.affinity.nodeAffinity)' $(CHART_DIR)/templates/tekton-pipelines-webhook-deploy.yaml
	yq -i '.controller.affinity.nodeAffinity = load("$(CHART_DIR)/templates/tekton-pipelines-controller-deploy.yaml").spec.template.spec.affinity.nodeAffinity' $(CHART_DIR)/values.yaml
	yq -i 'del(.spec.template.spec.affinity.nodeAffinity)' $(CHART_DIR)/templates/tekton-pipelines-controller-deploy.yaml
	# kustomize the resources to include some helm template blocs
	kustomize build ${CHART_DIR} | sed '/helmTemplateRemoveMe/d' > ${CHART_DIR}/templates/resource.yaml
	jx gitops split -d ${CHART_DIR}/templates
	jx gitops rename -d ${CHART_DIR}/templates
	# Move CRDs to crds/ directory
	find $(CHART_DIR)/templates -type f -name "*-crd.yaml" -exec mv {} $(CHART_DIR)/crds/ \;
	# Wrap ClusterRoles and ClusterRoleBindings with createClusterRoles conditional
	find $(CHART_DIR)/templates -type f \( -name "*-clusterrole.yaml" -o -name "*-crb.yaml" \) -exec sh -c 'echo "{{- if .Values.createClusterRoles }}" | cat - "$$1" > temp && mv temp "$$1"' _ {} \;
	find $(CHART_DIR)/templates -type f \( -name "*-clusterrole.yaml" -o -name "*-crb.yaml" \) -exec sh -c 'echo "{{- end }}" >> "$$1"' _ {} \;
	# Wrap aggregate ClusterRoles with additional createAggregateRoles conditional
	find $(CHART_DIR)/templates -type f -name "*aggregate*clusterrole.yaml" -exec sh -c 'sed -i.bak "1s/{{- if .Values.createClusterRoles }}/{{- if and .Values.createAggregateRoles .Values.createClusterRoles }}/" "$$1" && rm "$$1.bak"' _ {} \;
	cp src/templates/* ${CHART_DIR}/templates
ifneq ($(CHART_VERSION),latest)
	sed -i.bak "s/^appVersion:.*/appVersion: ${CHART_VERSION}/" ${CHART_DIR}/Chart.yaml
endif

version:
	# Increment Chart.yaml version for minor changes to helm chart
	yq eval '.version = "$(RELEASE_VERSION)"' -i charts/tekton-pipeline/Chart.yaml
build:
	rm -rf Chart.lock
	#helm dependency build
	helm lint ${NAME}

install: clean build
	helm install . --name ${NAME}

upgrade: clean build
	helm upgrade ${NAME} .

delete:
	helm delete --purge ${NAME}

clean:

release: clean
	helm dependency build
	helm lint
	helm package .
	helm repo add jx-labs $(CHART_REPO)
	helm gcs push ${NAME}*.tgz jx-labs --public
	rm -rf ${NAME}*.tgz%

test:
	cd tests && go test -v

test-regen:
	cd tests && export HELM_UNIT_REGENERATE_EXPECTED=true && go test -v


verify:
	jx kube test run