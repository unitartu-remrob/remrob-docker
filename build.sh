#!/bin/bash
VALID_TARGETS=("noetic" "jazzy")

IMAGE_NAME="remrob"
BUILD_CONTEXT="."
IMAGE_TYPE="base"
IMAGE_SUFFIX="base"

BASE_IMAGE_NOETIC="ubuntu:focal"
BASE_IMAGE_NOETIC_CUDAGL="nvidia/cudagl:11.4.2-base-ubuntu20.04"

BASE_IMAGE_JAZZY="ubuntu:noble"
BASE_IMAGE_JAZZY_CUDAGL="tsapu/cudagl:12.6.3-runtime-ubuntu24.04"

CUDAGL_ENABLED=false

usage() {
    echo "Usage: $0 [--target <target>] [--nvidia] [--help]"
    echo "  --target        Specify the ROS version (e.g., noetic or jazzy)"
    echo "  --nvidia        Build NVIDIA runtime supported image"
    exit 1
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --target) TARGET="$2"; shift ;;
        --nvidia)
            CUDAGL_ENABLED=true
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

if [[ $TARGET == "jazzy" ]]; then 
    if $CUDAGL_ENABLED; then
        BASE_IMAGE=$BASE_IMAGE_JAZZY_CUDAGL
    else
        BASE_IMAGE=$BASE_IMAGE_JAZZY
    fi
elif [ $TARGET == "noetic" ]; then
    if $CUDAGL_ENABLED; then
        BASE_IMAGE=$BASE_IMAGE_NOETIC_CUDAGL
    else
        BASE_IMAGE=$BASE_IMAGE_NOETIC
    fi
fi


if $CUDAGL_ENABLED; then
    IMAGE_TYPE="vgl"
    IMAGE_SUFFIX="cudagl"
fi

TAG="$TARGET-$IMAGE_SUFFIX"

echo "Building "$IMAGE_NAME-$TAG" image..."
docker build \
    -f "$TARGET/Dockerfile" \
    -t "$IMAGE_NAME:$TAG" \
    --build-arg BASE_IMAGE=$BASE_IMAGE \
    --build-arg IMAGE_TYPE=$IMAGE_TYPE \
    "$BUILD_CONTEXT"