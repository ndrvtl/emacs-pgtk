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

EMACS_VERSION=$(shell grep -Po 'AC_INIT.+\K30\.[^\]]+' emacs/configure.ac)
PKG_VERSION=$(EMACS_VERSION).$(shell date +%Y%m%d).$(shell git -C emacs rev-parse --short HEAD)
IMAGE=ndrvtl/emacs-pgtk
bookworm trixie:
	DOCKER_BUILDKIT=1 docker build --pull --build-arg EMACS_VERSION=$(EMACS_VERSION) --build-arg PKG_VERSION=$(PKG_VERSION) --tag $(IMAGE):$@ -f Dockerfile.$@ .
	container="$$(docker create $(IMAGE):$@)" ; docker cp "$$container:/opt/packages" . ; docker rm "$$container"

clean:
	rm -rf emacs packages
	docker rmi --force $(IMAGE):bookworm
	docker builder prune --force --all
