{{/*
ServiceAccount name resolvers.

When .Values.serviceaccount.enabled is true, the chart creates the
ServiceAccounts and all workloads/RBAC use the chart-generated names below.

When it is false, the chart does NOT create the ServiceAccounts and the names
provided in .Values.serviceaccount.names.<component> are used instead. If an
override is left empty, the chart-generated name is used as a fallback to avoid
rendering an empty serviceAccountName.
*/}}

{{- define "tektonPipeline.controller.serviceAccountName" -}}
{{- if .Values.serviceaccount.enabled -}}
tekton-pipelines-controller
{{- else -}}
{{- default "tekton-pipelines-controller" .Values.serviceaccount.names.controller -}}
{{- end -}}
{{- end -}}

{{- define "tektonPipeline.webhook.serviceAccountName" -}}
{{- if .Values.serviceaccount.enabled -}}
tekton-pipelines-webhook
{{- else -}}
{{- default "tekton-pipelines-webhook" .Values.serviceaccount.names.webhook -}}
{{- end -}}
{{- end -}}

{{- define "tektonPipeline.eventsController.serviceAccountName" -}}
{{- if .Values.serviceaccount.enabled -}}
tekton-events-controller
{{- else -}}
{{- default "tekton-events-controller" .Values.serviceaccount.names.eventsController -}}
{{- end -}}
{{- end -}}

{{- define "tektonPipeline.resolvers.serviceAccountName" -}}
{{- if .Values.serviceaccount.enabled -}}
tekton-pipelines-resolvers
{{- else -}}
{{- default "tekton-pipelines-resolvers" .Values.serviceaccount.names.resolvers -}}
{{- end -}}
{{- end -}}
