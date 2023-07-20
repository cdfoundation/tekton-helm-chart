NAME := tekton-pipeline
CHART_DIR := charts/${NAME}
CHART_VERSION ?= latest
RELEASE_VERSION := $(shell jx-release-version -previous-version=from-file:charts/tekton-pipeline/Chart.yaml)

CHART_REPO := gs://jenkinsxio/charts

fetch:
	rm -f ${CHART_DIR}/templates/*.yaml
	mkdir -p ${CHART_DIR}/templates
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
	# Move content of data: from feature-slags-cm.yaml to featureFlags: in values.yaml
	yq -i '.featureFlags = load("$(CHART_DIR)/templates/feature-flags-cm.yaml").data' $(CHART_DIR)/values.yaml
	yq -i '.data = null' $(CHART_DIR)/templates/feature-flags-cm.yaml
	# Move content of data: from config-defaults-cm.yaml to configDefaults: in values.yaml
	yq -i '.configDefaults = load("$(CHART_DIR)/templates/config-defaults-cm.yaml").data' $(CHART_DIR)/values.yaml
	yq -i '.data = null' $(CHART_DIR)/templates/config-defaults-cm.yaml
	# Move content of data: from git-resolver-config-cm.yaml to gitResolverConfig: in values.yaml
	yq -i '.gitResolverConfig = load("$(CHART_DIR)/templates/git-resolver-config-cm.yaml").data' $(CHART_DIR)/values.yaml
	yq -i '.data = null' $(CHART_DIR)/templates/git-resolver-config-cm.yaml
	# Retrieve the image value from the template
	yq -i '.controller.deployment.image = load("$(CHART_DIR)/templates/tekton-pipelines-controller-deploy.yaml").spec.template.spec.containers[].image' $(CHART_DIR)/values.yaml
	# Remove the image value, so that end users can customize the image
	yq -i '.spec.template.spec.containers[].image = null' $(CHART_DIR)/templates/tekton-pipelines-controller-deploy.yaml
	# Remove duplicated node affinity
	find $(CHART_DIR)/templates -type f -name "*deploy.yaml" -exec yq -i eval 'del(.spec.template.spec.affinity.nodeAffinity)' "{}" \;
	# kustomize the resources to include some helm template blocs
	kustomize build ${CHART_DIR} | sed '/helmTemplateRemoveMe/d' > ${CHART_DIR}/templates/resource.yaml
	jx gitops split -d ${CHART_DIR}/templates
	jx gitops rename -d ${CHART_DIR}/templates
	cp src/templates/* ${CHART_DIR}/templates
ifneq ($(CHART_VERSION),latest)
	sed -i.bak "s/^appVersion:.*/appVersion: ${CHART_VERSION}/" ${CHART_DIR}/Chart.yaml
endif

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
	# Increment Chart.yaml version for minor changes to helm chart
	yq eval '.version = "$(RELEASE_VERSION)"' -i charts/tekton-pipeline/Chart.yaml
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