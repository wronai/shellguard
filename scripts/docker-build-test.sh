#!/bin/bash
# Build and test ShellGuard Docker images

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Build the development image
echo -e "${YELLOW}🚧 Building development image...${NC}"
docker build -f docker/Dockerfile.dev -t shellguard-dev .

echo -e "\n${YELLOW}🚧 Building test image...${NC}"
docker build -f docker/Dockerfile.test -t shellguard-test .

# Run tests in the test container
echo -e "\n${YELLOW}🔍 Running tests...${NC}"
docker-compose -f docker/docker-compose.yml run --rm test

# Check for test results
if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✅ All tests passed!${NC}
"
    echo "To start a development container:"
    echo "  docker-compose -f docker/docker-compose.yml run --rm dev"
else
    echo -e "\n❌ Some tests failed. Check the output above for details.\n"
    exit 1
fi
