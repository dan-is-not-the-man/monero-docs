FROM squidfunk/mkdocs-material:9.5.27
RUN mkdir /md
COPY mkdocs.yml /md/mkdocs.yml
COPY /docs /md/docs
WORKDIR /md/docs
RUN pip install mkdocs-static-i18n[material]
RUN pip install mike
RUN pip3 install mkdocs-git-revision-date-localized-plugin
