FROM node:latest
ARG NPM_TOKEN
ENV NPM_TOKEN=$NPM_TOKEN DATABASE_URL=postgres://app:app@db:5432/app
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
EXPOSE 3000
CMD npm start
