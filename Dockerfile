FROM node:20-alpine as builder

RUN apk add --update python3 make g++ curl
RUN npm install -g eslint
RUN npm install -g @nestjs/cli

WORKDIR /app

COPY package.json .
COPY package-lock.json .
RUN npm install

COPY . .
RUN npm ci --prod
RUN npx nest build

FROM node:20-alpine

WORKDIR /app

COPY --from=builder /app/package.json /app/package.json
COPY --from=builder /app/dist /app/dist
COPY --from=builder /app/node_modules /app/node_modules

USER node

EXPOSE 8080

ENTRYPOINT ["npm", "run", "start:prod"]