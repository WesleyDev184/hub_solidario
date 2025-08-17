# Etapa de build
FROM golang:alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o levBin main.go

# Etapa final, apenas binário
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/levBin .
CMD ["./levBin"]