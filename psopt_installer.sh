#!/bin/bash

#
# PSOPT Installer
# Copyright (C) 2018, Flavio Santes <flavio.santes at 1byt3.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

psopt_dir="$HOME/psopt_bundle"
psopt_vars="set_variables.sh"

psopt_src="psopt"
psopt_url="https://github.com/flavio-santes/psopt.git"

download_cmd=""
os_name=""
binary_dir="$psopt_dir/binary"
configure_cmd="./configure --prefix=$binary_dir"

root_dir=$PWD

debian_pkgs()
{
	sudo apt-get install -y			\
		gcc g++ gfortran		\
		make patch			\
		libf2c2-dev 			\
		libopenblas-dev			\
		liblapack-dev			\
		gnuplot wget git unzip cmake
}

redhat_pkgs()
{
	sudo yum install -y			\
		gcc gcc-c++ gcc-gfortran	\
		make patch			\
		f2c		 		\
		atlas atlas-devel		\
		lapack lapack-devel		\
		gnuplot wget git unzip cmake
}

configure_os()
{
	case $(uname) in
	Linux)
		if [ -e "/etc/debian_version" ]
		then
			os_name="Debian"
			debian_pkgs
		elif [ -e "/etc/redhat-release" ] || [ -e "/etc/fedora-release" ]
		then
			os_name="CentOS"
			redhat_pkgs

			# CentOS hack for cblas and atlas
			cd /usr/lib64
			if [ ! -e "libcblas.so" ]
			then
				sudo ln -s atlas/libsatlas.so libcblas.so
			fi
		else
			echo "Unsupported OS :("
			exit 1
		fi

		download_cmd="wget -O"
		;;
	*)
		echo "Unsupported OS :("
		exit 1
		;;
	esac

	mkdir -p "$root_dir/tmp"
	mkdir -p "$psopt_dir"

	cd $psopt_dir/
	cp $root_dir/scripts/$psopt_vars .
	source $psopt_vars
}

clean_all()
{
	cd "$root_dir/"
	rm -rf "tmp"
	mkdir -p "$root_dir/tmp"

	rm -rf "$psopt_dir"
	mkdir -p "$psopt_dir"
}

install_metis()
{
	cd $root_dir/tmp
	tar zxf $root_dir/packages/metis-5.1.0.tar.gz

	cd $root_dir/tmp/metis-5.1.0
	patch -p0 < $root_dir/patches/METIS_type_size.diff

	make config shared=1 prefix=$binary_dir
	make
	make install
}

install_mumps()
{
        cd $root_dir/tmp
        tar zxf $root_dir/packages/MUMPS_5.1.2.tar.gz

	cd MUMPS_5.1.2
	patch -p0 < $root_dir/patches/MUMPS_Makefiles.diff

	make
	cp -R include $binary_dir/include/mumps
	cp libseq/*.h $binary_dir/include/mumps
	cp lib/libdmumps.so $binary_dir/lib
	cp lib/libmumps_common.so $binary_dir/lib
	cp libseq/libmpiseq.so $binary_dir/lib
}

install_ipopt()
{
	cd $root_dir/tmp
	tar zxf $root_dir/packages/Ipopt-3.12.3.tgz

	cd $root_dir/tmp/Ipopt-3.12.3
	$configure_cmd				\
		--disable-static		\
		coin_skip_warn_cxxflags=yes

	make && make install
}

install_colpack()
{
	cd $root_dir/tmp
	tar zxf $root_dir/packages/ColPack-1.0.9.tar.gz
	cd ColPack-1.0.9

	patch -p0 < $root_dir/patches/ColPack_utilities_extra.diff

	$configure_cmd				\
		--disable-shared

	make && make install
}

install_adol_c()
{
	cd $root_dir/tmp
	tar zxf $root_dir/packages/ADOL-C-2.5.2.tgz
	cd ADOL-C-2.5.2

	$configure_cmd				\
		--with-colpack="$psopt_dir"	\
		--disable-shared		\
		--enable-sparse

	make && make install
}

install_lusol()
{
	cd "$root_dir/tmp"
	unzip "$root_dir/packages/lusol.zip"
	cd lusol/csrc
	cp "$root_dir/scripts/Makefile_lusol" Makefile
	make -f Makefile

	mkdir -p $binary_dir/lib
	mkdir -p $binary_dir/include/lusol

	cp liblusol.a $binary_dir/lib
	cp *.h $binary_dir/include/lusol
}

install_cxsparse()
{
	cd $root_dir/tmp
	tar zxf $root_dir/packages/SuiteSparse-4.4.3.tar.gz
	cd SuiteSparse/CXSparse
	make

	incs=$binary_dir/include/cxsparse
	mkdir -p $incs

	cp Include/cs.h $incs
	cp ../SuiteSparse_config/SuiteSparse_config.h $incs
	cp Lib/libcxsparse.a $binary_dir/lib
}

install_psopt()
{
	cd $psopt_dir
	git clone $psopt_url --branch fixes $psopt_src

	cd $psopt_src

	patch -p0 < $root_dir/patches/PSOPT_delete_unused_files.diff
	patch -p0 < $root_dir/patches/PSOPT_src_plot.diff
	patch -p0 < $root_dir/patches/PSOPT_Makefile.diff

	export GIT_AUTHOR_NAME="PSOPT Installer"
	export GIT_AUTHOR_EMAIL="psopt"
	export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
	export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

	git add .
	git commit -m "installer: save local changes"

	make all
}

set -e

case $1 in
clean)
	clean_all
	;;
*)
	clean_all
	configure_os
	install_metis
	install_mumps
#	install_ipopt
#	install_colpack
#	install_adol_c
#	install_lusol
#	install_cxsparse
#	install_psopt
	;;
esac

