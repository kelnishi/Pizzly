# This is the Dockerfile for building a production image with Pizzly


# Build image 
FROM node:15.11.0-alpine3.13 AS base

RUN apk update
RUN apk add bash
RUN apk add postgresql-client

WORKDIR /app

# Copy in dependencies for building
COPY *.json ./
COPY yarn.lock ./
COPY integrations ./integrations/
COPY src ./src/
COPY tests ./tests/
COPY views ./views/
COPY wait-init.sh ./

RUN yarn install 

# Need this to run the wait-init first go, should really be in yarn?
RUN npm install knex -g


# Actual image to run from.
FROM base AS deployment

# Make sure we have ca certs for TLS
RUN apk --no-cache add ca-certificates

# Make a directory for the node user. Not running Pizzly as root.
RUN mkdir /home/node/app && chown -R node:node /home/node/app
WORKDIR /home/node/app

USER node

COPY --chown=node:node --from=base /app/dist/ .
COPY --chown=node:node --from=base /app/views ./views
COPY --chown=node:node --from=base /app/node_modules ./node_modules
COPY --chown=node:node --from=base /app/wait-init.sh ./

RUN chmod +x wait-init.sh

CMD ["node", "src"]
