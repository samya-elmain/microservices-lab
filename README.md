## Canary Part with istio:
We actually used this repo https://github.com/GoogleCloudPlatform/istio-samples/tree/master/istio-canary-gke#productcatalog-canary-deployment-gke--istio because we had some gRPC compatibility issue with a previous helm installation of istio and some other things so we decided to still explore istio and do it the easy way using this tuto however it also had some deprecations so anyway here is what we did and you, dear reader should also do:
1. Project and Billing Setup
```bash
gcloud config set project yasmine-istio-demo-project
gcloud services enable container.googleapis.com
gcloud billing projects link yasmine-istio-demo-project --billing-account=
```
3. GKE Cluster Creation
```bash
gcloud beta container clusters create istio - canary \
-- zone = us-central1-f \
-- machine - type = n1-standard-2 \
-- num-nodes =2
```

4. Download and Install Istio
The installation using install_istio.sh failed due to deprecated configu-
rations. I resolved this by manually installing Istio :
```bash
curl -L https://istio.io/downloadIstio | sh - 
cd istio -1.24.2
export PATH = $PWD / bin : $PATH
istioctl install -- set profile = default -y
```
6. Install Observability Tools
Prometheus was successfully installed :
```bash
kubectl apply -f https://github.com/istio/istio/releases/download/1.24.2/samples/addons/prometheus.yaml
Kiali failed to install via manifest, so I used Helm :
helm repo add kiali https :// kiali . org / helm - charts
helm repo update
helm install kiali - server kiali / kiali - server -- namespace istio-system --set auth.strategy = " anonymous "
kubectl patch svc kiali -n istio - system -p ’ {" spec ": {" type ":" LoadBalancer "}} ’
```
5. Microservices Deployment
```bash
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/kubernetes-manifests.yaml

kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/microservices-demo/master/release/istio-manifests.yaml

kubectl delete serviceentry allow-egress-google-metadata

kubectl delete serviceentry allow-egress-googleapis

kubectl patch deployments/productcatalogservice -p '{"spec":{"template":{"metadata":{"labels":{"version":"v1"}}}}}'
```

5. Canary Deployment Implementation
1/ Deploy New Version (v2) of Product Catalog

```bash
kubectl apply -f productcatalogv2.yaml

kubectl apply -f destinationrule.yaml
```
2/ Define Traffic Split
```bash
kubectl apply -f vs-split-traffic.yaml
```
3/ Monitor Traffic with Kiali and Prometheus Forwarded Prometheus to monitor traffic :
```bash
kubectl port - forward -n istio - system svc / prometheus 8080:9090
```

## Performance analysis:
This was done using the load generator VM and by running some scripts inside the container be it in a headless mode or with a UI:
like this:
```bash
locust --host="http://${FRONTEND_ADDR}" --headless -u 10 -r 1 --csv=/tmp/load_10_users
locust --host="http://${FRONTEND_ADDR}" --headless -u 50 -r 5 --csv=/tmp/load_50_users
locust --host="http://${FRONTEND_ADDR}" --headless -u 100 -r 10 --csv=/tmp/load_100_users
locust --host="http://${FRONTEND_ADDR}" --headless -u 200 -r 20 --csv=/tmp/load_200_users
```

also we had to change a little bit the ansible to expose the port 8089 like this:
```bash
    - name: Run Docker container
      docker_container:
        name: loadGenerator
        image: us-central1-docker.pkg.dev/google-samples/microservices-demo/loadgenerator:v0.10.2
        state: started
        ports:
          - "80:80"
          - "8089:8089"
```
and also to open that port in the vm this way:
```bash
gcloud compute firewall-rules create allow-locust-ui \
    --allow tcp:8089 \
    --target-tags=loadgenerator \
    --description="Allow external access to Locust UI"
    
gcloud compute instances add-tags loadgeneratorvm \
    --tags=loadgenerator \
    --zone=<your-zone>
```  
so that we could finally access the UI like this:
http://VM-IP:8089


