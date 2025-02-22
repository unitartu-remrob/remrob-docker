#!/bin/bash

NOETIC="noetic"
JAZZY="jazzy"

VALID_TARGETS=($NOETIC $JAZZY)

IMAGE_NAME="remrob"
BUILD_CONTEXT="."
IMAGE_TYPE="base"
IMAGE_SUFFIX="base"

BASE_IMAGE_NOETIC="ubuntu:focal"
BASE_IMAGE_NOETIC_CUDAGL="nvidia/cudagl:11.4.2-base-ubuntu20.04"

BASE_IMAGE_JAZZY="ubuntu:noble"
BASE_IMAGE_JAZZY_CUDAGL="tsapu/cudagl:12.6.3-runtime-ubuntu24.04"

CUDAGL_ENABLED=false
BUILD_ROBOT_IMAGES=true

ROBOTONT="robotont"
XARM="xarm"

ROBOT_OPTIONS_NOETIC=(
    $ROBOTONT
)

ROBOT_OPTIONS_JAZZY=(
    $ROBOTONT
    $XARM
)

usage() {
    echo "Usage: $0 --target <target> [--nvidia] [--robot <robot>] [--help]"
    echo "  --target        Specify the ROS version (e.g., noetic or jazzy)"
    echo "  --nvidia        Build NVIDIA runtime supported image"
    echo "  --robot         Specify robot child image to build (by default builds all)"
    echo "  --no-robot      Do not build any robot child images"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --target) TARGET="$2"; shift ;;
        --nvidia)
            CUDAGL_ENABLED=true
            ;;
        --robot)
            ROBOT="$2"; shift ;;
        --no-robot)
            BUILD_ROBOT_IMAGES=false
            ;;
        --help)
            usage ;;
        *)
            echo "Unknown option: $1"
            usage ;;
    esac
    shift
done

if [[ -z "$TARGET" ]]; then
    echo "Error: --target is required"
    usage
elif [[ ! " ${VALID_TARGETS[@]} " =~ " ${TARGET} " ]]; then
    echo "Error: Unsupported target specified: $TARGET"
    echo "Valid targets: $(IFS=','; echo "${VALID_TARGETS[*]}")"
    exit 1
fi

if [[ $TARGET == $JAZZY ]]; then 
    if $CUDAGL_ENABLED; then
        BASE_IMAGE=$BASE_IMAGE_JAZZY_CUDAGL
    else
        BASE_IMAGE=$BASE_IMAGE_JAZZY
    fi
    VALID_ROBOT_OPTIONS=("${ROBOT_OPTIONS_JAZZY[@]}")
elif [ $TARGET == $NOETIC ]; then
    if $CUDAGL_ENABLED; then
        BASE_IMAGE=$BASE_IMAGE_NOETIC_CUDAGL
    else
        BASE_IMAGE=$BASE_IMAGE_NOETIC
    fi
    VALID_ROBOT_OPTIONS=("${ROBOT_OPTIONS_NOETIC[@]}")
fi

if [[ $ROBOT != "" && ! " ${VALID_ROBOT_OPTIONS[@]} " =~ " ${ROBOT} " ]]; then
    echo "Error: Unsupported robot specified: $ROBOT"
    echo "Valid robots for $TARGET: $(IFS=','; echo "${VALID_ROBOT_OPTIONS[*]}")"
    exit 1
fi

if $CUDAGL_ENABLED; then
    IMAGE_TYPE="vgl"
    IMAGE_SUFFIX="cudagl"
fi

TAG="$TARGET-$IMAGE_SUFFIX"

echo "Building "$IMAGE_NAME:$TAG" image..."
docker build \
    -f "$TARGET/Dockerfile" \
    -t "$IMAGE_NAME:$TAG" \
    --build-arg BASE_IMAGE=$BASE_IMAGE \
    --build-arg IMAGE_TYPE=$IMAGE_TYPE \
    "$BUILD_CONTEXT"

if [[ $ROBOT != "" ]]; then
    # build only the specified robot image
    echo "Building child image "$ROBOT:$TAG" from $IMAGE_NAME:$TAG..."
    docker build \
        -f "$TARGET/Dockerfile.$ROBOT" \
        -t "$ROBOT:$TAG" \
        --build-arg BASE_IMAGE=$IMAGE_NAME:$TAG \
        "$BUILD_CONTEXT"
elif $BUILD_ROBOT_IMAGES; then
    # build all robot images
    for robot in "${VALID_ROBOT_OPTIONS[@]}"; do
        echo "Building child image "$robot:$TAG" from $IMAGE_NAME:$TAG..."
        docker build \
            -f "$TARGET/Dockerfile.$robot" \
            -t "$robot:$TAG" \
            --build-arg BASE_IMAGE=$IMAGE_NAME:$TAG \
            "$BUILD_CONTEXT"
    done
fi