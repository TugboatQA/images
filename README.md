# Tugboat Service Images

This repository contains the scripts used to generate the Docker images used by Tugboat Services. All of the images generated here extend the Dockerhub "Official Images"

## Service Definitions

Each image that is generated comes from a service definition directory in `/services`. The structure of this directory looks like

```
service
├── custom
├── files
│   ├── file1
│   └── file2
├── manifest
└── run
```

### custom

This file contains any custom Dockerfile information required for this image. Images are copied from the base image, so things like EXPOSE or ENV values are not carried over. So, any of those values that need to be in the resulting image need to be duplicated here.

### files

This directory is where files can be copied from into the resulting image.

### manifest

This is the primary image definition file. The following variables can be defined in this file.

* **NAME** - The name of the image to generate. If not defined, the directory name is used.
* **FROM** - The base image to build from. If not defined, the directory name is used.
* **PARSE** - An optional function to use to parse the library description for the image as provided at https://github.com/docker-library/official-images/tree/master/library. These are not standardized, so each image may need its own parser. If no parser is defined, pulling values from fields labeled `Tags:` and `SharedTags:` is used. The result of this parser should be a comma-space-separated list of tags & aliases, one line per unique image.
* **FILTER** - An optional filter to run against the parsed list of image tags. Usually this is used to exclude things like `rc` or `unstable` tags.

### run

This is the primary `runit` script used to start the service that the image is created for.