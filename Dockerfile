# generate static files
FROM node:19.8 AS node
WORKDIR /app
COPY package.json ./
RUN yarn install
COPY . .
RUN yarn generate

# build go binary
FROM golang:1.20 AS golang
WORKDIR /usr/src/app
COPY . .
COPY --from=node /app/pocketbase/.output /usr/src/app/pocketbase/.output
RUN go build -o pocketnuxt pocketbase/main.go

#build docker image
FROM ubuntu:22.10
COPY --from=golang /usr/src/app/pocketnuxt /pocketnuxt
CMD ["/pocketnuxt", "serve", "--http", "0.0.0.0:8090"]