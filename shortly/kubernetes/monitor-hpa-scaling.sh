#!/bin/bash

echo "🔍 HPA Scaling Monitor - Shortly Application"
echo "==========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display current status
show_status() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${BLUE}📅 $timestamp${NC}"
    echo ""
    
    echo -e "${YELLOW}🎯 HPA Status:${NC}"
    kubectl get hpa -n shortly
    echo ""
    
    echo -e "${YELLOW}📊 Pod Resource Usage:${NC}"
    kubectl top pods -n shortly
    echo ""
    
    echo -e "${YELLOW}🔄 Pod Status:${NC}"
    kubectl get pods -n shortly -o wide
    echo ""
    
    echo -e "${YELLOW}⚡ Load Test Pods:${NC}"
    kubectl get pods -n shortly | grep -E "(load-test|stress-test|aggressive)"
    echo ""
    
    echo -e "${GREEN}📈 Backend Replicas:${NC}"
    kubectl get deployment backend -n shortly -o jsonpath='{.status.replicas}/{.spec.replicas}' 
    echo " (current/desired)"
    
    echo -e "${GREEN}📈 Frontend Replicas:${NC}"
    kubectl get deployment frontend -n shortly -o jsonpath='{.status.replicas}/{.spec.replicas}'
    echo " (current/desired)"
    echo ""
    
    echo "================================================"
    echo ""
}

# Function to check if load test is running
check_load_test() {
    local load_pods=$(kubectl get pods -n shortly | grep -E "(load-test|stress-test|aggressive)" | grep Running | wc -l)
    if [ $load_pods -eq 0 ]; then
        echo -e "${RED}⚠️  No load test pods running! Starting load test...${NC}"
        kubectl apply -f load-test.yaml
        echo ""
    else
        echo -e "${GREEN}✅ Load test is running with $load_pods pods${NC}"
        echo ""
    fi
}

# Function to show scaling events
show_events() {
    echo -e "${YELLOW}📋 Recent Scaling Events:${NC}"
    kubectl get events -n shortly --sort-by='.lastTimestamp' | grep -E "(Scaled|SuccessfulCreate|Killing)" | tail -10
    echo ""
}

# Main monitoring loop
echo "Starting HPA monitoring... Press Ctrl+C to stop"
echo ""

# Initial status
show_status
check_load_test

# Monitor every 30 seconds
while true; do
    sleep 30
    clear
    echo "🔍 HPA Scaling Monitor - Shortly Application"
    echo "==========================================="
    echo ""
    
    show_status
    show_events
    
    echo -e "${BLUE}💡 Tips:${NC}"
    echo "- HPA evaluates every 15 seconds"
    echo "- Scale-up happens when CPU > threshold for 3 minutes"
    echo "- Scale-down happens when CPU < threshold for 5 minutes"
    echo "- Check load test: kubectl logs -l app=aggressive-load-test -n shortly"
    echo ""
    
    echo "Refreshing in 30 seconds... (Ctrl+C to stop)"
done 