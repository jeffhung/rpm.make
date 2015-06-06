
NAME            := rpm.make
BUILD_NUMBER    ?= 1000
VERSION         := 0.1.$(BUILD_NUMBER)

prefix          ?= /usr/local


.PHONY: all
all: help

.PHONY: help
help:
	@echo "Usage: make [ TARGET ... ]";
	@echo "";
	@echo "TARGET:";
	@echo "";
	@echo "  help      - show this help message";
	@echo "  package   - package the source tarball";
	@echo "  clean     - delete all generated files";
	@echo "  distclean - delete all generated files and caches";
	@echo "";
	@echo "Default TARGET is 'help'.";

.PHONY: clean
clean: rpm-clean
	rm -rf $(NAME)-$(VERSION);
	rm -rf $(NAME)-$(VERSION).tar.gz;

.PHONY: distclean
distclean: clean

.PHONY: package
package:
	mkdir -p $(NAME)-$(VERSION);
	cp -p GNUmakefile rpm.make rpm.make.spec.in \
	   $(NAME)-$(VERSION);
	tar zcvf $(NAME)-$(VERSION).tar.gz $(NAME)-$(VERSION);

.PHONY: install
install: DESTDIR  ?= root
install:
	mkdir -p $(DESTDIR)$(prefix)/share;
	cp -f rpm.make $(DESTDIR)$(prefix)/share/;

include rpm.make

