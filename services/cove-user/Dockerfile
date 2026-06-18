# Stage 1 — Build
# Pure Go service (no CGo). The build context is services/cove-user so
# only the service itself needs to be available.
FROM golang:1.25-bookworm AS builder

WORKDIR /build

# Module files first, so the dependency-download layer caches
# independently of service source changes.
COPY go.mod go.sum ./
RUN go mod download

# Service source.
COPY . ./

# COMMIT_SHA is injected by CI via --build-arg so /health reports the running commit.
ARG COMMIT_SHA=dev

# CGO_ENABLED=0 — pure Go, no C dependencies.
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags "-X main.commitSHA=${COMMIT_SHA}" \
    -o /build/cove-user \
    ./cmd/user/

# Stage 2 — Run
# gcr.io/distroless/static is suitable for pure Go binaries with no CGo.
# Smaller and lower attack surface than debian-slim.
FROM gcr.io/distroless/static-debian12

COPY --from=builder /build/cove-user /cove-user

EXPOSE 8080

ENTRYPOINT ["/cove-user"]
