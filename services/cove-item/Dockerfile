# Stage 1 — Build
# Pure Go service (no CGo) — no libvips or other C libraries needed.
FROM golang:1.25-bookworm AS builder

WORKDIR /build

# Download dependencies first so this layer is cached between builds
# that only change source files.
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# COMMIT_SHA is injected by CI via --build-arg so the /health endpoint
# can report the exact Git commit that is running.
ARG COMMIT_SHA=dev

# CGO_ENABLED=0 — pure Go, no C dependencies.
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags "-X main.commitSHA=${COMMIT_SHA}" \
    -o cove-item \
    ./cmd/item/

# Stage 2 — Run
# gcr.io/distroless/static is suitable for pure Go binaries with no CGo.
# It is smaller and has a smaller attack surface than debian-slim.
FROM gcr.io/distroless/static-debian12

COPY --from=builder /build/cove-item /cove-item

EXPOSE 8080

ENTRYPOINT ["/cove-item"]
