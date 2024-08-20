FROM squidfunk/mkdocs-material:9.5.32@sha256:a73e4bbbccb09e5374cef28ebe68511c166222274f8486b25ad467ec1f5e8bbe AS build
COPY mkdocs.yml ./mkdocs.yml
COPY docs/ /docs/docs/
RUN pip install mkdocs-static-i18n[material] && pip3 install mkdocs-git-revision-date-localized-plugin && pip install mkdocs-table-reader-plugin
RUN mkdocs build

FROM nginx:alpine

COPY --from=build /docs/public /usr/share/nginx/html

# Inline Nginx configuration
RUN echo 'server { \
    listen 80; \
    root /usr/share/nginx/html; \
    index index.html index.htm; \
    error_page 404 /404.html; \
    location = /404.html { \
        internal; \
    } \
    location / { \
        try_files $uri $uri/ =404; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
