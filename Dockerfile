FROM hugomods/hugo:exts-0.140.1 AS builder
WORKDIR /src
COPY . .
RUN hugo --gc --minify --baseURL "http://blog.gmoney.sh"

FROM nginx:alpine
COPY --from=builder /src/public /usr/share/nginx/html
EXPOSE 80
