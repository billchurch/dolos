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

EXPOSE 2560
