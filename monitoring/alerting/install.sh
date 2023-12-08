#!/bin/sh
# Patch notification alerts 

echo Patching alert manager secrets 
kubectl patch secret alertmanager-rancher-monitoring-alertmanager -n cattle-monitoring-system  --patch="{\"data\": { \"alertmanager.yaml\": \"$(cat ./alertmanager.yaml |base64 |tr -d '\n' )\" }}"
echo Regenerating secrets
kubectl delete secret alertmanager-rancher-monitoring-alertmanager-generated -n cattle-monitoring-system
echo Adding cluster name
kubectl patch Prometheus rancher-monitoring-prometheus -n cattle-monitoring-system --patch-file patch-cluster-name.yaml --type=merge
echo Adding Helm Repo for Prometheus blockbox Exporter for ssh certificate expiry monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
echo Installing prometheus-blackbox-exporter
helm install prometheus-blackbox-exporter prometheus-community/prometheus-blackbox-exporter -f blackbox-exporter-values.yaml -n cattle-monitoring-system
#echo Installing prometheus-elsticsearch-exporter
#helm install prometheus-elsticsearch-exporter prometheus-community/prometheus-elasticsearch-exporter -f elasticsearch-exporter-values.yaml -n cattle-monitoring-system
#echo Create and Copying secrets
#./copy_cm.sh $SLACKURL
echo Applying custom alerts
kubectl apply -f custom-alerts/ 



#See https://github.com/prometheus/blackbox_exporter/ for how to configure Prometheus and the Blackbox Exporter.

#1. Get the application URL by running these commands:
#  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=prometheus-blackbox-exporter,app.kubernetes.io/instance=rancher-monitoring" -o jsonpath="{.items[0].metadata.name}")
#  export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
#  echo "Visit http://127.0.0.1:8080 to use your application"
#  kubectl --namespace default port-forward $POD_NAME 8080:$CONTAINER_PORT