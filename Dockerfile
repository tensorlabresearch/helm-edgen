# syntax=docker/dockerfile:1.7

FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04 AS builder

ARG RUST_VERSION=1.88.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    build-essential \
    pkg-config \
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
RUN cat > /src/crates/edgen_server/src/bin/edgen.rs <<'EOF'
use once_cell::sync::Lazy;
use edgen_server::{cli, start, EdgenResult};

fn main() -> EdgenResult {
    Lazy::force(&cli::PARSED_COMMANDS);
    start(&cli::PARSED_COMMANDS)
}
EOF

RUN cargo build --manifest-path /src/Cargo.toml --release \
    -p edgen_server --bin edgen --features llama_cuda,whisper_cuda --locked

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
