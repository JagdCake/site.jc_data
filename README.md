<h1 align="center">JC Data</h1>

### In short:
- I'm using data from my website [“I watched a Movie!”](https://movies.jagdcake.com/)
- the data is stored in a PostgreSQL database (dump available [here](https://github.com/JagdCake/site.movies/blob/master/database_dump.movies.tar.xz)); most of the data processing functions are in the [repository](./src/Repository/MovieRepository.php) file 
- the information is visualized on a static website — [“JC Data”](https://data.jagdcake.com), generated using Symfony 4

## First Time Setup
#### Symfony 4
- make sure you have PHP (7.1.3+) installed
- download [composer](https://getcomposer.org/download/) and [install](https://getcomposer.org/doc/00-intro.md#globally) it globally
- run `composer install` 

#### Database
- make sure you have PostgreSQL (version 10) installed and running
- open [.env](./.env) and edit `DATABASE_URL="db_driver://db_user:db_password@db_host:db_port/db_name"`, to e.g. `postgres://jagdcake:password@127.0.0.1:5432/movies`
- download the movie data [database dump](https://github.com/JagdCake/site.movies/blob/master/database_dump.movies.tar.xz)
- extract it `tar -xavf database_dump.movies.tar.xz`
- import the database dump using `psql -U db_user -d db_name -1 -f movies_dump`

## Development
- start the development server with `bin/console server:run` or `php bin/console server:run`
- generate a static page by going to `localhost:8000/generate`
- go through the build process by following the steps outlined in [build_static_site.sh](./build_static_site.sh)
  - can't run the script itself without [this](https://github.com/JagdCake/bash.scripts/blob/master/scripts/build_web_project.sh) script which is just a wrapper around commands used to minify / optimize website assets
