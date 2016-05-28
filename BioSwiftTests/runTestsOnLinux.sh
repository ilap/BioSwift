#!/bin/bash
#
#
# Author:
#    Pal Dorogi "ilap" <pal.dorogi@gmail.com>
#
# Copyright (c) 2016 Pal Dorogi
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# Build BioSwift first and change directory to UnitTest directory
PWD=`pwd`
MODULE=BioSwift
BUILD_PATH=../.build/debug/
MODULE_PATH=${BUILD_PATH}

if [ ! -d ${PWD}/Resources ]
then
    print "Command must be Run in the UnitTest directory."
    exit 1
fi



# Fix the compiler as it requires libprefix in linux
# So, soft link BioSwift.a to libBioSwift.a
ln -sf ./${MODULE}.a ${MODULE_PATH}/lib${MODULE}.a 2>/dev/null

swiftc -o BioSwiftTest -I${MODULE_PATH} -L${MODULE_PATH} -l${MODULE} *.swift



