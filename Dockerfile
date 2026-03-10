# syntax=docker/dockerfile:1.7

FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04 AS builder

ARG RUST_VERSION=1.88.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    build-essential \
    pkg-config \
    libglib2.0-dev \
    libgtk-3-dev \
    libsoup2.4-dev \
    libwebkit2gtk-4.0-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev \
    libxdo-dev \
    libssl-dev \
    clang \
    git \
    cmake \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --default-toolchain "${RUST_VERSION}" --profile minimal

ENV PATH="/root/.cargo/bin:${PATH}"
WORKDIR /src

RUN git clone --depth 1 https://github.com/edgenai/edgen.git .
RUN cargo build --release -p edgen --features no_gui,llama_cuda,whisper_cuda

FROM nvidia/cuda:12.4.1-cudnn-runtime-ubuntu22.04 AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home app \
    && mkdir -p /config /models /home/app \
    && chown -R app:app /config /models /home/app

COPY --from=builder /src/target/release/edgen /usr/local/bin/edgen

USER app
WORKDIR /home/app

EXPOSE 33322

ENTRYPOINT ["/usr/local/bin/edgen"]
CMD ["serve", "-g", "-b", "http://0.0.0.0:33322"]
