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

#build docker image
FROM ubuntu:22.10
COPY --from=golang /usr/src/app/pocketnuxt /pocketnuxt
COPY pb_data/ /pb_data/
CMD ["/pocketnuxt", "serve", "--http", "0.0.0.0:8090", "--encryptionEnv", "PB_ENCRYPTION"]