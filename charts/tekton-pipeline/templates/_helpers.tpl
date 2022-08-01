{{- define "default_registry" -}}
{{- if .Values.global.DefaultRegistry -}}
{{- printf "%s/" .Values.global.DefaultRegistry -}}
{{- end -}}
{{- end -}}