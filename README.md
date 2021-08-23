# Diaspora*

![Diaspora Logo](https://i.imgur.com/J50tnoC.png)

[Diaspora](https://diasporafoundation.org/) is a nonprofit, user-owned, distributed social network that is based upon the free Diaspora software. Diaspora consists of a group of independently owned nodes (called pods) which interoperate to form the network.

 **Automated build of the image can be found on the [Docker Hub](https://hub.docker.com/repository/docker/dsterry/diaspora).**

 **Forked from [nikkoura/docker-diaspora](https://github.com/nikkoura/docker-diaspora)**

## Features

- Based on the official [ruby:2.6-slim-stretch](https://hub.docker.com/_/ruby/) image
- Running the latest version of [C4Social/diaspora](https://github.com/c4social/diaspora)
- Run as an unprivileged user (see `UID` and `GID`)
- Use of environment variables to set various configuration elements, for easier integration with other containers without modifying configuration files

### Build-time variables

- **`GID`**: group id *(default: `942`)*
- **`UID`**: user id *(default: `942`)*

### Volumes

- **`/diaspora/public`**: location of the assets and user uploads

## Usage

### Run-time environment variables

#### Base settings
See comments in `config/diaspora.yml` for the possible environment variables.
Here are the critical ones to integrate with the container environment:
- **`ENVIRONMENT_URL`**: diaspora public URL. Do not modify once db has been populated (optional, default= `http://localhost`)
- **`SERVER_LISTEN`**: Diaspora 'unicorn' server listener (default= `0.0.0.0:3000`)

#### REDIS Access
REDIS access can be specified in two ways:
- By providing a complete connection URL, optionally including user/password :
-- **`ENVIRONMENT_REDIS`**: REDIS url,  (default= `redis://redis`)
- By providing separate connection elements:
-- **`REDIS_HOST`**: REDIS server,  (default= `redis`)
-- **`REDIS_USER`**: REDIS connection user,  (optional, default empty)
-- **`REDIS_PASSWORD`**: REDIS connection password,  (optional, default empty)

#### Database access
Database configuration is templated using [confd](http://www.confd.io).
Template and associated settings are available in this repository under `/config` and under /etc/confd in the container image.
The following environment variables should be used depending on the db you are using:

##### PostgreSQL
- **`DB_TYPE`**: database type. Set to `postgresql` (mandatory)
- **`DB_HOST`**: db server host (optional, default= `postgres`)
- **`DB_PORT`**: db server port (optional, default= `5432`)
- **`DB_USER`**: db server user (optional, default= empty)
- **`DB_PASSWORD`**: db server password (optional, default= empty)

##### MySQL
- **`DB_TYPE`**: database type. Set to `mysql` (mandatory)
- **`DB_HOST`**: db server host (optional, default= `mysql`)
- **`DB_PORT`**: db server port (optional, default= `3306`)
- **`DB_USER`**: db server user (optional, default= empty)
- **`DB_PASSWORD`**: db server password (optional, default= empty)

### Docker Compose

A sample Docker Compose file is provided. It instanciates standalones instances of PostreSQL and REDIS,
and a NGinx web server to serve static elements (assets and user uploads).
It can be used for a basic deployment, with minor modifications to environment variables.

We need a Nginx container to server the uploads and assets, as Unicorn doesn't do it.

### Installation

When running the instance for the first time, run this command to initialize the postgres instance:

```sh
docker-compose up -d postgres
```

Allow a few minutes for the instance to initialize and settle, then create the schema:

```sh
docker-compose run --rm unicorn initdb
```

Make the data dir and set permissions

```sh
mkdir data
sudo chown -R 942:942 data
```

Then compile the assets:

```sh
docker-compose run --rm unicorn precompile-assets
```

You can now lauch your pod!

```sh
docker-compose up -d
```

You can check your Diaspora installation on the http://localhost with no modification on the configuration files. To set the administrator account follow the [Official FAQ instructions](https://wiki.diasporafoundation.org/FAQ_for_pod_maintainers#What_are_roles_and_how_do_I_use_them.3F_.2F_Make_yourself_an_admin_or_assign_moderators) after creating an account on the site.
