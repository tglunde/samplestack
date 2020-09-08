#!/bin/sh
kubectl delete deployment webgui --grace-period=0 
kubectl delete deployment api --grace-period=0 
kubectl delete deployment scheduler --grace-period=0 
kubectl delete deployment core --grace-period=0 
kubectl delete deployment connectionpool --grace-period=0 
kubectl delete -f secrets.yaml --grace-period=0 
kubectl delete -f core-deploy.yaml
