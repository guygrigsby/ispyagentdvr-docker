version= $(shell cat ./version.txt)
image=guygrigsby/ispyagent

build: inc
	docker build -t ${image}:${version} .
up: gen pvc
	kubectl apply -f ./deployment.yaml
pvc:
	kubectl apply -f ./pvc.yaml
gen:
	go run main.go
run:
	docker run -it ${image}:${version}
debug:
	docker run --entrypoint=/bin/bash -it ${image}:${version}
inc:
	./bump.sh
