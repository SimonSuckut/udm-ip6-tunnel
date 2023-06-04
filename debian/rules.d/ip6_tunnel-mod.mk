# -*- makefile -*-

# Copyright (C) 2023 Simon Suckut.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# Include configuration for the specific version
include debian/config/v${UDM_VERSION}/config.mk

BUILD_DIR ?= build

# The location from which the kernel sources are downloaded
UDM_KERNEL_URL ?= https://github.com/fabianishere/udm-kernel/archive/${UDM_COMMIT}.tar.gz
UDM_KERNEL_TARBALL := ${BUILD_DIR}/$(shell basename ${UDM_KERNEL_URL})
UDM_KERNEL_SRC ?= ${BUILD_DIR}/kernel-${UDM_COMMIT}
UDM_MODULE_DIR ?= ${BUILD_DIR}/modules/v${UDM_VERSION}

IPV6_MOD_SRC ?= ipv6-mod

# Cross compilation settings
export ARCH=${DEB_TARGET_ARCH}
export CROSS_COMPILE=${DEB_TARGET_MULTIARCH}-

.PHONY: all
all: ${UDM_MODULE_DIR}/ip6_tunnel.ko

${UDM_KERNEL_TARBALL}:
	mkdir -p $(dir ${UDM_KERNEL_TARBALL})/
	wget -P $(dir ${UDM_KERNEL_TARBALL})/ -N $(if ${GITHUB_TOKEN},--header="Authorization: token ${GITHUB_TOKEN}") ${UDM_KERNEL_URL}

${UDM_KERNEL_SRC}: ${UDM_KERNEL_TARBALL}
	mkdir -p $@
	tar -C $@ --strip-components=1 -xf ${UDM_KERNEL_TARBALL}

${UDM_KERNEL_SRC}/v${UDM_VERSION}.config: debian/config/v${UDM_VERSION}/config.udm | ${UDM_KERNEL_SRC}
	ln -s $(realpath $<) $@
	cp $@ ${UDM_KERNEL_SRC}/.config
	truncate -s 0 ${UDM_KERNEL_SRC}/localversion
	$(MAKE) -C ${UDM_KERNEL_SRC} olddefconfig LOCALVERSION=-ui-alpine
	$(MAKE) -C ${UDM_KERNEL_SRC} modules_prepare LOCALVERSION=-ui-alpine
	
${UDM_MODULE_DIR}/ip6_tunnel.ko: ${UDM_KERNEL_SRC}/v${UDM_VERSION}.config
	mkdir -p ${UDM_MODULE_DIR}
	dh_auto_build --sourcedirectory=${IPV6_MOD_SRC}/kernel -- KDIR=$(realpath ${UDM_KERNEL_SRC}) LDFLAGS=
	cp ${IPV6_MOD_SRC}/kernel/ip6_tunnel.ko ${UDM_MODULE_DIR}/ip6_tunnel.ko

.PHONY: clean
clean:
ifneq ($(realpath ${UDM_KERNEL_SRC}),)
	dh_auto_clean --sourcedirectory=${IPV6_MOD_SRC}/kernel -- KDIR=$(realpath ${UDM_KERNEL_SRC})
endif
	rm -rf ${BUILD_DIR}
