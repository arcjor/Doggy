GIT_HASH ?= $(shell git log --format="%h" -n 1)

build:
	docker build -t doggy\:${GIT_HASH} .

run:
	docker run --rm --network=doggy_postgres -p 8080\:80 doggy\:${GIT_HASH}

upload:
	/azhelpers/upload_to_acr.sh

deploy:
	/azhelpers/run_in_aca.sh
