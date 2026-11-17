# Image de l'API ShopLab
FROM node:22-alpine

WORKDIR /app

# Les dependances sont installees avant la copie du code
# pour profiter du cache des couches Docker.
COPY package.json ./
RUN npm install --omit=dev

COPY server.js ./
COPY public ./public

EXPOSE 3000
CMD ["node", "server.js"]
