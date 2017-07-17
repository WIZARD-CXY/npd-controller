GOFILES:=$(shell find . -name '*.go' | grep -v -E '(./vendor)')

all: \
	bin/darwin/npd-controller
	#bin/linux/npd-controller \

images: GVERSION=$(shell $(CURDIR)/git-version.sh)
images: bin/linux/npd-agent bin/linux/npd-controller
	docker build -f Dockerfile -t npd-controller:$(GVERSION) .

check:
	@find . -name vendor -prune -o -name '*.go' -exec gofmt -s -d {} +
	@go vet $(shell go list ./... | grep -v '/vendor/')
	@go test -v $(shell go list ./... | grep -v '/vendor/')

update:
	dep ensure

test: bin/darwin/npd-controller
	bin/darwin/npd-controller --kubeconfig=/Users/wizard/.kube/config -v=5
clean:
	rm -rf bin

bin/%: LDFLAGS=-X github.com/WIZARD-CXY/npd-controller/pkg/common.Version=$(shell $(CURDIR)/git-version.sh)
bin/%: $(GOFILES)
	mkdir -p $(dir $@)
	GOOS=$(word 1, $(subst /, ,$*)) GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o $@ github.com/WIZARD-CXY/npd-controller/

