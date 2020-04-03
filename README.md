<h1 align="center">JC Data</h1>

### In short:
- I'm using data from my website [“I watched a
  Movie!”](https://movies.jagdcake.com/)
- the data is stored in a PostgreSQL database; most of the data
  processing functions are in the
  [repository](./src/Repository/MovieRepository.php) file
- the information is visualized on a static website — [“JC
  Data”](https://data.jagdcake.com), generated using Symfony 4

## First Time Setup
#### Symfony 4
- make sure you have PHP (7.1.3+) installed
- download [composer](https://getcomposer.org/download/) and
  [install](https://getcomposer.org/doc/00-intro.md#globally) it
  globally
- run `composer install`

#### Database
- make sure you have PostgreSQL (version 10) installed and running
- open [.env](./.env) and edit `DATABASE_URL="[DATABASE
  DRIVER]://[DATABASE USER]:[DATABASE PASSWORD]@[DATABASE
  HOST]:[DATABASE PORT]/[DATABASE NAME]"`, to e.g.
  `postgres://jagdcake:password@127.0.0.1:5432/movies`
- download movie data [database
  dump](https://github.com/JagdCake/i-watched-a-movie/releases)
- create a database for the data `psql -d [DATABASE USER] -c "create
  database [DATABASE NAME]"`
- extract database dump `tar -xavf database_dump.movies.tar.xz`
- import the dump `psql -U [DATABASE USER] -d [DATABASE NAME] <
  movies_dump`

## Development
- start the development server with `bin/console server:run` or `php
  bin/console server:run`
- make your changes and inspect them on the server
- to generate and build the static site — `make` from the root dir
    - make sure to install the tools (can be found in the Makefile) used
      to minify / optimize website assets

## Testing
- first update the `DATABASE_URL` for the test environment in
  [.env.test](./.env.test)
- to set up the test environment — `cd tests/` and `make`
- run `bin/phpunit` or `bin/phpunit --testdox` (displays an overview of
  the test cases)
    - to run specific tests `bin/phpunit tests/SomeTestFile.php`,
      `bin/phpunit tests/SomeTestDirectory/` or `bin/phpunit --filter
      {someTestMethodName}`
