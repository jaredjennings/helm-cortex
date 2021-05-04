{{- define "cortex.caCertVolumes" }}
{{- if .Values.elasticsearch.tls }}
- name: es-http-ca
  secret:
    secretName: {{ default .Values.elasticsearch.caCertSecret (include "cortex.elasticCACertSecretName" .) }}
    items:
      - key: {{ .Values.elasticsearch.caCertSecretMappingKey | quote }}
        path: es-http-ca.crt
{{- end }}
{{- range .Values.trustRootCertsInSecrets }}
- name: {{ printf "tls-ca-s-%s" . | quote }}
  secret:
    secretName: {{ . | quote }}
    items:
      - key: "ca.crt"
        path: "ca.crt"
{{- end }}
{{- range .Values.trustRootCerts }}
{{ $shortsum := . | sha256sum | substr 0 10 }}
- name: {{ printf "tls-ca-%s" $shortsum | quote}}
  secret:
    secretName: {{ printf "%s-ca-%s" (include "cortex.fullname" $) $shortsum | quote }}
    items:
      - key: "ca.crt"
        path: "ca.crt"
{{- end }}
{{- end }}

{{- define "cortex.caCertVolumeMounts" }}
{{- if .Values.elasticsearch.tls }}
- name: es-http-ca
  mountPath: /opt/cortex/es-http-ca
{{- end }}
{{- range .Values.trustRootCertsInSecrets }}
- name: {{ printf "tls-ca-s-%s" . | quote }}
  mountPath: {{ printf "/opt/cortex/tls-ca-s-%s" . | quote }}
{{- end }}
{{- range .Values.trustRootCerts }}
{{ $shortsum := . | sha256sum | substr 0 10 }}
- name: {{ printf "tls-ca-%s" $shortsum | quote}}
  mountPath: {{ printf "/opt/cortex/tls-ca-%s" $shortsum | quote }}
{{- end }}
{{- end }}

{{- define "cortex.caCertFilenamesCommaSeparated" }}
{{- $all := list "" }}
{{- if .Values.elasticsearch.tls }}
{{- $all = append $all "/opt/cortex/es-http-ca" }}
{{- end }}
{{- range .Values.trustRootCertsInSecrets }}
{{- $all = append $all (printf "/opt/cortex/tls-ca-s-%s/ca.crt" .) }}
{{- end }}
{{- range .Values.trustRootCerts }}
{{- $all = append $all (printf "/opt/cortex/tls-ca-%s/ca.crt" (. | sha256sum | substr 0 10)) }}
{{- end }}
{{- $all | compact | join "," }}
{{- end }}
