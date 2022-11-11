FROM squidfunk/mkdocs-material:8.5.8

ARG YQ_BINARY=yq_linux_amd64

RUN apk add --no-cache --update nodejs npm
RUN wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O - |\
      tar xz && mv ${YQ_BINARY} /usr/bin/yq

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
