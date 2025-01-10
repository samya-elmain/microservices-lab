# Monitoring Stack Deployment

This project deploys a monitoring stack in a Kubernetes cluster. The stack includes:
- **Prometheus** for data collection
- **Grafana** for visualization
- **Node Exporter** for node-level metrics
- **cAdvisor** for container-level metrics
- **Redis Exporter** for Redis metrics

## Prerequisites

1. A Kubernetes cluster with `kubectl` configured.
2. Helm installed ([Helm Installation Guide](https://helm.sh/docs/intro/install/)).

## Deployment Steps

To deploy the monitoring stack, simply run the provided script:

```bash
./monitoring-setup.sh
```

This script will:
1. Apply the necessary Kubernetes manifests (YAML files) for Prometheus, Grafana, Node Exporter, cAdvisor, and Redis Exporter.
2. Set up services and deployments required for monitoring.

## Accessing Grafana

This is explained in the rport documentation.

