#!/bin/bash

echo "=== Ghost CMS Debug Script ==="
echo ""

# Check if .env file exists
echo "1. Checking environment file..."
if [ -f ".env" ]; then
    echo "✅ .env file exists"
    echo "Environment variables found:"
    grep -E "^[A-Z]" .env | cut -d'=' -f1
else
    echo "❌ .env file missing! Run ./setup-credentials.sh first"
    exit 1
fi

echo ""

# Check Docker containers status
echo "2. Checking container status..."
docker-compose ps

echo ""

# Check if containers are running
echo "3. Checking if Ghost containers are running..."
GHOST_RUNNING=$(docker ps --filter "name=blog-ghost" --filter "status=running" -q)
DB_RUNNING=$(docker ps --filter "name=blog-ghost-db" --filter "status=running" -q)

if [ -n "$GHOST_RUNNING" ]; then
    echo "✅ Ghost container is running"
else
    echo "❌ Ghost container is not running"
fi

if [ -n "$DB_RUNNING" ]; then
    echo "✅ Database container is running"
else
    echo "❌ Database container is not running"
fi

echo ""

# Check Ghost logs
echo "4. Recent Ghost logs (last 20 lines):"
echo "----------------------------------------"
docker-compose logs --tail=20 ghost
echo "----------------------------------------"

echo ""

# Check database logs
echo "5. Recent Database logs (last 10 lines):"
echo "----------------------------------------"
docker-compose logs --tail=10 ghost-db
echo "----------------------------------------"

echo ""

# Test database connection
echo "6. Testing database connection..."
if [ -n "$DB_RUNNING" ]; then
    echo "Attempting to connect to database..."
    docker exec blog-ghost-db mysqladmin ping -h localhost -u ghost -p$(grep GHOST_DB_PASSWORD .env | cut -d'=' -f2) 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ Database connection successful"
    else
        echo "❌ Database connection failed"
    fi
else
    echo "❌ Database container not running, cannot test connection"
fi

echo ""

# Check Traefik network
echo "7. Checking Traefik network..."
TRAEFIK_NETWORK=$(docker network ls --filter "name=traefik-public" -q)
if [ -n "$TRAEFIK_NETWORK" ]; then
    echo "✅ traefik-public network exists"
else
    echo "❌ traefik-public network missing! Create it with: docker network create traefik-public"
fi

echo ""

# Check if Ghost is accessible internally
echo "8. Testing Ghost internal connectivity..."
if [ -n "$GHOST_RUNNING" ]; then
    echo "Testing if Ghost responds on port 2368..."
    docker exec blog-ghost wget -q --spider http://localhost:2368 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ Ghost responds on internal port 2368"
    else
        echo "❌ Ghost not responding on internal port 2368"
    fi
else
    echo "❌ Ghost container not running, cannot test"
fi

echo ""
echo "=== Debug Summary ==="
echo "If you see any ❌ above, those are the issues to fix."
echo ""
echo "Common solutions:"
echo "- If .env missing: Run ./setup-credentials.sh"
echo "- If containers not running: Run docker-compose up -d"
echo "- If database connection fails: Check GHOST_DB_PASSWORD in .env"
echo "- If traefik-public network missing: Run docker network create traefik-public"
echo "- If Ghost not responding: Check Ghost logs for errors"
