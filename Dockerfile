# Stage 1: install dependencies
FROM node:alpine AS deps

ENV NEXT_TELEMETRY_DISABLED=1

WORKDIR /app/
COPY package*.json .
ARG NODE_ENV
ENV NODE_ENV $NODE_ENV
RUN npm install

# Stage 2: build
FROM node:alpine AS builder

ENV NEXT_TELEMETRY_DISABLED=1

WORKDIR /app/
COPY --from=deps /app/node_modules ./node_modules
COPY src ./src
COPY public ./public
COPY package.json next.config.js jsconfig.json ./
RUN npm run build

# Stage 3: run
FROM node:alpine

ENV NEXT_TELEMETRY_DISABLED=1

WORKDIR /app/
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./
CMD ["npm", "run", "start"]
