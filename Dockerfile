FROM squidfunk/mkdocs-material:9.5.34@sha256:a2e3a31c00cfe1dd2dae83ba21dbfa2c04aee2fa2414275c230c27b91a4eda09 AS build
COPY mkdocs.yml ./mkdocs.yml
COPY docs/ /docs/docs/
RUN pip install mkdocs-static-i18n[material] && pip3 install mkdocs-git-revision-date-localized-plugin && pip install mkdocs-table-reader-plugin
RUN mkdocs build

FROM caddy:2.8.4-alpine@sha256:b29f8188b594a5dc462553f5488b4f268294c622add2bfe0e775541bbe08130a

COPY --from=build /docs/public /srv

# Inline Caddy configuration
RUN { \
    echo ":80 {"; \
    echo "    root * /srv"; \
    echo "    file_server"; \
    echo "}"; \
} > /etc/caddy/Caddyfile

EXPOSE 80

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
