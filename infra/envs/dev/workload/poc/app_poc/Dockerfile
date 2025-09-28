# Build stage
FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY app/go.mod ./
COPY app/main.go ./
RUN go build -o /out/app

# Runtime stage
FROM alpine:3.20
WORKDIR /app
RUN addgroup -S app && adduser -S -g app app
COPY --from=builder /out/app /usr/local/bin/app
USER app
EXPOSE 8080
ENV PORT=8080
CMD ["app"]
