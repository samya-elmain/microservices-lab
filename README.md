## Canary Part with istio:
We actually used this repo https://github.com/GoogleCloudPlatform/istio-samples/tree/master/istio-canary-gke#productcatalog-canary-deployment-gke--istio because we had some gRPC compatibility issue with a previous helm installation of istio and some other things so we decided to still explore istio and do it the easy way using this tuto however it also had some deprecations so anyway here is what we did and you, dear reader should also do:
1. Project and Billing Setup
gcloud config set project yasmine - istio - demo - project
gcloud services enable container . googleapis . com
gcloud billing projects link yasmine - istio - demo - project --
billing - account =010 A3E -3452 F8 - C85061

2. GKE Cluster Creation
gcloud beta container clusters create istio - canary \
-- zone = us - central1 - f \
-- machine - type = n1 - standard -2 \
-- num - nodes =2


3. Download and Install Istio
The installation using install_istio.sh failed due to deprecated configu-
rations. I resolved this by manually installing Istio :
curl -L https://istio.io/downloadIstio | sh - 
cd istio -1.24.2
export PATH = $PWD / bin : $PATH
istioctl install -- set profile = default -y

4. Install Observability Tools
Prometheus was successfully installed :

kubectl apply -f https :// github . com / istio / istio / releases /
download /1.24.2/ samples / addons / prometheus . yaml
Kiali failed to install via manifest, so I used Helm :
helm repo add kiali https :// kiali . org / helm - charts
helm repo update
helm install kiali - server kiali / kiali - server -- namespace istio
- system -- set auth . strategy = " anonymous "
kubectl patch svc kiali -n istio - system -p ’ {" spec ": {" type ":" LoadBalancer "}} ’

5. Microservices Deployment
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/kubernetes-manifests.yaml
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/istio-manifests.yaml
kubectl delete serviceentry allow-egress-google-metadata
kubectl delete serviceentry allow-egress-googleapis
kubectl patch deployments/productcatalogservice -p '{"spec":{"template":{"metadata":{"labels":{"version":"v1"}}}}}'


5. Canary Deployment Implementation
1/ Deploy New Version (v2) of Product Catalog
kubectl apply -f productcatalogv2.yaml
kubectl apply -f destinationrule.yaml

2/ Define Traffic Split
kubectl apply -f vs-split-traffic.yaml
3/ Monitor Traffic with Kiali and Prometheus Forwarded Prometheus to monitor traffic :
kubectl port - forward -n istio - system svc / prometheus 8080:9090

