# Помогла инструкция - https://docs.docker.com/guides/golang/build-images/ 

# Stage 1: Build the backend
FROM golang:1.20 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o api ./cmd/api


# Stage 2: Run backend
FROM gcr.io/distroless/base
WORKDIR /app
COPY --from=builder /app/api .

EXPOSE 8081

CMD ["./api"]
