#!/bin/bash

# Script: monitoring-setup.sh
# Description: This script automates the deployment of Prometheus, Grafana, Node Exporter, cAdvisor, and Redis Exporter in a Kubernetes cluster.
# Usage: ./monitoring-setup.sh

NAMESPACE="monitoring"

echo "Creating Kubernetes namespace '$NAMESPACE'..."
kubectl create namespace $NAMESPACE || echo "Namespace '$NAMESPACE' already exists."

echo "Adding Helm repositories..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo "Deploying Grafana using Helm..."
helm install grafana grafana/grafana -n $NAMESPACE --set adminPassword=admin || echo "Grafana already installed."

echo "Deploying Node Exporter as a DaemonSet..."
kubectl apply -n $NAMESPACE -f ./node-exporter.yaml

echo "Deploying cAdvisor as a DaemonSet..."
kubectl apply -n $NAMESPACE -f ./cadvisor.yaml

echo "Deploying Redis Exporter..."
kubectl apply -f ./redis-exporter-service.yaml
kubectl apply -f ./redis-exporter.yaml

echo "Deploying Prometheus using Helm with custom values..."
helm install prometheus prometheus-community/prometheus -n $NAMESPACE -f values.yaml --create-namespace || echo "Prometheus already installed. Upgrading with custom values..."
helm upgrade prometheus prometheus-community/prometheus -n $NAMESPACE -f values.yaml

echo "Waiting for Prometheus and Grafana to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus-server -n $NAMESPACE
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n $NAMESPACE

echo "Starting port forwarding for Prometheus and Grafana..."
kubectl port-forward svc/prometheus-server 9090:80 -n $NAMESPACE &
kubectl port-forward svc/grafana 3000:80 -n $NAMESPACE &

echo "===================================================="
echo "Monitoring setup complete!"
echo "Prometheus is available at: http://localhost:9090"
echo "Grafana is available aACSt: http://localhost:3000"
echo "Login to Grafana using username 'admin' and password 'admin'."
echo "===================================================="
