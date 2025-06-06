image := named  regd
buildhost := localhost
level := ingress

init:
	for b in $(image); do podman build $${b} -t $(buildhost)/$(level)/$${b} --squash-all; ret=$$?; (( ! $${ret} )) || exit 1; done

build: clean
	for b in $(image); do podman build $${b} -t $(buildhost)/$(level)/$${b} --squash-all; done

push:
	for b in $(image); do podman push $(buildhost)/$(level)/$${b}; done

clean:
	for b in $(image); do podman rmi -f $(buildhost)/$(level)/$${b}; done

