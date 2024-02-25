FROM public.ecr.aws/lambda/nodejs:16

COPY dist/index.js dist/package.json /var/task/
COPY prisma/. /var/task/
COPY .env /var/task/
RUN npm install
RUN npx prisma generate

CMD ["index.handler"]