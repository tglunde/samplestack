- [1. Deployment Überblick](#1-deployment-überblick)
- [2. CI/CD Komponenten](#2-cicd-komponenten)
  - [2.1. Gitlab](#21-gitlab)
  - [2.2. Jenkins CI](#22-jenkins-ci)
  - [2.3. ArgoCD](#23-argocd)
  - [2.4. ACR](#24-acr)
- [3. DWH Komponenten](#3-dwh-komponenten)
  - [3.1. Exasol Database (docker-db für dev und staging)](#31-exasol-database-docker-db-für-dev-und-staging)
  - [3.2. Datavault Builder](#32-datavault-builder)
  - [3.3. Data Build Tool](#33-data-build-tool)
  - [3.4. JasperReport](#34-jasperreport)
  - [3.5. Superset](#35-superset)
  - [3.6. Airflow](#36-airflow)
- [4. Entwicklungsumgebung (lokal)](#4-entwicklungsumgebung-lokal)
  - [4.1. Berechtigungsgruppen AD](#41-berechtigungsgruppen-ad)
  - [4.2. Proxyeinstellungen](#42-proxyeinstellungen)
  - [4.3. Installations for local dev (laptop)](#43-installations-for-local-dev-laptop)
  - [4.4. IAC - Services und Kubernetes YAML](#44-iac---services-und-kubernetes-yaml)
- [5. Staging Environment (Azure)](#5-staging-environment-azure)
- [6. Produktion (Azure)](#6-produktion-azure)
- [7. Logging und Monitoring](#7-logging-und-monitoring)
- [8. Betriebshandbuch](#8-betriebshandbuch)


# 1. Deployment Überblick

- Kubernetes Cluster
- lokal
- staging
- production

# 2. CI/CD Komponenten
## 2.1. Gitlab
Gitlab instanz im Azure, um die Entwicklungsergebnisse vom on-prem enterprise Github Server in die Cloud zu pushen.
Hierfür muss ein entsprechender SSH-Key-Pair eingerichtet werden, das im Gitlab und im Github entsprechend hinterlegt wird.
Anschließend wird im Github ein entpsrechender Commit-Hook angelegt, der alle Änderungen in die Cloud Gitlab Instanz pushed.

## 2.2. Jenkins CI
CI-Server um die Commits auf der Azure Cloud Staging Instanz zu verproben. Entsprechende Pipeline erzeugt die Testjobs und führt die Tests aus.
dbt seed - dbt+dvb run - dbt test

## 2.3. ArgoCD
CD-Server für Kubernetes. Erfolgreich Tests erzeugen ein neues Tag - das entsprechend in den Kubernetes.yaml gepushed wird. Dieser IAC-change gilt als trigger für das ArgoCD und das Test-Deployment.

## 2.4. ACR
Die benötigten Docker images (iac/services/*) werden in der ACR registry abgelegt. Neue Tags / Versionen müssen gleichermaßen im iac/k8s YAML eingetragen werden, um neue Deployments im Test zu triggern (siehe ArgoCD).

# 3. DWH Komponenten
## 3.1. Exasol Database (docker-db für dev und staging)
## 3.2. Datavault Builder
## 3.3. Data Build Tool
## 3.4. JasperReport
## 3.5. Superset
## 3.6. Airflow

# 4. Entwicklungsumgebung (lokal)
https://github1.vg.vector.int/pes

## 4.1. Berechtigungsgruppen AD

## 4.2. Proxyeinstellungen
set NO_PROXY=localhost, 127.0.0.*, 172.31.31.* *.vector.int, 10.49.*, 10.149.*,kubernetes.docker.internal,github1.vg.vector.int
git config --global http.sslVerify false

## 4.3. Installations for local dev (laptop)
### 4.3.1. Empfohlene Commandline
Windows Terminal
CMDer.net
Unterstützung für git muss gegeben sein
WLS-2 wäre empfehlenswert
azure-cli missing
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
https://aka.ms/installazurecliwindows

### 4.3.2. Docker Desktop Edge
https://docs.docker.com/docker-for-windows/edge-release-notes/

### 4.3.3. Chocolatey - Package Manager
https://chocolatey.org/install

### 4.3.4. k9s command line monitor
choco install k9s
installiert auch kubectl
kubectl config get-contexts

### 4.3.5. Kustomize
choco install kustomize

### 4.3.6. Helm
choco install kubernetes-helm

### 4.3.7. ArgoCD CLI
https://github.com/argoproj/argo-cd/releases/download/v1.7.6/argocd-windows-amd64.exe

copy argocd-windows-amd64.exe %PATH%-Element (cmder bin directory)

### 4.3.8. Installation of IDE (VSCode)

## 4.4. IAC - Services und Kubernetes YAML
### 4.4.1. Services - docker images
### 4.4.2. K8s - YAML
#### 4.4.2.1. Definierte Deployments und deren Kustomizations
#### 4.4.2.2. Aktuallisierung von Komponenten aus helm charts
asdfasdfasdfasdf
adsf
adfadf
# 5. Staging Environment (Azure)


# 6. Produktion (Azure)

# 7. Logging und Monitoring

# 8. Betriebshandbuch
