# Tugboat Service Images

This repository contains the scripts used to generate the Docker images used by
[Tugboat](https://tugboat.qa) Services. All of the images generated here extend the Dockerhub
"Official Images"

## Service Definitions

Each image that is generated comes from a service definition directory in
`/services`. The structure of this directory looks like

```
service
├── Dockerfile
├── files
│   ├── file1
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

### run

This is the primary `runit` script used to start the service that the image is
created for.
