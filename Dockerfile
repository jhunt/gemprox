FROM perl:5.32
WORKDIR /app
RUN cpanm Carton
COPY cpanfile .
COPY cpanfile.snapshot .
RUN carton install

COPY . .
CMD ["carton", "exec", "plackup", "/app/bin/app.psgi"]

ARG BUILD_DATE
ARG VCS_REF
