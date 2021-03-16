kubectl create namespace dev
kustomize build exasol/overlay/dev | kubectl apply -f - && ./waitforit -host localhost -port 8888

