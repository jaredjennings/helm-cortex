{{- define "cortex.esCACertDir" -}}
/tmp/es-http-ca
{{- end }}
{{- define "cortex.esCACert" -}}
{{ printf "%s/ca.crt" (include "cortex.esCACertDir" .) }}
{{- end }}
{{- define "cortex.esCACertVolumes" -}}
{{- if .Values.elasticsearch.tls }}
- name: es-http-ca
  secret:
    secretName: {{ default .Values.elasticsearch.caCertSecret (include "cortex.elasticCACertSecretName" .) }}
    items:
      - key: {{ .Values.elasticsearch.caCertSecretMappingKey | quote }}
        path: "ca.crt"
{{- end }}
{{- end }}
{{- define "cortex.esCACertVolumeMounts" -}}
- name: es-http-ca
  mountPath: {{ include "cortex.esCACertDir" . | quote }}
{{- end }}


{{/*
Container-local path for JKS-format Elasticsearch trust store.
This is JKS-format because elastic4play requires a keyStore to be
provided in order for the trustStore setting to take effect, and a
trust store can serve as an empty keystore too. This will need to be
changed if Elasticsearch client certs are ever supported.
*/}}
{{- define "cortex.esTrustStoreDir" -}}
/etc/cortex/es-trust
{{- end }}
{{- define "cortex.esTrustStore" -}}
{{ printf "%s/store" (include "cortex.esTrustStoreDir" .) }}
{{- end }}
{{- define "cortex.esTrustStoreVolumeMount" -}}
- name: es-trust-store
  mountPath: {{ include "cortex.esTrustStoreDir" . }}
{{- end }}



{{- define "cortex.wsCACertVolumes" -}}
{{- range .Values.trustRootCertsInSecrets }}
{{- $name := printf "tls-ca-s-%s" . }}
- name: {{ $name | quote }}
  secret:
    secretName: {{ . | quote }}
    items:
      - key: "ca.crt"
        path: "ca.crt"
{{- end }}
{{- range .Values.trustRootCerts }}
{{- $shortsum := . | sha256sum | substr 0 10 }}
{{- $name := printf "tls-ca-%s" $shortsum }}
- name: {{ $name | quote }}
  secret:
    secretName: {{ printf "%s-ca-%s" (include "cortex.fullname" $) $shortsum | quote }}
    items:
      - key: "ca.crt"
        path: "ca.crt"
{{- end }}
{{- end }}


{{- define "cortex.wsCACertVolumeMounts" -}}
{{- range .Values.trustRootCertsInSecrets }}
{{ $name := printf "tls-ca-s-%s" . }}
- name: {{ $name | quote }}
  mountPath: {{ printf "/etc/cortex/tls/%s" $name | quote }}
{{- end }}
{{- range .Values.trustRootCerts }}
{{- $shortsum := . | sha256sum | substr 0 10 }}
{{- $name := printf "tls-ca-%s" $shortsum }}
- name: {{ $name | quote }}
  mountPath: {{ printf "/etc/cortex/tls/%s" $name | quote }}
{{- end }}
{{- end }}


{{- define "cortex.wsCACertFilenamesPlayWSStoreLines" }}
{{- range .Values.trustRootCertsInSecrets }}
{{ $name := printf "tls-ca-s-%s" . }}
{{ printf "{ path: \"/etc/cortex/tls/%s/ca.crt\", type: \"PEM\" }" $name }}
{{- end }}
{{- range .Values.trustRootCerts }}
{{- $shortsum := . | sha256sum | substr 0 10 }}
{{- $name := printf "tls-ca-%s" $shortsum }}
{{ printf "{ path: \"/etc/cortex/tls/%s/ca.crt\", type: \"PEM\" }" $name }}
{{- end }}
{{- end }}


{{- define "cortex.wsCACertPlayWSConfig" -}}
{{- if (or .Values.trustRootCerts .Values.trustRootCertsInSecrets) }}
play.ws.ssl.trustManager.stores = [
{{- include "cortex.wsCACertFilenamesPlayWSStoreLines" . | nindent 2 }}
]
{{- end }}
{{- end }}
