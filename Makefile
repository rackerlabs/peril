PWD=$(shell pwd)
VOLUMES=\
	--volume=$(PWD)/peril.yml:/usr/src/app/peril.yml \
	--volume=$(PWD)/notifications.rb:/usr/src/app/notifications.rb \
	--volume=$(PWD)/slurpers.rb:/usr/src/app/slurpers.rb \
	--volume=$(PWD)/unicorn.rb:/usr/src/app/unicorn.rb \

.PHONY: build-image

build-image:
	docker build -t peril-core .

run-setup: build-image
	docker run --rm peril-core bin/peril-setup

run-poll: build-image
	docker run --detach=true \
		--name="peril-poll" \
		$(VOLUMES) \
		peril-core bin/peril-poll

run-web: build-image
	docker run --detach=true \
		--name="peril-web" --expose=8080 --publish=8080:8080 \
		$(VOLUMES) \
		peril-core bin/peril-web

run: build-image run-poll run-web

stop:
	docker stop peril-poll
	docker stop peril-web
	docker rm peril-poll
	docker rm peril-web
