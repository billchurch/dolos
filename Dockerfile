FROM alpine:3.21
LABEL maintainer="Bill Church bill@f5.com"

# Add ncurses and terminal utilities for better TUI support
RUN apk --no-cache add \
    openssl \
    bash \
    uuidgen \
    libfaketime \
    coreutils \
    gum \
    ncurses \
    ncurses-terminfo-base \
    ncurses-terminfo

# Create non-root user and set up directories with correct permissions
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup && \
    chown -R appuser:appgroup /app && \
    chmod -R 755 /app

# Set working directory
WORKDIR /opt

# Switch to non-root user
USER appuser

EXPOSE 2560
