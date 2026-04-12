# Include os-release to get current codename.
include /etc/os-release

# Without targets on command line, fetch emacs and build package for host distribution.
default:
	$(MAKE) fetch
	$(MAKE) $(VERSION_CODENAME)

REMOTE=https://github.com/emacs-mirror/emacs.git
HEAD=emacs-30
fetch: emacs/.git
# Fetch last commit of emacs-30 branch and checkout it.
	git -C emacs fetch --force --depth 1 $(REMOTE) refs/heads/$(HEAD):refs/remote/origin/$(HEAD)
	git -C emacs checkout --detach FETCH_HEAD

# Initialize an empty git to fetch emacs code.
emacs/.git:
	mkdir $(dir $@)
	git -C emacs init .

TREE_SITTER_VERSION=$(shell grep -oP 'TREE_SITTER_VERSION=\K[^\s]+' Dockerfile.trixie)
EMACS_VERSION=$(shell grep -Po 'AC_INIT.+\K30\.[^\]]+' emacs/configure.ac)
PKG_VERSION=$(EMACS_VERSION).$(shell date +%Y%m%d).$(shell git -C emacs rev-parse --short HEAD)
IMAGE=ndrvtl/emacs-pgtk
CONTAINER ?= docker

# Prefix: DOCKER_BUILDKIT=1 for docker, empty for podman
CONTAINER_PREFIX = $(if $(filter docker,$(CONTAINER)),DOCKER_BUILDKIT=1,)

.PHONY: tree-sitter
tree-sitter:
	mkdir -p packages/treesitter
	$(CONTAINER_PREFIX) $(CONTAINER) build --pull --build-arg TREE_SITTER_VERSION=$(TREE_SITTER_VERSION) --target tree-sitter-builder --tag $(IMAGE):tree-sitter -f Dockerfile.trixie .
	container="$$($(CONTAINER) create $(IMAGE):tree-sitter)" ; $(CONTAINER) cp "$$container:/output" ./packages/treesitter ; $(CONTAINER) rm "$$container"
	$(CONTAINER) rmi $(IMAGE):tree-sitter

bookworm trixie:
	mkdir -p packages
	# Build tree-sitter stage and extract packages
	$(CONTAINER_PREFIX) $(CONTAINER) build --pull --build-arg TREE_SITTER_VERSION=$$(grep -oP 'TREE_SITTER_VERSION=\K[^\s]+' Dockerfile.$@) --target tree-sitter-builder --tag $(IMAGE):$@-ts -f Dockerfile.$@ .
	container="$$($(CONTAINER) create $(IMAGE):$@-ts)" ; $(CONTAINER) cp "$$container:/output" ./packages/treesitter ; $(CONTAINER) rm "$$container"
	# Build full image using tree-sitter stage as cache (no rebuild)
	$(CONTAINER_PREFIX) $(CONTAINER) build --pull --cache-from $(IMAGE):$@-ts --build-arg EMACS_VERSION=$(EMACS_VERSION) --build-arg PKG_VERSION=$(PKG_VERSION) --tag $(IMAGE):$@ -f Dockerfile.$@ .
	container="$$($(CONTAINER) create $(IMAGE):$@)" ; $(CONTAINER) cp "$$container:/opt/packages" ./packages/emacs ; $(CONTAINER) rm "$$container"
	$(CONTAINER) rmi $(IMAGE):$@-ts

clean:
	rm -rf emacs packages
	$(CONTAINER) rmi --force $(IMAGE):bookworm
	$(CONTAINER) builder prune --force --all
