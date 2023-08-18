# Tugboat Service Images

This repository contains the scripts used to generate the Docker images used by
[Tugboat](https://tugboat.qa) Services. All of the images generated here extend
the Dockerhub "Official Images".

## Service Definitions

Each image that is generated comes from a service definition directory in
`/services`. The structure of this directory looks like

```
service
├── Dockerfile
├── files
│   ├── file1
│   └── file2
├── manifest
└── run
```

### Adding a new service

To add a new service, add the directory and any necessary files. Typically the
bare minimum is a manifest or Dockerfile. Before adding these files, [create a
new repository](https://cloud.docker.com/u/tugboatqa/repository/create) on
Docker hub, and give the `write` team write permissions to it.

### Dockerfile

This file contains any custom Dockerfile information required for this image.
Images are copied from the base image, so things like EXPOSE or ENV values are
not carried over. So, any of those values that need to be in the resulting image
need to be duplicated here.

### files

This directory is where files can be copied from into the resulting image.

### manifest

This is the primary image definition file. The following variables can be
defined in this file.

* **NAME** - The name of the image to generate. If not defined, the directory name is used.
* **FROM** - The base image to build from. If not defined, the directory name is used.
* **SERVICE** - The name of the service tied to the `run` script (below)
* **GETTAGS** - An optional function to generate a list of tags for the image. Most image definitions can be parsed automatically from the dockerhub image definition, but there are some cases that need a little help. The resulting list should be comma-separated, with no spaces, one line per unique image.
* **FILTER** - An optional filter to run against the parsed list of image tags. Usually this is used to exclude things like `rc` or `unstable` tags. This is used by the default GETTAGS function, and must be explicitly built in to a custom GETTAGS function in order to have any effect there.
* **TEMPLATE** - Which Dockerfile template to use. Valid options: apk, apt, yum, none. Default: apt
* **PLATFORMS** - A comma-separated list of platforms to build images for. Default: linux/amd64

### run

This is the primary `runit` script used to start the service that the image is
created for.

## Building images locally

If you would like to build images locally, there are a few things to know before
you get started.

### System requirements

You will need the following utilities:

- Docker
- [Task](https://taskfile.dev/) version 3.28.0 or greater
- [GNU Parallel](https://www.gnu.org/software/parallel/)
- [jq](https://jqlang.github.io/jq/)

### Environment variables.

Please see the `.env` that exists in this repository. If you would like to
override values in the `.env`, you may do so in a `.env.local`.

### To run

- `task --list`: to list all tasks.
- `task --summary`: to see help.
- `task`: build all images.
- `PUSH=1 task`: builds and push all images. (You may also set `PUSH=1` in your .env.local.)
- `task -- chicken duck`: builds just the `chicken` and `duck` service, if there were such things.
- `task clean`: to clean the files on disk (without losing your local cache in the docker builder.)
- `task clean-all`: to remove all files on disk and the docker builder.

### S3 Layer cache

To speed up frequent builds on your environment, you can use an
[S3 layer cache](https://docs.docker.com/build/cache/backends/s3/).
See the `.env` for the `AWS_*` environment variables necessary for this.
