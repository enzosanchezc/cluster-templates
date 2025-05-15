{{/*
Expand the name of the chart.
*/}}
{{- define "rke2-openstack-calico.name" -}}
{{- default .Chart.Name .Values.cluster.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rke2-openstack-calico.fullname" -}}
{{- if .Values.cluster.name }}
{{- .Values.cluster.name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.cluster.name }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rke2-openstack-calico.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "rke2-openstack-calico.labels" -}}
helm.sh/chart: {{ include "rke2-openstack-calico.chart" . }}
{{ include "rke2-openstack-calico.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "rke2-openstack-calico.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rke2-openstack-calico.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "rke2-openstack-calico.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "rke2-openstack-calico.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "cloudConfig.innerSecret" -}}
apiVersion: v1
kind: Secret
metadata:
  name: cloud-config
  namespace: kube-system
data:
  cloud.conf:
    {{- $password := (lookup "v1" "Secret" .Values.infraConfig.password.secret.namespace .Values.infraConfig.password.secret.name).data.password | b64dec }}
    {{- $config := printf "[Global]\nauth-url=%s\nusername=%s\npassword=%s\nregion=%s\ntenant-name=%s\ndomain-name=%s\n" .Values.infraConfig.authUrl .Values.infraConfig.username $password .Values.infraConfig.region .Values.infraConfig.tenantName .Values.infraConfig.domainName }}
    {{- $config := $config | b64enc }}
    {{- $config := cat " " $config }}
    {{- $config }}
{{- end }}