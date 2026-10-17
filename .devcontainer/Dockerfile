# Combined toolchain for working on every OpenCarControls repo at once:
# firmware (every board: PC/Raspberry Pi and all ESP targets) plus the mobile
# app (Flutter and Android SDK). The build context is the workspace root (see
# devcontainer.json).
#
# Keep in sync with firmware/.devcontainer/Dockerfile and
# mobile-app/.devcontainer/Dockerfile.
FROM mcr.microsoft.com/devcontainers/rust:2-1

ARG CMDLINE_TOOLS_VERSION="14742923"
ARG ANDROID_COMPILE_SDK="36"
ARG ANDROID_BUILD_TOOLS="36.0.0"

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends \
    protobuf-compiler \
    python3 python3-pip \
    libusb-1.0-0 libudev-dev pkg-config \
    usbip \
    curl git git-lfs unzip xz-utils zip libglu1-mesa openjdk-21-jdk \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN usermod -aG dialout vscode

USER vscode
WORKDIR /home/vscode

# ── Firmware ──────────────────────────────────────────────────────────────────
# Raspberry Pi cross-compile target (64-bit) and the ESP RISC-V targets.
RUN rustup target add aarch64-unknown-linux-gnu riscv32imc-unknown-none-elf riscv32imac-unknown-none-elf

# Espressif Cargo tools
RUN curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

RUN cargo binstall -y espup espflash

RUN cargo binstall -y probe-rs-tools

# Xtensa toolchain (`+esp`), used by xtask for ESP32/ESP32-S3 builds.
RUN espup install --export-file /home/vscode/export-esp.sh

RUN echo "source /home/vscode/export-esp.sh" >> ~/.bashrc

# ── Mobile app ────────────────────────────────────────────────────────────────
ENV ANDROID_HOME=/home/vscode/android-sdk
ENV FLUTTER_HOME=/home/vscode/flutter
ENV PATH="$PATH:$FLUTTER_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:/home/vscode/.pub-cache/bin"

# Install Android SDK Command Line Tools
RUN mkdir -p $ANDROID_HOME/cmdline-tools && \
    curl -sL https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VERSION}_latest.zip -o cmdline-tools.zip && \
    unzip -q cmdline-tools.zip -d $ANDROID_HOME/cmdline-tools && \
    rm -rf cmdline-tools.zip && \
    mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest

RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-${ANDROID_COMPILE_SDK}" "build-tools;${ANDROID_BUILD_TOOLS}"

# Install Flutter at the version the app pins
COPY mobile-app/.flutter-version /tmp/.flutter-version
RUN FLUTTER_VERSION=$(cat /tmp/.flutter-version) && \
    git clone https://github.com/flutter/flutter.git --depth 1 -b "$FLUTTER_VERSION" $FLUTTER_HOME && \
    flutter config --no-analytics && \
    flutter precache --android && \
    dart pub global activate protoc_plugin 21.1.2
