{{- define "cortex.elasticUserSecretName" -}}
{{- if .Values.elasticsearch.eck.enabled -}}
{{- if .Values.elasticsearch.eck.name -}}
{{ printf "%s-%s" .Values.elasticsearch.eck.name "es-elastic-user" | quote }}
{{- else -}}
{{ fail "User secret: when ECK is enabled you must supply a value for the elasticsearch.eck.name." }}
{{- end -}}
{{- else if .Values.elasticsearch.external.enabled -}}
{{ printf "%s-%s" (include "cortex.fullname" .) "ext-es-user-secret" | quote }}
{{- else -}}
{{ fail "User secret: Some kind of Elasticsearch must be enabled." }}
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
{{ printf "%s-%s" (.Values.elasticsearch.eck.name) "es-http-ca-internal" | quote }}
{{- else -}}
{{ fail "CA cert secret: when ECK is enabled you must supply a value for elasticsearch.eck.name." }}
{{- end -}}
{{- else if .Values.elasticsearch.external.enabled -}}
{{ printf "%s-%s" (include "cortex.fullname" .) "external-es-http-ca" | quote }}
{{- else -}}
{{ fail "CA cert secret: Some kind of Elasticsearch must be enabled." }}
{{- end -}}
{{- end }}