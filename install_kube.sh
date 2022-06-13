#!bin/bash

# install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

kubectl create namespace cert-manager
kubectl create namespace ingress-nginx

kubectl apply --validate=false -f https://github.com/Parthi10/deployment_script/blob/4fd6c0c5c96c9db9af550601aef2115f7aaf9aeb/cert-manager-1.0.4.yaml
kubectl -n ingress-nginx apply -f https://github.com/Parthi10/deployment_script/blob/4fd6c0c5c96c9db9af550601aef2115f7aaf9aeb/deploy.yaml
sleep 60

# update godaddy domain records
IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath="{.status.loadBalancer.ingress[*].ip}")
curl -X PUT "https://api.godaddy.com/v1/domains/$DOMAIN/records/A/$RECORD_NAME" -H "accept: application/json" -H "Content-Type: application/json" -H "Authorization: sso-key $GODADDY_API_KEY:$GODADDY_API_SECRET" -d "[{ \"data\": \"$IP\", \"ttl\": 3600 }]"

sleep 60
kubectl apply -f https://github.com/Parthi10/deployment_script/blob/4fd6c0c5c96c9db9af550601aef2115f7aaf9aeb/cert-issuer-nginx-ingress.yaml
sleep 60

# deploy all backend pods
kubectl create secret generic configs --from-file=yamls/config.ini

kubectl apply -f https://github.com/Parthi10/deployment_script/blob/4fd6c0c5c96c9db9af550601aef2115f7aaf9aeb/api-authentication.yaml
kubectl apply -f https://github.com/Parthi10/deployment_script/blob/4fd6c0c5c96c9db9af550601aef2115f7aaf9aeb/backend-api.yaml
kubectl apply -f https://github.com/Parthi10/deployment_script/blob/4fd6c0c5c96c9db9af550601aef2115f7aaf9aeb/batch-controller.yaml
kubectl apply -f https://github.com/Parthi10/deployment_script/blob/4fd6c0c5c96c9db9af550601aef2115f7aaf9aeb/batch-process.yaml
kubectl apply -f https://github.com/Parthi10/deployment_script/blob/4fd6c0c5c96c9db9af550601aef2115f7aaf9aeb/cron-jobs-controller.yaml
kubectl apply -f https://github.com/Parthi10/deployment_script/blob/4fd6c0c5c96c9db9af550601aef2115f7aaf9aeb/extraction-controller.yaml
kubectl apply -f https://github.com/Parthi10/deployment_script/blob/4fd6c0c5c96c9db9af550601aef2115f7aaf9aeb/extraction-process.yaml
kubectl apply -f https://github.com/Parthi10/deployment_script/blob/4fd6c0c5c96c9db9af550601aef2115f7aaf9aeb/tag-identification-service.yaml
kubectl apply -f https://github.com/Parthi10/deployment_script/blob/4fd6c0c5c96c9db9af550601aef2115f7aaf9aeb/ui-protecto-deployment.yaml

kubectl apply -f https://github.com/Parthi10/deployment_script/blob/4fd6c0c5c96c9db9af550601aef2115f7aaf9aeb/nginx-ingress.yaml
kubectl apply -f https://github.com/Parthi10/deployment_script/blob/4fd6c0c5c96c9db9af550601aef2115f7aaf9aeb/certificate.yaml



