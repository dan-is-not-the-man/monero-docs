FROM squidfunk/mkdocs-material:9.5.27@sha256:9919d6ee948705ce6cd05e5bc0848af47de4f037afd7c3b91e776e7b119618a4 AS build
COPY mkdocs.yml ./mkdocs.yml
COPY docs/ /docs/docs/
RUN pip install mkdocs-static-i18n[material] && pip3 install mkdocs-git-revision-date-localized-plugin && pip install mkdocs-table-reader-plugin
RUN mkdocs build

FROM caddy:alpine

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
