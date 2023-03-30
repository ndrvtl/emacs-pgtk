# Include os-release to get current codename.
include /etc/os-release

# Without targets on command line, fetch emacs and build package for host distribution.
default:
	$(MAKE) fetch
	$(MAKE) $(VERSION_CODENAME)

REMOTE=https://github.com/emacs-mirror/emacs.git
HEAD=emacs-29
fetch: emacs/.git
# Fetch last commit of emacs-29 branch and checkout it.
	git -C emacs fetch --force --depth 1 $(REMOTE) refs/heads/$(HEAD):refs/remote/origin/$(HEAD)
	git -C emacs checkout --detach FETCH_HEAD

# Initialize an empty git to fetch emacs code.
emacs/.git:
	mkdir $(dir $@)
	git -C emacs init .

IMAGE=ndrvtl/emacs-pgtk
bullseye:
	docker build --pull --tag $(IMAGE):$@ -f Dockerfile .
	container="$$(docker create $(IMAGE):$@)" ; docker cp "$$container:/opt/packages" . ; docker rm "$$container"

clean:
	rm -rf emacs packages
	docker rmi --force $(IMAGE):bullseye
	docker rmi --force $(IMAGE):bookworm
	docker builder prune --force --all
