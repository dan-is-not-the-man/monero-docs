FROM squidfunk/mkdocs-material:9.5.34@sha256:a2e3a31c00cfe1dd2dae83ba21dbfa2c04aee2fa2414275c230c27b91a4eda09  AS build
COPY mkdocs.yml ./mkdocs.yml
COPY docs/ /docs/docs/
RUN pip install mkdocs-static-i18n[material] && pip3 install mkdocs-git-revision-date-localized-plugin && pip install mkdocs-table-reader-plugin
RUN mkdocs build

FROM caddy:2.8.4-alpine@sha256:b29f8188b594a5dc462553f5488b4f268294c622add2bfe0e775541bbe08130a

COPY --from=build /docs/public /srv

# Inline Caddy configuration
RUN { \
    echo "(common) {"; \
    echo "    header {"; \
    echo "        Strict-Transport-Security \"max-age=63072000; includeSubDomains\""; \
    echo "        X-Xss-Protection \"0\""; \
    echo "        X-Content-Type-Options \"nosniff\""; \
    echo "        X-Frame-Options \"SAMEORIGIN\""; \
    echo "        Permissions-Policy \"autoplay=(self),camera=(),geolocation=(),microphone=(),payment=(),usb=()\""; \
    echo "        Content-Security-Policy \"upgrade-insecure-requests\""; \
    echo "        Referrer-Policy \"strict-origin-when-cross-origin\""; \
    echo "        Cache-Control \"public, max-age=15, must-revalidate\""; \
    echo "        Feature-Policy \"accelerometer 'none'; ambient-light-sensor 'none'; autoplay 'self'; camera 'none'; encrypted\""; \
    echo "        Set-Cookie (.*) \"$1; SameSite=None; Secure\""; \
    echo "        Server \"No.\""; \
    echo "        X-Powered-By MutantMonkeys"; \
    echo "        defer"; \
    echo "    }"; \
    echo "}"; \
    echo ":80 {"; \
    echo "    import common"; \
    echo "    root * /srv"; \
    echo "    handle_errors {"; \
    echo "        rewrite * /404.html"; \
    echo "    file_server"; \
    echo "    }"; \
    echo "    try_files {path} {path}/ /404.html"; \
    echo "    file_server"; \
    echo "}"; \
} > /etc/caddy/Caddyfile

# Format Caddyfile
RUN caddy fmt --overwrite /etc/caddy/Caddyfile

EXPOSE 80

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
