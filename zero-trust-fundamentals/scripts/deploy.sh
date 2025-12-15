#!/bin/bash
# Deploy Zero Trust Fundamentals Lab
#
# Starts the microservices architecture with docker-compose:
# - MongoDB for data storage
# - Identity service for JWT authentication
# - Web service with protected endpoints

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(dirname "$SCRIPT_DIR")"

echo "======================================"
echo "Deploying Zero Trust Fundamentals Lab"
echo "======================================"
echo ""

cd "$LAB_DIR"

echo "Building and starting services..."
docker-compose up -d --build

echo ""
echo "Waiting 30 seconds for services to initialize..."
sleep 30

echo ""
echo "======================================"
echo "Lab Deployed Successfully!"
echo "======================================"
echo ""
echo "Services:"
echo "  - Identity: http://localhost:8443"
echo "  - Web App:  http://localhost:8080"
echo "  - MongoDB:  localhost:27017 (internal)"
echo ""
echo "Test credentials:"
echo "  Username: alice"
echo "  Password: password123"
echo ""
echo "Validate:"
echo "  ./scripts/validate.sh"
echo ""
echo "Cleanup:"
echo "  ./scripts/cleanup.sh"
echo ""
