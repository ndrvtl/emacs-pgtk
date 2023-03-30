# Include os-release to get current codename.
include /etc/os-release

# Without targets on command line, fetch emacs and build package for host distribution.
default:
	$(MAKE) $(VERSION_CODENAME)

IMAGE=ndrvtl/emacs-pgtk
bullseye:
	docker build --pull --tag $(IMAGE):$@ -f Dockerfile .
	container="$$(docker create $(IMAGE):$@)" ; docker cp "$$container:/opt/packages" . ; docker rm "$$container"

clean:
	rm -rf packages
	docker rmi --force $(IMAGE):bullseye
	docker rmi --force $(IMAGE):bookworm
	docker builder prune --force --all
