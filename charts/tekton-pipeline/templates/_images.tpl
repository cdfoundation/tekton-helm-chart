{{/*
Return the proper image name
*/}}
{{- define "common.images.image" -}}
    {{- $registryName := .context.Values.imageConfig.imageRegistry -}}
    {{- $repositoryName := .context.Values.imageConfig.imageRepository -}}
    {{- $imageName := .imageRoot.name -}}
    {{- $imageTag := printf "v%s" .context.Chart.AppVersion -}}
    {{- $imageSha := .imageRoot.sha -}}
    {{- printf "%s/%s/%s:%s@%s" $registryName $repositoryName $imageName $imageTag $imageSha -}}
{{- end -}}

{{/*
Return the proper image name with no tag
*/}}
{{- define "common.images.notagimage" -}}
    {{- $registryName := .context.Values.imageConfig.imageRegistry -}}
    {{- $repositoryName := .imageRoot.repository -}}
    {{- $imageName := .imageRoot.name -}}
    {{- $imageSha := .imageRoot.sha -}}
    {{- printf "%s/%s/%s@%s" $registryName $repositoryName $imageName $imageSha -}}
{{- end -}}