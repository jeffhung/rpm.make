# rpm.make

For those who package RPM occasionally, the `rpm.make` file is a `Makefile`
module built on top of [GNU make][gmake] to simplify package building.

[gmake]: http://www.gnu.org/software/make/


## Usage

Use the `-f` option to load and use `rpm.make`:

```console
$ make -f rpm.make
Usage: make [ TARGET ... ]

These rpm-* make targets help you automate the process to create RPM packages.

  rpm-help              - show this help message
  rpm-pack RPM_NAME=%   - create the RPM package called %
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

```make
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

```console
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

The extracted `.spec` file will be renamed to `.spec.in` and be put in current
directory. So you could modify it and use `rpm-pack` later to package the RPM
based on the `.spec.in` file enhanced by you. See
[Customize RPM Spec](#customize-rpm-spec) for more details.


## Customize RPM Spec

You are using this `rpm.make` because you are neither satisfied on existing RPM
nor can find one. The following workflow is supported to support customizing
and build your own RPM:

1. If you have an existing RPM, use the `rpm-spec` target to extract the
	 `.spec` file into `.spec.in` file.
2. Create or use the extracted `.spec.in` file and modify it bassed on your
	 needs.
3. Use the `rpm-pack` target to package the RPM you desired.

Variable substitutions are supported to allow reusing `.spec.in` files. It is
recommended to make these substitutions RPM `.spec` variables at the very
beginning for later use when defining RPM tags. For example:

```
%define rpm_name    #RPM_NAME#
%define rpm_version #RPM_VERSION#
%define rpm_source  #RPM_SOURCE#
%define rpm_packer  #RPM_PACKER#

Name:           %{rpm_name}
Version:        %{rpm_version}
Release:        1%{?dist}%{rpm_packer}
Summary:        Dumps information about the CPU(s)
License:        MIT
URL:            http://www.etallen.com/cpuid.html
#Source0:        http://www.etallen.com/%{name}/%{name}-%{version}.src.tar.gz
Source0:        %{rpm_source}
```

Like you see in the above example, variable substitutions are surrounded by `#`
signs in the `.spec.in` file. The supported variable substitutions are:

### RPM_NAME

The name of the RPM to build. You do not have to subsitute this actually. It
will be the value of the `RPM_NAME` variable you passed into `rpm.make`.

### RPM_VERSION

The version of the RPM to build. Usually you will subsitute this so you could
reuse the `.spec.in` file for future versions.

### RPM_SOURCE

The file path or URL to the source tarball of this RPM. According to RPM
official guide:

> RPM actually ignores everything prior to the last filename in the source
> line, so the first part of the source string could be anything you'd like.
> Traditionally, the source line usually contains a Uniform Resource Locator,
> or URL. 

To make sure future builds will success disregard to network/upstream issue, it
is recommended to download the source tarball and put in somewhere for
`rpm.make` to consume -- by specifying the `RPM_SOURCE` variable.

### RPM_PACKER

Specify who is using `rpm.make` and packaged the RPM. Default to `.rpmmake`.

The value shall have a dot `.` prefix. So you could use it in the RPM `Release` tag like:

```
%define rpm_packer  #RPM_PACKER#

Release: 1%{?dist}%{rpm_packer}
```


