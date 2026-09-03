FROM node:24-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY tsconfig.json ./
COPY src ./src
COPY sql ./sql
RUN npm run build

FROM node:24-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY --from=build /app/dist ./dist
COPY sql ./sql
RUN chmod +x dist/cli.js && ln -sf /app/dist/cli.js /usr/local/bin/fw
USER node
EXPOSE 3000
CMD ["node", "dist/server.js"]
