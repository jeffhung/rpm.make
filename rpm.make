# Copyright (c) 2015, Jeff Hung
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright notice,
#       this list of conditions and the following disclaimer in the documentation
#       and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
# OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# ----------------------------------------------------------------------------
# See: https://github.com/jeffhung/rpm.make
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Configurations
# ----------------------------------------------------------------------------

RPM_BUILD_DIR       ?= $(abspath build)
RPM_DISTS_DIR       ?= $(abspath dists)
RPM_WORKS_DIR       ?= $(abspath works)


# ----------------------------------------------------------------------------
# Functions
# ----------------------------------------------------------------------------

rpm_noop      =
rpm_joinwords = $(subst $(rpm_noop) $(rpm_noop),$(1),$(2))
rpm_popback   = $(wordlist 1,$(shell expr $(words $(1)) - 1),$(1))


# ----------------------------------------------------------------------------
# Make targets of rpm.make
# ----------------------------------------------------------------------------

.PHONY: rpm-help
rpm-help:
	@echo "Usage: make [ TARGET ... ]";
	@echo "";
	@echo "These rpm-* make targets help you automate the process to create RPM packages.";
	@echo "in local via virtualenv(1) and pip(1) inside it.";
	@echo "";
	@echo "  rpm-help             - show this help message";
	@echo "  rpm     PKG_NAME=%   - create the RPM package called %";
	@echo "  rpm-rip PKG_SRCRPM=% - rip out the spec file from source RPM";
	@echo "";
	@echo "For example, use the following command to create the libpng RPM:";
	@echo "";
	@echo "  $ make PKG_NAME=rpm-libpng";
	@echo "";
	@echo "Available make variables:";
	@echo "";
	@echo "  PKG_NAME      - name of the package to build";
	@echo "  PKG_VERSION   - version of the package to build";
	@echo "  PKG_SOURCE    - source tar-ball of the package to build";
	@echo "";

.PHONY: rpm-clean
rpm-clean:
	rm -rf $(RPM_BUILD_DIR);
	rm -rf $(RPM_WORKS_DIR);

.PHONY: rpm
rpm: PKG_NAME       ?= rpm.make
rpm: PKG_VERSION    ?= 0.1.1000
rpm: PKG_SOURCE     ?= $(PKG_NAME)-$(PKG_VERSION).tar.gz
rpm: PKG_SPECFILE   ?= $(PKG_NAME).spec.in
rpm:
	@echo "Making RPM $(PKG_NAME) version $(PKG_VERSION)";
	@echo "      from $(PKG_SOURCE)";
	@echo "      with $(PKG_SPECFILE)";
	mkdir -p $(RPM_BUILD_DIR)/{RPMS,SOURCES,BUILD,SPECS,SRPMS};
	cp -f $(PKG_SOURCE) $(RPM_BUILD_DIR)/SOURCES/;
	# Create SPEC file with changelog, and build RPM files.
	cat $(PKG_NAME).spec.in | sed \
		-e "s/#PKG_NAME#/$(PKG_NAME)/" \
		-e "s/#PKG_VERSION#/$(PKG_VERSION)/" \
		-e "s/#PKG_SOURCE#/$(PKG_SOURCE)/" \
	> $(RPM_BUILD_DIR)/SPECS/$(PKG_NAME)-$(PKG_VERSION).spec;
	rpmbuild --verbose --define="_topdir $(RPM_BUILD_DIR)" \
		-ba $(RPM_BUILD_DIR)/SPECS/$(PKG_NAME)-$(PKG_VERSION).spec;
	cp -f $(RPM_BUILD_DIR)/RPMS/*/$(PKG_NAME)-$(PKG_VERSION)-*.rpm $(RPM_DISTS_DIR)/;
	cp -f $(RPM_BUILD_DIR)/SRPMS/$(PKG_NAME)-$(PKG_VERSION)-*.rpm  $(RPM_DISTS_DIR)/;

.PHONY: rpm-rip
rpm-rip: RPM_SRCRPM  ?= $(error Please specify RPM_SRCRPM variable)
rpm-rip: RPM_NAME    ?= $(call rpm_joinwords,-,$(call rpm_popback,$(call rpm_popback,$(subst -, ,$(notdir $(RPM_SRCRPM))))))
rpm-rip: RPM_VERSION ?= $(lastword $(call rpm_popback,$(subst -, ,$(notdir $(RPM_SRCRPM)))))
rpm-rip: RPM_RIP_DIR ?= $(RPM_WORKS_DIR)/$(RPM_NAME)-$(RPM_VERSION)
rpm-rip:
	@echo "Ripping .spec from $(RPM_SRCRPM)";
	@echo "     name: $(RPM_NAME)";
	@echo "  version: $(RPM_VERSION)";
	mkdir -p $(RPM_RIP_DIR);
	cd $(RPM_RIP_DIR); rpm2cpio $(abspath $(RPM_SRCRPM)) | cpio -idmv

