{{/* Elasticsearch cluster object names, if we control the elasticsearch */}}

{{- define "cortex.elasticUserSecretName" -}}
{{- if .Values.elasticsearch.eck.enabled -}}
{{ include "cortex.fullname" . }}-es-elastic-user
{{- else if .Values.elasticsearch.external.enabled -}}
{{ include "cortex.fullname" . }}-external-es-user
{{- else -}}
{{ fail "User secret: Some kind of Elasticsearch must be enabled." }}
{{- end -}}
{{- end }}

{{- define "cortex.elasticURL" -}}
{{- if .Values.elasticsearch.eck.enabled }}
https://{{ include "cortex.fullname" . }}-es-http:9200
{{- else -}}{{/* no good guess */}}
{{- end -}}
{{- end }}

{{- define "cortex.elasticCACertSecretName" -}}
{{- if .Values.elasticsearch.eck.enabled -}}
{{ printf "%s-%s" (include "cortex.fullname" .) "es-http-ca-internal" | quote }}
{{- else if .Values.elasticsearch.external.enabled -}}
{{ printf "%s-%s" (include "cortex.fullname" .) "external-es-http-ca" | quote }}
{{- else -}}
{{ fail "CA cert secret: Some kind of Elasticsearch must be enabled." }}
{{- end -}}
{{- end }}