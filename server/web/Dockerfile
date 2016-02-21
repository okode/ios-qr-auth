# iOS QR Auth - Server - Web container

FROM node:latest

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY resources /usr/src/app/
RUN npm install

EXPOSE 3001 3002

CMD [ "npm", "start" ]
