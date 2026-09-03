FROM nginx:alpine
ARG VERSION
ENV VERSION=${VERSION}
COPY html /usr/share/nginx/html
RUN sed -i "s/{{ .Version }}/${VERSION}/g" /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]