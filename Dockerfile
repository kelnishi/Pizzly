# This is the Dockerfile for building a production image with Pizzly


# Build image 
FROM node:15.11.0-alpine3.13

RUN apk update
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing direnv
RUN apk add bash

WORKDIR /app

# Copy in dependencies for building
COPY *.json ./
COPY yarn.lock ./
#COPY config ./config
COPY integrations ./integrations/
COPY src ./src/
COPY tests ./tests/
COPY views ./views/
COPY .envrc ./

RUN yarn install 

#SHELL ["/bin/bash", "-c"]
#RUN eval "$(direnv hook bash)"
#RUN direnv allow .envrc

# Actual image to run from.
FROM node:15.11.0-alpine3.13

RUN apk update

# Make sure we have ca certs for TLS
RUN apk --no-cache add ca-certificates

RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing direnv
RUN apk add bash
RUN apk add curl

# Make a directory for the node user. Not running Pizzly as root.
RUN mkdir /home/node/app && chown -R node:node /home/node/app
WORKDIR /home/node/app

USER node

COPY --chown=node:node --from=0 /app/dist/ .
COPY --chown=node:node --from=0 /app/views ./views
COPY --chown=node:node --from=0 /app/node_modules ./node_modules

COPY --chown=node:node --from=0 /app/.envrc ./

CMD ["node", "src"]
