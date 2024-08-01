FROM squidfunk/mkdocs-material:9.5.27
RUN ls -l
COPY ./mkdocs.yml /mkdocs.yml
WORKDIR docs
RUN pip install mkdocs-static-i18n[material]
RUN pip install mike
RUN pip3 install mkdocs-git-revision-date-localized-plugin
RUN mkdocs build
