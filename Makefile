JSONNET = https://github.com/google/jsonnet/releases/download/v0.15.0/jsonnet-bin-v0.15.0-linux.tar.gz
BINDIR = bin
TEMPLATESDIR = templates
OUTPUTDIR = rendered
ALLDIRS = $(BINDIR) $(OUTPUTDIR)
SYNCER_IMG_TAG = quay.io/cloud-bulldozer/dittybopper-syncer:latest

# Get all templates at $(TEMPLATESDIR)
TEMPLATES = $(wildcard $(TEMPLATESDIR)/*.jsonnet)

# Replace $(TEMPLATESDIR)/*.jsonnet by $(OUTPUTDIR)/*.json
outputs = $(patsubst $(TEMPLATESDIR)/%.jsonnet, $(OUTPUTDIR)/%.json, $(TEMPLATES))

all: deps format build

deps: $(ALLDIRS) $(TEMPLATESDIR)/grafonnet-lib $(BINDIR)/jsonnet

$(ALLDIRS):
	mkdir -p $(ALLDIRS)

format: deps
	$(BINDIR)/jsonnetfmt -i $(TEMPLATES)

build: deps $(TEMPLATESDIR)/grafonnet-lib $(outputs)

clean:
	@echo "Cleaning up"
	rm -rf $(ALLDIRS) $(TEMPLATESDIR)/grafonnet-lib

$(TEMPLATESDIR)/grafonnet-lib:
	git clone --depth 1 https://github.com/grafana/grafonnet-lib.git $(TEMPLATESDIR)/grafonnet-lib

$(BINDIR)/jsonnet:
	@echo "Downloading jsonnet binary"
	curl -s -L $(JSONNET) | tar xz -C $(BINDIR)

# Build each template and output to $(OUTPUTDIR)
$(OUTPUTDIR)/%.json: $(TEMPLATESDIR)/%.jsonnet
	@echo "Building template $<"
	$(BINDIR)/jsonnet $< > $@

build-syncer-image: build
	podman build --all-platforms -f dittybopper/syncer/Dockerfile --manifest=${SYNCER_IMG_TAG} .

push-syncer-image:
	podman manifest push ${SYNCER_IMG_TAG} ${SYNCER_IMG_TAG}
