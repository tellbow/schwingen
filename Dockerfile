# generate static files
FROM node:21.6 AS node
WORKDIR /app
ENV YARN_VERSION 4.1.0
RUN yarn policies set-version $YARN_VERSION
COPY package.json ./
COPY yarn.lock ./
COPY .yarnrc.yml ./
#COPY .yarn/releases/yarn-4.1.0.cjs ./
RUN yarn install
COPY . .
RUN yarn generate

# build go binary
FROM golang:1.21 AS golang
WORKDIR /usr/src/app
COPY . .
COPY --from=node /app/pocketbase/.output /usr/src/app/pocketbase/.output
RUN go build -o pocketnuxt pocketbase/main.go

# download database
FROM curlimages/curl:latest AS downloader
RUN curl -L -o data.db https://github.com/tellbow/schwingen/releases/latest/download/data.db

#build docker image
FROM ubuntu:22.10
ENV NODE_ENV production
COPY --from=golang /usr/src/app/pocketnuxt /pocketnuxt
COPY --from=downloader /home/curl_user/data.db /pb_data/
CMD ["/pocketnuxt", "serve", "--http", "0.0.0.0:8090", "--encryptionEnv", "PB_ENCRYPTION"]