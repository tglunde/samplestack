NS=dev
#all resources from namespace
kubectl delete namespace $NS
#additional CRDs wo namespace
kubectl delete -f https://strimzi.io/install/latest?namespace=$NS -n $NS
