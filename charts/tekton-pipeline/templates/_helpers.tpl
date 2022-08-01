{{- define "default_registry" -}}
{{- if .Values.global.DefaultRegistry -}}
{{- printf "%s/" .Values.global.DefaultRegistry -}}
{{- end -}}
{{- end -}}

{{- define "controller_image" -}}
{{- printf "%s:%s" .Values.controller.deployment.images.controller.image .Values.controller.deployment.images.controller.tag -}}
{{- end -}}

{{- define "webhook_image" -}}
{{- printf "%s:%s" .Values.webhook.deployment.images .Values.webhook.deployment.tag -}}
{{- end -}}
