JB = https://github.com/jsonnet-bundler/jsonnet-bundler/releases/latest/download/jb-linux-amd64
BINDIR = bin
TEMPLATESDIR = templates
OUTPUTDIR = rendered
ALLDIRS = $(BINDIR) $(OUTPUTDIR)
SYNCER_IMG_TAG ?= quay.io/cloud-bulldozer/dittybopper-syncer:latest
PLATFORM = linux/amd64,linux/arm64,linux/ppc64le,linux/s390x

ifeq ($(filter v2,$(MAKECMDGOALS)),v2)
    # Set variables and instructions for v2
    TEMPLATES := $(wildcard $(TEMPLATESDIR)/**/*-v2.jsonnet)
	LIBRARY_PATH := $(TEMPLATESDIR)/vendor
	JSONNET := https://github.com/cloud-bulldozer/utils/releases/download/v0.0.0/jsonnet-bin-v0.20.0-linux.tar.gz
else
	# Get all templates at $(TEMPLATESDIR)
	TEMPLATES := $(filter-out %-v2.jsonnet, $(wildcard $(TEMPLATESDIR)/**/*.jsonnet))
	LIBRARY_PATH := $(TEMPLATESDIR)/grafonnet-lib
	JSONNET := https://github.com/google/jsonnet/releases/download/v0.17.0/jsonnet-bin-v0.17.0-linux.tar.gz
endif

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
	rm -rf $(ALLDIRS) $(TEMPLATESDIR)/vendor $(TEMPLATESDIR)/grafonnet-lib

$(BINDIR)/jsonnet:
	@echo "Downloading jsonnet binary"
	curl -s -L $(JSONNET) | tar xz -C $(BINDIR)
	@echo "Downloading jb binary"
	curl -s -L $(JB) -o $(BINDIR)/jb
	chmod +x $(BINDIR)/jb

$(TEMPLATESDIR)/grafonnet-lib:
	git clone --depth 1 https://github.com/grafana/grafonnet-lib.git $(TEMPLATESDIR)/grafonnet-lib

$(TEMPLATESDIR)/vendor:
	@echo "Downloading vendor files"
	cd $(TEMPLATESDIR) && ../$(BINDIR)/jb install && cd ../

# Build each template and output to $(OUTPUTDIR)
$(OUTPUTDIR)/%.json: $(TEMPLATESDIR)/%.jsonnet
	@echo "Building template $<"
	mkdir -p $(dir $@)
	$(BINDIR)/jsonnet -J ./$(LIBRARY_PATH) $< > $@

v2: all
	@echo "Rendered the v2 dashboards with latest grafonnet library"

build-syncer-image: build
	podman build --platform=${PLATFORM} -f Dockerfile --manifest=${SYNCER_IMG_TAG} .

push-syncer-image:
	podman manifest push ${SYNCER_IMG_TAG} ${SYNCER_IMG_TAG}