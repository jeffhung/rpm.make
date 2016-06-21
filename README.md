# rpm.make

For those who package RPM occasionally, the `rpm.make` file is a `Makefile`
module built on top of [GNU make][gmake] to simplify package building.

[gmake]: http://www.gnu.org/software/make/


## Usage

Use the `-f` option to load and use `rpm.make`:

```
$ make -f rpm.make
Usage: make [ TARGET ... ]

These rpm-* make targets help you automate the process to create RPM packages.

  rpm-help              - show this help message
  rpm-pack PKG_NAME=%   - create the RPM package called %
  rpm-spec RPM_SRCRPM=% - rip out the spec file from source RPM
  
For example, use the following command to create the libpng RPM:
  
  make RPM_NAME=rpm-libpng
  
Available make variables:
  
  RPM_NAME      - name of the package to build
  RPM_VERSION   - version of the package to build
  RPM_SOURCE    - source tar-ball of the package to build
```

Or you can write your main makefile like following to merge `rpm.make` make
targets in:

```
.PHONY: all
all: rpm-help

...

include rpm.make
```


## Targets

The make targets provided by `rpm.make` are prefixed with `rpm-` so you can use
them easily with auto-completion:

	$ make rpm-<TAB>
	rpm-clean  rpm-help   rpm-pack   rpm-spec

### rpm-help

Show help message of `rpm.make`:

	$ make rpm-help
	...

### rpm-spec

Extract `.spec` file from existing source RPM specified by `RPM_SRCRPM`.

```shell
$ make rpm-rip RPM_SRCRPM=cpuid-20140123-1.el6.src.rpm
[rpm.make] Ripping .spec from cpuid-20140123-1.el6.src.rpm
[rpm.make]      name: cpuid
[rpm.make]   version: 20140123
rm    -rf /vagrant/works/cpuid-20140123;
mkdir -p  /vagrant/works/cpuid-20140123;
cd /vagrant/works/cpuid-20140123; rpm2cpio /vagrant/cpuid-20140123-1.el6.src.rpm | cpio -idmv
cpuid-20140123.src.tar.gz
cpuid.spec
141 blocks
cp /vagrant/works/cpuid-20140123/*.spec .
```

The extracted `.spec` file will be put in current directory.

