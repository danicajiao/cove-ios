# Stage 1 — Build
# govips requires CGo (libvips C bindings), so we use a Debian-based Go image
# and install the libvips development headers.
FROM golang:1.25-bookworm AS builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends libvips-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Download dependencies first so this layer is cached between builds
# that only change source files.
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# COMMIT_SHA is injected by CI via --build-arg so the /health endpoint
# can report the exact Git commit that is running.
ARG COMMIT_SHA=dev

# CGO_ENABLED=1 is required — govips links against the libvips C library.
RUN CGO_ENABLED=1 GOOS=linux go build \
    -ldflags "-X main.commitSHA=${COMMIT_SHA}" \
    -o cove-image \
    ./cmd/image/

# Stage 2 — Run
# debian:bookworm-slim + libvips42 (runtime only, no dev headers or compiler).
# The binary links against libvips at runtime so we must include the shared
# library — gcr.io/distroless/static is not suitable for CGo binaries.
FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends libvips42 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/cove-image /cove-image

EXPOSE 8080

ENTRYPOINT ["/cove-image"]
