FROM docker.io/squidfunk/mkdocs-material:8.5.8 as builder

ARG OVERLAY=techzone
ARG YQ_VERSION=v4.29.2
ARG YQ_BINARY=yq_linux_amd64

RUN apk add --no-cache --update nodejs npm
RUN wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O - |\
      tar xz && mv ${YQ_BINARY} /usr/bin/yq

WORKDIR /site
COPY . .

# Python Dependencies
RUN pip --no-cache-dir install git+https://github.com/linkchecker/linkchecker@v10.0.1#egg=linkchecker
# NodeJS Dependencies
RUN npm ci

RUN npm run build

FROM docker.io/bitnami/nginx:1.23.2

EXPOSE 8080 8443
COPY --from=builder /site/public /app
