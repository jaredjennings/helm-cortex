{{- define "cortex.caCertVolumes" }}
{{- if .Values.elasticsearch.tls }}
- name: es-http-ca
  secret:
    secretName: {{ default .Values.elasticsearch.caCertSecret (include "cortex.elasticCACertSecretName" .) }}
    items:
      - key: {{ .Values.elasticsearch.caCertSecretMappingKey | quote }}
        path: es-http-ca.crt
{{- end }}
{{/* may need unique filenames rather than "ca.crt" for every one, so do that */}}
{{- range .Values.trustRootCertsInSecrets }}
{{ $name := printf "tls-ca-s-%s" . }}
- name: {{ $name | quote }}
  secret:
    secretName: {{ . | quote }}
    items:
      - key: "ca.crt"
        path: {{ printf "%s.crt" $name | quote }}
{{- end }}
{{- range .Values.trustRootCerts }}
{{- $shortsum := . | sha256sum | substr 0 10 }}
{{- $name := printf "tls-ca-%s" $shortsum }}
- name: {{ $name | quote }}
  secret:
    secretName: {{ printf "%s-ca-%s" (include "cortex.fullname" $) $shortsum | quote }}
    items:
      - key: "ca.crt"
        path: {{ printf "%s.crt" $name | quote }}
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
{{- $shortsum := . | sha256sum | substr 0 10 }}
- name: {{ printf "tls-ca-%s" $shortsum | quote}}
  mountPath: {{ printf "/opt/cortex/tls-ca-%s" $shortsum | quote }}
{{- end }}
{{- end }}

{{- define "cortex.esCACertFilenamesCommaSeparated" }}
{{- $all := list "" }}
{{- if .Values.elasticsearch.tls }}
{{- $all = append $all "/opt/cortex/es-http-ca/es-http-ca.crt" }}
{{- end }}
{{- $all | compact | join "," }}
{{- end }}

{{- define "cortex.wsCACertFilenamesCommaSeparated" }}
{{- $all := list "" }}
{{- range .Values.trustRootCertsInSecrets }}
{{ $name := printf "tls-ca-s-%s" . }}
{{- $all = append $all (printf "/opt/cortex/%s/%s.crt" $name $name) }}
{{- end }}
{{- range .Values.trustRootCerts }}
{{- $shortsum := . | sha256sum | substr 0 10 }}
{{- $name := printf "tls-ca-%s" $shortsum }}
{{- $all = append $all (printf "/opt/cortex/%s/%s.crt" $name $name) }}
{{- end }}
{{- $all | compact | join "," }}
{{- end }}
