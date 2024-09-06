FROM squidfunk/mkdocs-material:9.5.33@sha256:7132ca3957c1fc325443579356fcc68696cd1aa54c715ce61228ea5e0b2d427a AS build
COPY mkdocs.yml ./mkdocs.yml
COPY docs/ /docs/docs/
RUN pip install mkdocs-static-i18n[material] && pip3 install mkdocs-git-revision-date-localized-plugin && pip install mkdocs-table-reader-plugin && && pip install mkdocs-htmlproofer-plugin
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
