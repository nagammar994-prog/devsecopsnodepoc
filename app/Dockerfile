FROM public.ecr.aws/docker/library/node:22-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install 

COPY . .

RUN addgroup -S appgroup \
 && adduser -S appuser -G appgroup

USER appuser

EXPOSE 3000

CMD ["node","server.js"]
