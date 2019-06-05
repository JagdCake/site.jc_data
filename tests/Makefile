export APP_ENV = test

.PHONY: all

.PHONY: create-test-db
.PHONY: execute-migrations
.PHONY: load-data-fixture

php.console = ../bin/console

all: create-test-db execute-migrations load-data-fixture

create-test-db:
	@echo Make sure you\'ve updated "DATABASE_URL" inside ../.env.test
	@echo Press enter to confirm
	@read
	$(php.console) doctrine:database:create

execute-migrations:
	$(php.console) doctrine:migrations:migrate

load-data-fixture:
	$(php.console) doctrine:fixtures:load
