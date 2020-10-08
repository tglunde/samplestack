NS=dev
#all resources from namespace
kubectl create namespace $NS
#additional CRDs wo namespace
kustomize build iac/k8s/overlay/crds | kubectl apply -f -
sleep 2s
kustomize build iac/k8s/overlay/dev-kafka-broker | kubectl apply -f -
kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n $NS
kustomize build iac/k8s/overlay/dev-exa-sr | kubectl apply -f -
