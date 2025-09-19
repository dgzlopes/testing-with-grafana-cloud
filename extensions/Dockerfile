# Stage 1: build k6 with local xk6-judge extension
FROM golang:1.25 AS builder

# Install xk6
ENV PATH="/go/bin:${PATH}"
RUN go install go.k6.io/xk6/cmd/xk6@latest

# Copy our local extensions
COPY xk6-judge ./xk6-judge

# Build custom k6 binary including the local extensions
RUN /go/bin/xk6 build \
    --with xk6-judge=./xk6-judge \
    --output /k6

# Stage 2: minimal runtime image
FROM grafana/k6:latest

COPY --from=builder /k6 /usr/bin/k6

ENTRYPOINT ["k6"]
