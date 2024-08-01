FROM squidfunk/mkdocs-material:9.5.27
RUN pip install mkdocs-static-i18n[material]
RUN pip install mike
RUN pip3 install mkdocs-git-revision-date-localized-plugin
WORKDIR /docs
COPY mkdocs.yml /
