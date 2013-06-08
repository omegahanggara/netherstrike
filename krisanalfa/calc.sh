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

prompt() {
    echo -en "Masukan angka pertama: ";
    read angka1;
    echo -en "Masukan angka kedua: ";
    read angka2;
    if [[ $1 == "x" ]]; then
        hitung \* $angka1 $angka2;
    else
        hitung $1 $angka1 $angka2;
    fi
}

# Usage hitung operation 1 2
hitung() {
    jumlah=$(python -c "print $2 $1 $3");
    echo $jumlah;
    exit;
}

while [[ true ]]; do
    echo "1. Penjumlahan
2. Pengurangan
3. Perkalian
4. Pembagian
X. Keluar"
    echo -en "Masukan pilihan: "
    read operasi;
    case $operasi in
        "1" ) prompt + ;;
        "2" ) prompt - ;;
        "3" ) prompt x ;;
        "4" ) prompt / ;;
        "x"|"X" ) exit ;;
        * ) echo "Pilihan salah!" ;;
    esac
done
