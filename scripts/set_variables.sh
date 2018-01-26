#
# ser_variables.sh file - PSOPT Installer
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

BINARY="$PWD/binary"

export PSOPT_ROOT_DIR="$PWD/psopt"

export PATH="$BINARY/bin:$PATH"
export LD_LIBRARY_PATH="$BINARY/lib:$BINARY/lib64:$LD_LIBRARY_PATH"
export LIBRARY_PATH="$LD_LIBRARY_PATH:$LIBRARY_PATH"
CXXFLAGS="-I$BINARY/include "
CXXFLAGS+="-I$BINARY/include/lusol $CXXFLAGS"
CXXFLAGS+="-I$BINARY/include/cxsparse $CXXFLAGS"
export CXXFLAGS+="-I$BINARY/include/coin $CXXFLAGS"
export LDFLAGS="-L$BINARY/lib -L$BINARY/lib64"


