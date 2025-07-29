#!/bin/bash

echo "=== Ghost HTTP Debug Script ==="
echo ""

# Check if Ghost container is running
GHOST_RUNNING=$(docker ps --filter "name=blog-ghost" --filter "status=running" -q)

if [ -z "$GHOST_RUNNING" ]; then
    echo "❌ Ghost container is not running!"
    echo "Run: docker-compose up -d"
    exit 1
fi

echo "✅ Ghost container is running"
echo ""

# Check Ghost process inside container
echo "1. Checking Ghost process inside container..."
docker exec blog-ghost ps aux | grep node || echo "No node process found"
echo ""

# Check if Ghost is listening on port 2368
echo "2. Checking if Ghost is listening on port 2368..."
docker exec blog-ghost netstat -tlnp 2>/dev/null | grep :2368 || echo "Port 2368 not listening"
echo ""

# Try to curl Ghost directly
echo "3. Testing HTTP response from Ghost..."
docker exec blog-ghost curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:2368 2>/dev/null || echo "Curl failed"
echo ""

# Check Ghost configuration
echo "4. Checking Ghost configuration..."
docker exec blog-ghost printenv | grep -E "(url|server|database)" | sort
echo ""

# Check recent Ghost logs for startup messages
echo "5. Recent Ghost startup logs..."
echo "----------------------------------------"
docker-compose logs --tail=30 ghost | grep -E "(Ghost is running|Listening on|started|error|Error)"
echo "----------------------------------------"
echo ""

# Test database connectivity from Ghost container
echo "6. Testing database connection from Ghost container..."
docker exec blog-ghost nc -z ghost-db 3306 && echo "✅ Database port reachable" || echo "❌ Database port not reachable"
echo ""

echo "=== Troubleshooting Steps ==="
echo "If Ghost is not listening on port 2368:"
echo "1. Check Ghost logs: docker-compose logs ghost"
echo "2. Restart Ghost: docker-compose restart ghost"
echo "3. Check .env file has correct database password"
echo "4. Try: docker-compose down && docker-compose up -d"
