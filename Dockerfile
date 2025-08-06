# Stage 1: Build the application
# We use a Go-specific image to compile the source code.
FROM golang:1.20-alpine AS builder

# Set the working directory inside the container.
WORKDIR /app

# Copy the Go module files to download dependencies.
COPY go.mod .
COPY go.sum .

# Download dependencies. This is cached for faster future builds.
RUN go mod download

# Copy the rest of the source code.
COPY . .

# Build the application and save the executable as 'server'.
RUN go build -o server cmd/main.go

# Stage 2: Create a clean final image
# We use a minimal Alpine Linux image to keep the final container small and secure.
FROM alpine:latest

# Set the working directory inside the final container.
WORKDIR /root/

# Copy only the compiled 'server' binary from the 'builder' stage.
COPY --from=builder /app/server .

# Expose the port that the application listens on.
EXPOSE 8080

# Set the command to run the executable when the container starts.
CMD ["./server"]