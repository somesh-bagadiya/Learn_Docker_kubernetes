#!/bin/bash

# Monitor Kubernetes Scaling and Resource Usage
# Usage: ./monitor-scaling.sh

echo "🚀 Kubernetes Scaling Monitor - Shortly Application"
echo "=================================================="
echo ""

# Function to display current status
show_status() {
    echo "📊 Current Status - $(date)"
    echo "----------------------------------------"
    
    echo "🏗️  Nodes:"
    kubectl top nodes 2>/dev/null || echo "Metrics not available yet"
    echo ""
    
    echo "🚀 Pods in shortly namespace:"
    kubectl get pods -n shortly -o wide
    echo ""
    
    echo "📈 Pod Resource Usage:"
    kubectl top pods -n shortly 2>/dev/null || echo "Metrics not available yet"
    echo ""
    
    echo "🎯 HPA Status:"
    kubectl get hpa -n shortly
    echo ""
    
    echo "📋 Services:"
    kubectl get services -n shortly
    echo ""
    
    echo "=================================================="
    echo ""
}

# Check if metrics server is running
echo "🔍 Checking Metrics Server..."
if kubectl get pods -n kube-system | grep -q "metrics-server.*Running"; then
    echo "✅ Metrics Server is running"
else
    echo "❌ Metrics Server not found or not running"
    echo "Install with: kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
    echo ""
fi

# Show initial status
show_status

# Monitor mode
if [[ "$1" == "--watch" ]]; then
    echo "👀 Watching for changes (Press Ctrl+C to stop)..."
    echo ""
    
    while true; do
        sleep 30
        clear
        show_status
    done
else
    echo "💡 Run with --watch to monitor continuously"
    echo "💡 Run load test with: kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh"
fi 