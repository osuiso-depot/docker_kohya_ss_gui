# For build automation - Allows building from any ai-dock base image
# Use a *cuda*base* image as default because pytorch brings the libs
ARG IMAGE_BASE="ghcr.io/ai-dock/python:3.10-v2-cuda-12.1.1-cudnn8-runtime-22.04"
FROM ${IMAGE_BASE}

LABEL org.opencontainers.image.source https://github.com/ai-dock/kohya_ss
LABEL org.opencontainers.image.description "Kohya's GUI docker images (unlikable6/docker_kohya_ss_gui) for use in GPU cloud and local environments. Includes AI-Dock base for authentication and improved user experience."
LABEL maintainer="Rob Ballantyne <rob@dynamedia.uk>"

# Build configuration
ARG PYTHON_VERSION="3.10"
ARG PYTORCH_VERSION="2.4.0"
ARG KOHYA_BUILD_REF=""

# Path configuration
ENV KOHYA_VENV=$VENV_DIR/kohya \
    KOHYA_VENV_PYTHON=$VENV_DIR/kohya/bin/python \
    KOHYA_VENV_PIP=$VENV_DIR/kohya/bin/pip \
    IMAGE_SLUG="kohya_ss" \
    OPT_SYNC=kohya_ss \
    PYTHON_VERSION="${PYTHON_VERSION}" \
    PYTORCH_VERSION="${PYTORCH_VERSION}" \
    KOHYA_BUILD_REF="${KOHYA_BUILD_REF}" \
    PYTHON_DEFAULT_VENV=kohya

# Prepare environment (Layer 0)
COPY --chown=0:1111 ./COPY_ROOT_0/ /
RUN set -eo pipefail && /opt/ai-dock/bin/build/layer0/init.sh | tee /var/log/build.log

# Install Kohya_ss (Layer 1)
COPY --chown=0:1111 ./COPY_ROOT_1/ /
RUN set -eo pipefail && /opt/ai-dock/bin/build/layer1/init.sh | tee -a /var/log/build.log

# Overrides and post-install (Layer 99)
COPY --chown=0:1111 ./COPY_ROOT_99/ /
#RUN set -eo pipefail && /opt/ai-dock/bin/build/layer99/init.sh | tee -a /var/log/build.log

# Keep init.sh as-is and place additional logic in /opt/ai-dock/bin/preflight.sh
CMD ["init.sh"]
