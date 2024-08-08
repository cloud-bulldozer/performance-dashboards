ARCH := $(shell arch)
OS_TYPE := $(shell uname)
JB_OS_TYPE := $(shell uname | tr '[:upper:]' '[:lower:]')
JSONNET := https://github.com/google/go-jsonnet/releases/download/v0.20.0/go-jsonnet_0.20.0_$(OS_TYPE)_$(ARCH).tar.gz
JB := https://github.com/jsonnet-bundler/jsonnet-bundler/releases/latest/download/jb-$(JB_OS_TYPE)-$(subst x86_64,amd64,$(ARCH))
BINDIR = bin
TEMPLATESDIR = templates
ASSETS := $(wildcard assets/**/*.libsonnet)
OUTPUTDIR = rendered
ALLDIRS = $(BINDIR) $(OUTPUTDIR)
SYNCER_IMG_TAG ?= quay.io/cloud-bulldozer/dittybopper-syncer:latest
PLATFORM = linux/amd64,linux/arm64,linux/ppc64le,linux/s390x

# Get all templates at $(TEMPLATESDIR)
TEMPLATES := $(wildcard $(TEMPLATESDIR)/**/*.jsonnet)
LIBRARY_PATH := $(TEMPLATESDIR)/vendor

# Replace $(TEMPLATESDIR)/*.jsonnet by $(OUTPUTDIR)/*.json
outputs := $(patsubst $(TEMPLATESDIR)/%.jsonnet, $(OUTPUTDIR)/%.json, $(TEMPLATES))

all: deps format build

deps: $(ALLDIRS) $(BINDIR)/jsonnet $(LIBRARY_PATH)

$(ALLDIRS):
	mkdir -p $(ALLDIRS)

format: deps
	$(BINDIR)/jsonnetfmt -i $(TEMPLATES)

build: deps $(LIBRARY_PATH) $(outputs)

clean:
	@echo "Cleaning up"
	rm -rf $(ALLDIRS) $(TEMPLATESDIR)/vendor

$(BINDIR)/jsonnet:
	@echo "Downloading jsonnet binary"
	curl -s -L $(JSONNET) | tar xz -C $(BINDIR)
	@echo "Downloading jb binary"
	curl -s -L $(JB) -o $(BINDIR)/jb
	chmod +x $(BINDIR)/jb

$(TEMPLATESDIR)/vendor:
	@echo "Downloading vendor files"
	cd $(TEMPLATESDIR) && ../$(BINDIR)/jb install && cd ../

# Build each template and output to $(OUTPUTDIR)
$(OUTPUTDIR)/%.json: $(TEMPLATESDIR)/%.jsonnet $(ASSETS)
	@echo "Building template $<"
	mkdir -p $(dir $@)
	$(BINDIR)/jsonnet -J ./$(LIBRARY_PATH) $< > $@

build-syncer-image: build
	podman build --platform=${PLATFORM} -f Dockerfile --manifest=${SYNCER_IMG_TAG} .

push-syncer-image:
	podman manifest push ${SYNCER_IMG_TAG} ${SYNCER_IMG_TAG}
