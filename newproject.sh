#!/bin/sh
#Version 1.8

# Set default values for boolean options
provision_app=false
FORWARD_ARGS=""

# Parse command-line arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --new)
      provision_app=true
      ;;
    --livewire|--no-livewire|--tailwind|--no-tailwind|--windows|--no-windows)
      FORWARD_ARGS="$FORWARD_ARGS $1"
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

#Pull down github action file
if [ ! -f .github/workflows/build.yaml ]; then
       curl https://raw.githubusercontent.com/Middle-Earth-Gitops/public-deploy-scripts/master/build.yaml --create-dirs -o .github/workflows/build.yaml
fi

#Pull down docker-compose.yaml file
if [ ! -f docker-compose.yaml ]; then
       curl https://raw.githubusercontent.com/Middle-Earth-Gitops/public-deploy-scripts/master/docker-compose.yaml --create-dirs -o docker-compose.yaml
fi

#Pull down deploy-plan.json file
if [ ! -f deploy-plan.json ]; then
       curl https://raw.githubusercontent.com/Middle-Earth-Gitops/public-deploy-scripts/master/deploy-plan.json --create-dirs -o deploy-plan.json
fi

#give developers a script to create a new laravel project if a laravel app is not detected
if [ ! -d app ]; then
       if [ ! -f new-laravel-app.sh ]; then
              curl https://raw.githubusercontent.com/Middle-Earth-Gitops/public-deploy-scripts/master/new-laravel-app.sh --create-dirs -o new-laravel-app.sh
              chmod +x new-laravel-app.sh
       fi
fi

if [ ! -d Dockerfile.dev ]; then
       curl -X POST -d @deploy-plan.json --header "Content-Type: application/json" -H "AUTH: $AUTH" http://localhost:8080/api/docker/build-dev > Dockerfile.dev
fi

#Build and run container
docker stop app
docker rm app
docker-compose up -d --build
