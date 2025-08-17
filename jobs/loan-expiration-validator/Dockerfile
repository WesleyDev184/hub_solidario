# Etapa de build
FROM golang:1.21-alpine AS builder

# Install git and ca-certificates (needed for git operations and https)
RUN apk add --no-cache git ca-certificates

WORKDIR /app

# Copy go mod files
COPY go.mod go.sum ./

# Download dependencies with timeout
RUN go mod download

# Copy source code
COPY . .

# Build with optimizations
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o levBin main.go

# Etapa final, apenas binário
FROM alpine:latest

# Install ca-certificates for HTTPS requests
RUN apk --no-cache add ca-certificates

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/levBin .

# Make binary executable
RUN chmod +x levBin

CMD ["./levBin"]