#!/bin/bash

# Test script to verify RAG system is working correctly

echo "Testing Local RAG System..."
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
PASSED=0
FAILED=0

# Function to test endpoint
test_endpoint() {
    local name=$1
    local url=$2
    local expected=$3
    
    echo -n "Testing $name... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    
    if [ "$response" -eq "$expected" ]; then
        echo -e "${GREEN}PASSED${NC}"
        ((PASSED++))
    else
        echo -e "${RED}FAILED${NC} (got $response, expected $expected)"
        ((FAILED++))
    fi
}

# Test 1: Backend health
test_endpoint "Backend health" "http://localhost:8000/health" 200

# Test 2: Backend root
test_endpoint "Backend root" "http://localhost:8000/" 200

# Test 3: Files endpoint
test_endpoint "Files list" "http://localhost:8000/api/files" 200

# Test 4: Frontend
echo -n "Testing Frontend... "
if curl -s http://localhost:5173 | grep -q "Local RAG"; then
    echo -e "${GREEN}PASSED${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAILED${NC}"
    ((FAILED++))
fi

# Test 5: Ollama
echo -n "Testing Ollama... "
if curl -s http://localhost:11434/api/tags > /dev/null 2>&1; then
    echo -e "${GREEN}PASSED${NC}"
    ((PASSED++))
else
    echo -e "${YELLOW}WARNING${NC} (Ollama not running - system will still work but without LLM generation)"
fi

echo ""
echo "========================"
echo "Test Results:"
echo "  Passed: ${GREEN}$PASSED${NC}"
echo "  Failed: ${RED}$FAILED${NC}"
echo "========================"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All critical tests passed!${NC}"
    echo ""
    echo "System is ready to use!"
    echo "Open: http://localhost:5173"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    echo ""
    echo "Troubleshooting:"
    echo "1. Ensure backend is running: cd backend && python -m app.main"
    echo "2. Ensure frontend is running: cd frontend && npm run dev"
    echo "3. Check for port conflicts: lsof -i :8000,5173"
    exit 1
fi
