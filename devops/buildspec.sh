#!/bin/bash

THE_DATE=$(date '+%Y-%m-%d %H:%M:%S')
echo "Build started on $THE_DATE"

appenvsubstr(){
    p_template=$1
    p_destination=$2
    envsubst '$TF_VAR_ENV_APP_GL_SCRIPT_MODE' < $p_template \
    | envsubst '$TF_VAR_ENV_APP_GL_NAMESPACE' \
    | envsubst '$TF_VAR_ENV_APP_GL_NAME' \
    | envsubst '$TF_VAR_ENV_APP_GL_STAGE' \
    | envsubst '$TF_VAR_ENV_APP_BE_DOMAIN_NAME' \
    | envsubst '$TF_VAR_ENV_APP_BE_URL' \
    | envsubst '$TF_VAR_ENV_APP_BE_LOCAL_PORT' \
    | envsubst '$TF_VAR_ENV_APP_BE_LOCAL_SOURCE_FOLDER' \
    | envsubst '$TF_VAR_ENV_APP_GL_AWS_REGION_ECR' \
    | envsubst '$TF_VAR_ENV_APP_GL_DOCKER_REPOSITORY' \
    | envsubst '$TF_VAR_ENV_APP_KC_URL' > $p_destination
}


appenvsubstr devops/appspec.yml.template appspec.yml
appenvsubstr devops/appspec.sh.template devops/appspec.sh
chmod 777 devops/appspec.sh
appenvsubstr devops/.env.template .env

appenvsubstr devops/keycloak.json.template public/keycloak.json
appenvsubstr devops/config.js.template config/config.js
appenvsubstr devops/realm-import.json.template config/realm-import.json

appenvsubstr devops/Dockerfile.template Dockerfile
appenvsubstr devops/docker-compose.yml.template docker-compose.yml

DOCKER_REGISTRY="$TF_VAR_ENV_APP_GL_DOCKER_REPOSITORY"
ECR_REGION="$TF_VAR_ENV_APP_GL_AWS_REGION_ECR"
ECR_REPOSITORY="${TF_VAR_ENV_APP_GL_NAMESPACE}_${TF_VAR_ENV_APP_GL_NAME}_${TF_VAR_ENV_APP_GL_STAGE}"
ECR_TAG="${TF_VAR_ENV_APP_GL_NAMESPACE}_${TF_VAR_ENV_APP_GL_NAME}_${TF_VAR_ENV_APP_GL_STAGE}"

echo "Building the Docker image..."
docker build -t $ECR_REPOSITORY:$ECR_TAG .

echo "Create $ECR_REPOSITORY repository..."
aws ecr describe-repositories --repository-names $ECR_REPOSITORY --region $ECR_REGION || aws ecr create-repository --repository-name $ECR_REPOSITORY --region $ECR_REGION
aws ecr delete-repository --repository-name $ECR_REPOSITORY --force
aws ecr create-repository --repository-name $ECR_REPOSITORY --region $ECR_REGION

echo "Tag your image with the Amazon ECR registry..."
docker tag $ECR_REPOSITORY:$ECR_TAG $DOCKER_REGISTRY/$ECR_REPOSITORY:$ECR_TAG

echo "Push the image to ecr..."
docker push $DOCKER_REGISTRY/$ECR_REPOSITORY:$ECR_TAG
