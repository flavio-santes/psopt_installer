# PSOPT Installer

The PSOPT Installer is a set of scripts and patches that allow
the user to compile and run the PSOPT sample code.

"Pseudospectral Optimal Control Solver in C++" or PSOPT is a set
of routines and sample code for optimal control.

The PSOPT package is available at:

- Website: http://www.psopt.org/
- Repository: https://github.com/PSOPT/psopt

However, this installer uses a modified version
[freely available](https://github.com/flavio-santes/psopt).

## Requirements

### Supported Operating Systems
- Debian: tested on Debian 9.3
- Ubuntu: tested on Ubuntu 16 LTS
- CentOS / RedHat Enterprise Linux (REL): tested on CentOS 7
- Fedora: tested on Fedora 27

### Extra requirements
- Access to sudo. In Ubuntu, sudo is already configured.
  However, in Debian, CentOS, REL and Fedora, `sudo` must be
  configured by the sys admin.
- Access to Internet during installation to download dependencies.

## Build

- Open a terminal window and type:
```
wget https://github.com/flavio-santes/psopt_installer/archive/dev.zip
unzip dev.zip
cd psopt_installer-dev
./psopt_installer.sh
```

The psopt_installer.sh script executes the following steps:

- Download all the dependencies.
- Configure, patch, compile and install all the dependencies.
- Patch and compile the PSOPT package.

## Run sample applications

- For example, to run the `coulomb` sample application,
  open a terminal window and type:

```
cd ~/psopt_bundle
source set_variables.sh
cd psopt/PSOPT/examples/coulomb/
./coulomb
```

## Frequently Asked Questions

#### I see there is a LICENSE.txt file, what does it mean?

The GNU Affero GPL version 3 License only applies to the following
files:

- `psopt_installer.sh`
- `scripts/set_variables.sh`

#### What PSOPT version is included by the PSOPT Installer?

The PSOPT version with HEAD pointing to commit
[88f9c2f](https://github.com/PSOPT/psopt/commit/88f9c2f9f91538ea6bb355b485e93bbdee7ffbcd).

#### Are you the PSOPT maintainer?

No, I am not. PSOPT issues must be reported to the PSOPT developers.

#### Why don't you distribute a binary containing all the software?

I can't. METIS 4.0.3 package forbids this. However, newer METIS versions
are licensed under the Apache License v2.0, so perhaps if PSOPT is updated
we can produce binary packages.

#### What is the difference between this project and the install scripts found at the psopt-master.zip file?

The `psopt_installer.sh` script installs all the dependencies in
a portable way. If you want to hack the installer do the following:

##### Before installing PSOPT

If you modify the `psopt_dir` variable to point to another directory, the
PSOPT Installer will install everything there, without modifying your
current system libraries.

##### After installing PSOPT

Alternatively, you can move the `psopt_bundle` folder to any location
within the machine and PSOPT will work fine.

## Troubleshooting

#### I get the following message when trying to run the xxxxx sample application:
```
./xxxxx: error while loading shared libraries: libipopt.so.1: cannot open shared object file: No such file or directory
```

Open a terminal window and type:
```
cd ~/psopt_bundle
source set_variables.sh
cd psopt/PSOPT/examples/coulomb/
./coulomb
```

Replace `coulomb` with the name of sample application you want to run.

#### Does the installer work on other GNU/Linux distributions?

##### Debian 8

In Debian 8, the symbolic links to the libf2c shared objects must be
removed, after installing the libf2c package and before linking the
PSOPT sample applications. Thus, forcing the linker to use the static
version:

```
sudo rm /usr/lib/x86_64-linux-gnu/libf2c.so
sudo rm /usr/lib/x86_64-linux-gnu/libf2c.so.2
```

##### Ubuntu 17

There are some bugs in PSOPT and/or its dependencies that prevent that
in some cases, PSOPT routines demanding a lot of memory are unable
to reach an optimal solution.

Workarounds:
- Increase the iteration number in the example (easiest)
- Change the BLAS library: modify Makefile, change this line:
```
	-lcblas
```
  Use another BLAS library and recompile.
- Find and fix the bug (complicated)
- Or use GCC-6: gcc-6, g++-6, gfortran-6 and libgfortran-3 instead of
the default compiler version (currently GCC-7). (a bit more complicated...)

The `psopt_installer.sh` script must be modified to allow the usage of
GCC-6 and the following variables must be exported:

```
export CC=gcc-6
export CXX=g++-6
export FC=gfortran-6
export F77=gfortran-6
```

#### On Fedora 27, some examples do not converge, what should I do?

See the Ubuntu 17 Workarounds.

