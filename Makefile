SHELL:=/bin/bash

.PHONY: init
init:
	@SETUP_REPO_DIR=$(shell pwd) GOLANG_VERSION=latest MEMBERS=(tesso57 toshi-pono Ras96) ./init.sh
