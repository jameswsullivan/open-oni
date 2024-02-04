#!/bin/bash

# Build images for your online repository (e.g. harbor)

# Initialize variables
WEB_BUILD_VERSION="0.1.0"
WEB_REPO_NAME="openoni-web"
WEB_DOCKERFILE="web.dockerfile"

RDBMS_BUILD_VERSION="0.1.0"
RDBMS_REPO_NAME="openoni-mysql"
RDBMS_DOCKERFILE="mysql.dockerfile"

MANAGER_BUILD_VERSION="0.1.0"
MANAGER_REPO_NAME="openoni-manager"
MANAGER_DOCKERFILE="manager.dockerfile"

REPOSITORY_URL="your_repository_url"
REPOSITORY_PROJECT_NAME="openoni"

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
SLEEP_TIMER=5

WEB_IMAGE_TAG=${REPOSITORY_URL}/${REPOSITORY_PROJECT_NAME}/${WEB_REPO_NAME}:${WEB_BUILD_VERSION}
RDBMS_IMAGE_TAG=${REPOSITORY_URL}/${REPOSITORY_PROJECT_NAME}/${RDBMS_REPO_NAME}:${RDBMS_BUILD_VERSION}
MANAGER_IMAGE_TAG=${REPOSITORY_URL}/${REPOSITORY_PROJECT_NAME}/${MANAGER_REPO_NAME}:${MANAGER_BUILD_VERSION}


# Build Open ONI web image:
function build_web_image() {
    echo "Begin building ${WEB_IMAGE_TAG} ... "
    echo "Log will be saved to file: web_${WEB_BUILD_VERSION}_${TIMESTAMP}_build.log ."
    echo

    docker build --file ${WEB_DOCKERFILE} --tag ${WEB_IMAGE_TAG} --progress plain \
    --no-cache . 2>&1 | tee "web_${WEB_BUILD_VERSION}_${TIMESTAMP}_build.log"
    echo

    echo "Done building: ${WEB_IMAGE_TAG}."
        
    echo
    docker images
    echo
}


# Build Open ONI MySQL/rdbms image:
function build_mysql_image() {
    echo "Begin building ${RDBMS_IMAGE_TAG} ... "
    echo "Log will be saved to file: mysql_${RDBMS_BUILD_VERSION}_${TIMESTAMP}_build.log ."
    echo

    docker build --file ${RDBMS_DOCKERFILE} --tag ${RDBMS_IMAGE_TAG} --progress plain \
    --no-cache . 2>&1 | tee "mysql_${RDBMS_BUILD_VERSION}_${TIMESTAMP}_build.log"
    echo

    echo "Done building: ${RDBMS_IMAGE_TAG}."
    
    echo
    docker images
    echo
}

# BUild Open ONI Manager/Ubuntu image:
function build_manager_image() {
    echo "Begin building ${MANAGER_IMAGE_TAG} ... "
    echo "Log will be saved to file: manager_${MANAGER_BUILD_VERSION}_${TIMESTAMP}_build.log ."
    echo

    docker build --file ${MANAGER_DOCKERFILE} --tag ${MANAGER_IMAGE_TAG} --progress plain \
    --no-cache . 2>&1 | tee "manager_${MANAGER_BUILD_VERSION}_${TIMESTAMP}_build.log"
    echo

    echo "Done building: ${MANAGER_IMAGE_TAG}."
    
    echo
    docker images
    echo
}

function purge_images() {
    docker rmi ${WEB_IMAGE_TAG}
    docker rmi ${RDBMS_IMAGE_TAG}
    docker rmi ${MANAGER_IMAGE_TAG}
    docker system prune --force
    echo
    docker images
    echo
}

function push_images() {
    # Push web image:
    if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "${WEB_IMAGE_TAG}"; then
        echo "Pushing ${WEB_IMAGE_TAG} ... "
        echo
        docker push ${WEB_IMAGE_TAG}
        echo
        echo "Done pushing ${WEB_IMAGE_TAG}"
        echo
    fi

    # Push mysql image:
    if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "${RDBMS_IMAGE_TAG}"; then
        echo "Pushing ${RDBMS_IMAGE_TAG} ... "
        echo
        docker push ${RDBMS_IMAGE_TAG}
        echo
        echo "Done pushing ${RDBMS_IMAGE_TAG}"
        echo
    fi

    # Push manager image:
    if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "${MANAGER_IMAGE_TAG}"; then
        echo "Pushing ${MANAGER_IMAGE_TAG} ... "
        echo
        docker push ${MANAGER_IMAGE_TAG}
        echo
        echo "Done pushing ${MANAGER_IMAGE_TAG}"
        echo
    fi
}

function sleep_timer() {
    echo "Waiting for ${SLEEP_TIMER} seconds to continue ... "
    echo
    sleep ${SLEEP_TIMER}
}

# Provide user options:
while true; do
    echo "Choose an Open ONI image to build:"
    echo "1. Build ${WEB_IMAGE_TAG}"
    echo "2. Build ${RDBMS_IMAGE_TAG}"
    echo "3. Build ${MANAGER_IMAGE_TAG}"
    echo "4. Build all images"
    echo "5. Purge all images with current tags ... "
    echo "6. Push images to ${REPOSITORY_URL} ... "
    echo "7. Quit"
    read -p "Enter the number of your choice: " choice

    case $choice in
        1)
            build_web_image
            ;;
        2)
            build_mysql_image
            ;;
        3)
            build_manager_image
            ;;
        4)
            build_manager_image
            sleep_timer
            build_mysql_image
            sleep_timer
            build_manager_image
            
            echo "All images have been built ..."
            docker images
            echo
            ;;
        5)
            echo "Purging all images with current tags ... "
            purge_images
            ;;
        6)
            echo "Pushing images to ${REPOSITORY_URL} ..."
            push_images
            ;;
        7)
            echo "Exiting the build script ..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done