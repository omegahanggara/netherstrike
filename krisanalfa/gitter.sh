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

python -c "print 2*2";
exit;
# Some public variable
WORKING_DIR=$(pwd);
IS_CONNECTED=false;
IS_ROOT=false;
DISTRO="";

# Usage: cin [variable] [messsage] <callback>
cin() {
    if [ $1 != "" ]; then
        output="\e[01;30m[?]\e[00m"
    else
        cout error "No variable given as arguments."
        exit 1;
    fi
    output="$output $2";
    echo -en "$output";
    read $1;
    if [[ $3 != "" ]]; then $3; fi
}

# Usage: cout [type] [message]
cout() {
    if [ "$1" == "action" ]; then output="\e[01;32m[>]\e[00m"; fi
    if [ "$1" == "info" ]; then output="\e[01;33m[i]\e[00m"; fi
    if [ "$1" == "error" ]; then output="\e[01;31m[!]\e[00m"; fi
    output="$output $2"
    echo -e "$output"
}

welcome() {
    while [[ true ]]; do
        cout info "Welcome!";
    echo -e "1. Initialize an empty repo.
2. Check status of current repo.
x. Exit."
        cin choice "Please select option: ";
        case $choice in
            1 ) initialize ;;
            2 ) status ;;
            x ) quit ;;
            * ) cout error "Error input $choice" ;;
        esac
    done
}

quit() {
    cout info "Bye bye...";
    exit 0;
}

# Usage initialize <project_name> <options>
initialize() {
    project_name=$(echo $@ | sed -e 's/--init\|-n//g' -e 's/[ ]//g');
    check_no_readme=$(echo $@ | grep -we "--no-readme\|-n");
    noreadme="false";
    echo $@;
    exit;
    if [[ $check_no_readme != "" ]]; then noreadme="true"; fi;
    if [[ $project_name != "" ]]; then
        if [[ -d $project_name ]]; then
            cout error "There is \`$1' folder in $WORKING_DIR, cannot continue.";
        else
            cout action "Creating \`$1' folder in \`$WORKING_DIR'";
            # mkdir $project_name;
            # cd $project_name;
            cout action "Initializing git repo";
            # git init;
            if [[ $noreadme == "false" ]]; then
                cout action "Launching $EDITOR";
                # $EDITOR README.md;
            fi
            # if [[ $WORKING_DIR != $OLDPWD ]]; then cd - 2>&1 /dev/null; true; fi;
        fi
    else
        cout info "Wizard will running";
        cin project_name "Enter name of your project: ";
        while [[ $loop != "false" ]]; do
            cin readme_md "Do you want to create README.md file for your new Git Repo? [Y|n]: ";
            case $readme_md in
                ''|Y|y ) initialize $project_name ; loop="false"; ;;
                    N|n) initialize "$project_name" "--no-readme"; loop="false"; ;;
                     * ) cout error "Invalid choice: $readme_md"; ;;
            esac
        done
    fi
}

# Program run

# Setting variable
wget www.google.com -q
if [[ $? -eq 0 ]]; then IS_CONNECTED=true; rm index.html; fi;
if [[ $(whoami) == "root" ]]; then IS_ROOT=true; fi
if [[ $EDITOR == "" ]]; then set_editor; fi;

set_editor() {
    command -v nano > /dev/null;
    if [[ $? -eq 0 ]]; then
        export $EDITOR=nano
    else
        command -v pico > /dev/null;
        if [[ $? -eq 0 ]]; then
            export $EDITOR=pico;
        else
            command -v vim > /dev/null;
            if [[ $? -eq 0 ]]; then
                export $EDITOR=vim;
            else
                command -v vi > /dev/null;
                if [[ $? -eq 0 ]]; then
                    export $EDITOR=vi;
                else
                    cout error "Cannot find any text editor for you.
You can ignore this message, but some function will cannot be applied.";
                fi
            fi
        fi
    fi
}

set_editor;
if [[ $(echo $@ | grep 'init') != '' ]]; then
    option=$(echo $@ | awk '{print $3}');
    project_name=$(echo $@ | awk '{print $2}');
    if [[ $option == "" ]]; then
        cout info "Will init without option";
    else
        cout info "Will init with option $option";
    fi
fi
# Some basic args you can use
# case $1 in
#     --init|-i ) initialize $1 $2 $3;;
#     * ) welcome ;;
# esac
