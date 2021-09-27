build:
	docker build -t test-agent .
run:
	docker run -it test-agent
debug:
	docker run --entrypoint=/bin/bash -it test-agent
