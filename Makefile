CHART_REPO := gs://jenkinsxio/charts
NAME := jx-git-operator

fetch:
	rm -f tekton/templates/*.yaml
	curl https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml > tekton/templates/resource.yaml
	jx gitops split -d tekton/templates
	jx gitops rename -d tekton/templates
	cp src/templates/* tekton/templates

build: clean
	rm -rf Chart.lock
	helm dependency build
	helm lint

install: clean build
	helm install . --name ${NAME}

upgrade: clean build
	helm upgrade ${NAME} .

delete:
	helm delete --purge ${NAME}

clean:
	rm -rf charts
	rm -rf ${NAME}*.tgz

release: clean
	sed -i -e "s/version:.*/version: $(VERSION)/" Chart.yaml

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

