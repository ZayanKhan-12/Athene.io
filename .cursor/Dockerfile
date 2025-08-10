# Base environment for Cursor background agents
# - Do NOT copy project code here (agents will clone code separately)
# - Include general development tools needed by agents
# - Use a non-root user and set WORKDIR to the home directory

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install common developer tooling
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    git-lfs \
    unzip \
    zip \
    tar \
    build-essential \
    pkg-config \
    cmake \
    python3 \
    python3-pip \
    jq \
    ripgrep \
    fzf \
    openssh-client \
    sudo \
    locales \
    tzdata \
  && rm -rf /var/lib/apt/lists/* \
  && git lfs install --system

# Configure UTF-8 locale
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Create non-root user and set home as WORKDIR
ARG USERNAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME

# Intentionally no COPY or RUN that assumes repository files exist.

