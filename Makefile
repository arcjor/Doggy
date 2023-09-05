GIT_HASH ?= $(shell git log --format="%h" -n 1)

build:
	docker build -t doggy\:${GIT_HASH} .

run:
	docker run --rm -p 8080\:80 doggy\:${GIT_HASH}
