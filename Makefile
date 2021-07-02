IMAGE ?= iamjameshunt/gemprox
TAG   ?= latest

build:
	docker build \
	  --build-arg BUILD_DATE="$(shell date -u --iso-8601)" \
	  --build-arg VCS_REF="$(shell git rev-parse --short HEAD)" \
	  . -t $(IMAGE):$(TAG)

push: build
	docker push $(IMAGE):$(TAG)

run:
	carton exec plackup -p 6001 ./bin/app.psgi
