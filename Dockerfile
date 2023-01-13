FROM alpine:3.17
LABEL maintainer="Bill Church bill@f5.com"
RUN apk --update add openssl bash uuidgen
RUN apk add libfaketime --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/
# COPY create_ca.sh create_ca.sh
# COPY create_client.sh create_client
# COPY revoke_client.sh revoke_client
# COPY get_chain.sh get_chain
# COPY get_cert.sh get_cert
# COPY root-openssl.conf /root/ca/openssl.cnf
# COPY intermediate-openssl.conf /root/ca/intermediate/openssl.cnf
# RUN chmod +x create_ca.sh && \
#     chmod +x create_client && \
#     chmod +x revoke_client && \
#     chmod +x get_chain && \
#     chmod +x get_cert
# RUN ./create_ca.sh
# COPY docker-entrypoint.sh docker-entrypoint.sh
EXPOSE 2560
# ENTRYPOINT [ "/bin/sh", "docker-entrypoint.sh" ]