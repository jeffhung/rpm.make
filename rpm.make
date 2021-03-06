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

rpm_sedsubs   = sed -e "s/\#RPM_NAME\#/$(RPM_NAME)/"
rpm_sedsubs  +=     -e "s/\#RPM_VERSION\#/$(RPM_VERSION)/"
rpm_sedsubs  +=     -e "s/\#RPM_PACKER\#/$(RPM_PACKER)/"
rpm_sedsubs  +=     -e "s/\#RPM_SOURCE0\#/$(patsubst %.in,%,$(notdir $(RPM_SOURCE0)))/"
rpm_sedsubs  +=     -e "s/\#RPM_SOURCE1\#/$(patsubst %.in,%,$(notdir $(RPM_SOURCE1)))/"
rpm_sedsubs  +=     -e "s/\#RPM_SOURCE2\#/$(patsubst %.in,%,$(notdir $(RPM_SOURCE2)))/"


# ----------------------------------------------------------------------------
# Make targets of rpm.make
# ----------------------------------------------------------------------------

.PHONY: rpm-help
rpm-help:
	@echo "Usage: make [ TARGET ... ]";
	@echo "";
	@echo "These rpm-* make targets help you automate the process to create RPM packages.";
	@echo "";
	@echo "  rpm-help              - show this help message";
	@echo "  rpm-pack RPM_NAME=%   - create the RPM package called %";
	@echo "  rpm-spec RPM_SRCRPM=% - rip out the spec file from source RPM";
	@echo "";
	@echo "For example, use the following command to create the libpng RPM:";
	@echo "";
	@echo "  $ make RPM_NAME=rpm-libpng";
	@echo "";
	@echo "Available make variables:";
	@echo "";
	@echo "  RPM_NAME      - name of the package to build";
	@echo "  RPM_VERSION   - version of the package to build";
	@echo "  RPM_SOURCE    - source tar-ball of the package to build";
	@echo "  RPM_PACKER    - tag to show who packed the RPM";
	@echo "";

.PHONY: rpm-clean
rpm-clean:
	rm -rf $(RPM_BUILD_DIR);
	rm -rf $(RPM_WORKS_DIR);

.PHONY: rpm-pack
rpm-pack: RPM_NAME       ?= rpm.make
rpm-pack: RPM_VERSION    ?= 0.1.1000
rpm-pack: RPM_SPECFILE   ?= $(RPM_NAME).spec.in
rpm-pack: RPM_PACKER     ?= .rm
rpm-pack: RPM_SOURCE0    ?= $(RPM_NAME)-$(RPM_VERSION).tar.gz
rpm-pack: RPM_SOURCE1    ?= 
rpm-pack: RPM_SOURCE2    ?= 
rpm-pack:
	@echo "$(rpm_sedsubs)";
	@echo $(filter %.in,$(RPM_SOURCE1));
	###
	@echo "Making RPM $(RPM_NAME) version $(RPM_VERSION)";
	@echo "      with $(RPM_SPECFILE)";
	@echo "        by $(RPM_PACKER)";
	@echo "      from $(RPM_SOURCE0)";
	mkdir -p $(RPM_BUILD_DIR)/{RPMS,SOURCES,BUILD,SPECS,SRPMS};
	# Put the source0 file
	cp -f $(RPM_SOURCE0) $(RPM_BUILD_DIR)/SOURCES/;
	# Put source1~9 and substitute values if its name end with .in.
	$(if $(filter %.in,$(RPM_SOURCE1))\
	,cat $(RPM_SOURCE1) | $(rpm_sedsubs) > $(patsubst %.in,%,$(RPM_BUILD_DIR)/SOURCES/$(notdir $(RPM_SOURCE1)))\
	,$(if $(RPM_SOURCE1),cp $(RPM_SOURCE1) $(RPM_BUILD_DIR)/SOURCES/))
	$(if $(filter %.in,$(RPM_SOURCE2))\
	,cat $(RPM_SOURCE2) | $(rpm_sedsubs) > $(patsubst %.in,%,$(RPM_BUILD_DIR)/SOURCES/$(notdir $(RPM_SOURCE2)))\
	,$(if $(RPM_SOURCE2),cp $(RPM_SOURCE2) $(RPM_BUILD_DIR)/SOURCES/))
	# Create and put the SPEC file.
	cat $(RPM_SPECFILE) | $(rpm_sedsubs) > $(RPM_BUILD_DIR)/SPECS/$(RPM_NAME)-$(RPM_VERSION).spec;
	# Build the RPM files.
	rpmbuild --verbose --define="_topdir $(RPM_BUILD_DIR)" \
		-ba $(RPM_BUILD_DIR)/SPECS/$(RPM_NAME)-$(RPM_VERSION).spec;
	mkdir -p $(RPM_DISTS_DIR);
	cp -f $(RPM_BUILD_DIR)/RPMS/*/$(RPM_NAME)-$(RPM_VERSION)-*.rpm $(RPM_DISTS_DIR)/;
	cp -f $(RPM_BUILD_DIR)/SRPMS/$(RPM_NAME)-$(RPM_VERSION)-*.rpm  $(RPM_DISTS_DIR)/;

.PHONY: rpm-spec
rpm-spec: RPM_SRCRPM  ?= $(error Please specify RPM_SRCRPM variable)
rpm-spec: RPM_NAME    ?= $(call rpm_joinwords,-,$(call rpm_popback,$(call rpm_popback,$(subst -, ,$(notdir $(RPM_SRCRPM))))))
rpm-spec: RPM_VERSION ?= $(lastword $(call rpm_popback,$(subst -, ,$(notdir $(RPM_SRCRPM)))))
rpm-spec: RPM_RIP_DIR ?= $(RPM_WORKS_DIR)/$(RPM_NAME)-$(RPM_VERSION)
rpm-spec:
	@echo "[rpm.make] Extract .spec from $(RPM_SRCRPM)";
	@echo "[rpm.make]      name: $(RPM_NAME)";
	@echo "[rpm.make]   version: $(RPM_VERSION)";
	rm    -rf $(RPM_RIP_DIR);
	mkdir -p  $(RPM_RIP_DIR);
	cd $(RPM_RIP_DIR); rpm2cpio $(abspath $(RPM_SRCRPM)) | cpio -idmv
	cp $(RPM_RIP_DIR)/*.spec ./$(RPM_NAME).spec.in

