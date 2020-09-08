kubectl apply -f secrets.yaml
kubectl apply -f core-deploy.yaml
sleep 5
kubectl apply -f connection_pool-deploy.yaml
sleep 10
kubectl apply -f api-deploy.yaml
kubectl apply -f scheduler-deploy.yaml
sleep 20
kubectl apply -f webgui-deploy.yaml
