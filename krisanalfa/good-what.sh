#!/usr/bin/env bash
########################################################################
# This program is free software: you can redistribute it and/or modify #
# it under the terms of the GNU General Public License as published by #
# the Free Software Foundation, either version 3 of the License, or    #
# (at your option) any later version.                                  #
#                                                                      #
# This program is distributed in the hope that it will be useful,      #
# but WITHOUT ANY WARRANTY; without even the implied warranty of       #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        #
# GNU General Public License for more details.                         #
#                                                                      #
# You should have received a copy of the GNU General Public License    #
# along with this program.  If not, see <http://www.gnu.org/licenses/>.#
########################################################################

myTime=$(date | awk '{print $4}' | awk -F: '{print $1}');
if [[ $myTime -gt 0 && $myTime -le 6 ]]; then echo "Selamat pagi"; fi;
if [[ $myTime -gt 6 && $myTime -le 12 ]]; then echo "Selamat siang"; fi;
if [[ $myTime -gt 12 && $myTime -le 18 ]]; then echo "Selamat sore"; fi;
if [[ $myTime -gt 18 ]]; then echo "Selamat malam"; fi;
