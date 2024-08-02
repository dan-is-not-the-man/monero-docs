FROM squidfunk/mkdocs-material:9.5.27 AS build
COPY mkdocs.yml ./mkdocs.yml
COPY docs/ /docs
RUN pip install mkdocs-static-i18n[material] && pip install mike && pip3 install mkdocs-git-revision-date-localized-plugin
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
