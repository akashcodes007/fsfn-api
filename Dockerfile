FROM node:23-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build
WORKDIR /app
COPY . /app

RUN corepack enable
RUN apk add --no-cache python3 alpine-sdk

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --prod --frozen-lockfile

FROM base AS api
WORKDIR /app

# Copy everything from /app, instead of /prod/api
COPY --from=build --chown=node:node /app /app

USER node
EXPOSE 9000
CMD [ "node", "src/cobalt" ]
