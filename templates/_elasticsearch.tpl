{{- define "cortex.elasticUserSecretName" -}}
{{- if .Values.elasticsearch.eck.enabled -}}
{{- if .Values.elasticsearch.eck.name -}}
{{ printf "%s-%s" .Values.elasticsearch.eck.name "es-elastic-user" | quote }}
{{- else -}}
{{ fail "While trying to construct user secret name: when elasticsearch.eck.enabled is true, you must provide elasticsearch.eck.name." }}
{{- end -}}
{{- else -}}{{- /* Well this is stilted isn't it */ -}}
{{- if .Values.elasticsearch.userSecret -}}
{{ .Values.elasticsearch.userSecret }}
{{- else -}}
{{ fail "When elasticsearch.eck.enabled is false, you must provide elasticsearch.userSecret." }}
{{- end -}}
{{- end -}}
{{- end }}

{{- define "cortex.elasticURL" -}}
{{- if .Values.elasticsearch.eck.enabled -}}
{{ printf "https://%s-es-http:9200" .Values.elasticsearch.eck.name | quote }}
{{- else -}}{{- /* guess */ -}}
"https://elasticsearch:9200"
{{- end -}}
{{- end }}

{{- define "cortex.elasticCACertSecretName" -}}
{{- if .Values.elasticsearch.eck.enabled -}}
{{- if .Values.elasticsearch.eck.name -}}
{{ printf "%s-%s" (.Values.elasticsearch.eck.name) "es-http-certs-public" | quote }}
{{- else -}}
{{ fail "CA cert secret: when ECK is enabled you must supply a value for elasticsearch.eck.name." }}
{{- end -}}
{{- else if .Values.elasticsearch.external.enabled -}}
{{ printf "%s-%s" (include "cortex.fullname" .) "external-es-http-ca" | quote }}
{{- else -}}
{{ fail "CA cert secret: Some kind of Elasticsearch must be enabled." }}
{{- end -}}
{{- end }}