# Tugboat Service Images

This repository contains the scripts used to generate the Docker images used by Tugboat Services. All of the images generated here extend the Dockerhub "Official Images"

## Service Definitions

Each image that is generated comes from a service definition directory in `/services`. The structure of this directory looks like

```
service
├── Dockerfile
├── files
│   ├── file1
│   └── file2
├── manifest
├── README.md
└── run
```

### Dockerfile

This file contains any custom Dockerfile information required for this image. Images are copied from the base image, so things like EXPOSE or ENV values are not carried over. So, any of those values that need to be in the resulting image need to be duplicated here.

### files

This directory is where files can be copied from into the resulting image.

### manifest

This is the primary image definition file. The following variables can be defined in this file.

* **NAME** - The name of the image to generate. If not defined, the directory name is used.
* **FROM** - The base image to build from. If not defined, the directory name is used.
* **SERVICE** - The name of the service tied to the `run` script (below)
* **GETTAGS** - An optional function to generate a list of tags for the image. Most image definitions can be parsed automatically from the dockerhub image definition, but there are some cases that need a little help. The resulting list should be comma-separated, with no spaces, one line per unique image.
* **FILTER** - An optional filter to run against the parsed list of image tags. Usually this is used to exclude things like `rc` or `unstable` tags. This is used by the default GETTAGS function, and must be explicitly built in to a custom GETTAGS function in order to have any effect there.
* **PACKAGES** - Which package manager is used by the base image. Valid options: apt, yum. Default: apt

### README.md

The build scripts automatically generate a README.md file with a list of currently supported tags. If this file exists in the service definition directory, it is appended to the end of that automatically generated README.md.

### run

This is the primary `runit` script used to start the service that the image is created for.