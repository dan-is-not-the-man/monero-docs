FROM squidfunk/mkdocs-material:9.5.27
COPY ./mkdocs.yml ./mkdocs.yml
COPY ./docs ./docs
RUN pip install mkdocs-static-i18n[material] && pip install mike && pip3 install mkdocs-git-revision-date-localized-plugin
RUN mkdocs build
