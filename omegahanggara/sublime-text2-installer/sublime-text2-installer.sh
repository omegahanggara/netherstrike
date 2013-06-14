#!/bin/bash

# Variable
arch=$(uname -m)
url32="http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.1.tar.bz2"
url64="http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.1%20x64.tar.bz2"
extractOutput=

# Function
cin() {
	if [ "$1" == "action" ] ; then output="\e[01;32m[>]\e[00m" ; fi
	if [ "$1" == "info" ] ; then output="\e[01;33m[i]\e[00m" ; fi
	if [ "$1" == "error" ] ; then output="\e[01;31m[!]\e[00m" ; fi
	output="$output $2"
	echo -en "$output"
}

cout() {
	if [ "$1" == "action" ] ; then output="\e[01;32m[>]\e[00m" ; fi
	if [ "$1" == "info" ] ; then output="\e[01;33m[i]\e[00m" ; fi
	if [ "$1" == "error" ] ; then output="\e[01;31m[!]\e[00m" ; fi
	output="$output $2"
	echo -e "$output"
}

interrupt() {
	cout info "CAUGHT INTERRUPT SIGNAL!!!"
	sleep 2
	cout action "Removing junk file..."
	command -v sublime > /dev/null
	if [[ $? -eq 0 ]]; then
		if [[ $runAsRoot ]]; then
			if [[ -d /opt/SublimeText2 ]]; then
				rm -rf /opt/SublimeText2 $(which sublime) 2&>1 /dev/null
			else
				rm -rf $(which sublime) 2&>1 /dev/null
			fi
		else
			if [[ -d ~/Applications/SublimeText2 ]]; then
				rm -rf ~/Applications/SublimeText2 $(which sublime) 2&>1 /dev/null
			else
				rm -rf $(which sublime) 2&>1 /dev/null
			fi
		fi
	else
		if [[ $runAsRoot ]]; then
			if [[ -d /opt/SublimeText2 ]]; then
				rm -rf /opt/SublimeText2 2&>1 /dev/null
			else
				cout info "You haven't done anything yet!"
			fi
		else
			if [[ -d ~/Applications/SublimeText2 ]]; then
				rm -rf ~/Applications/SublimeText2 2&>1 /dev/null
			else
				cout info "You haven't done anything yet!"
			fi
		fi
	fi
	cout action "Quiting..."
	sleep 1
	exit 1
}

checkroot() {
	if [[ $(whoami) == "root" ]]; then
		cout action "Check root complete"
		extractOutput=/opt/
		runAsRoot=true
	else
		cout info "You don't have root privilege. It's OK tho"
		sleep 1
		cout action "Your Sublime can be found on yout HOME directory"
		sleep 1
		cout info "Anyway, you may need to provide your password to gain root privilege on installation section"
		extractOutput=~/Applications/
	fi
}

checkarch() {
	cout action "Checking your architecture..."
	sleep 1
	if [[ $arch == "i686" ]]; then
		cout info "your architecture is 32bit."
	elif [[ $arch == "x86_64" ]]; then
		cout info "Your architecture is 64bit."
	else
		cout error "Sorry, we don't have Sublime Text for your architecture yet. Please wait for update."
		cout info "Quiting..."
		sleep 1
		exit 1
	fi
}

checkdownloader() {
	command -v curl > /dev/null
	if [[ $? = 0 ]]; then
		downloader=curl
	else
		command -v wget > /dev/null
		if [[ $? = 0 ]]; then
			downloader=wget
		else
			command -v axel > /dev/null
			if [[ $? = 0 ]]; then
				downloader=axel
			else
				setdownloader
			fi
		fi
	fi
}

setdownloader() {
	cout action "Checking list of available downloader on your machine..."
	for apps in $(dpkg -l | grep 'ii  curl\|ii  wget\|ii  axel' | awk {'print $2'}); do
		if [[ $apps == "" ]]; then
			cout error "You don't have any downloader on your machine."
			askForInstall=true
			while [[ $askForInstall == "true" ]]; do
				cin info "Do you want to install one of them (Y/n): "
				read answerForInstall
				if [[ $answerForInstall == *[Yy]* ]] || [[ $answerForInstall == "" ]]; then
					echo "[1] curl"
					echo "[2] wget"
					echo "[3] axel"
					cin info "Please select one of them (1-3): "
					read answerForApp
					askForApp=true
					while [[ $askForApp == true ]]; do
						if [[ $answerForApp == "1" ]]; then
							cout action "Installing curl..."
							sleep 1
							sudo apt-get install curl
							cout action "Setup curl as your downloader..."
							sleep 1
							downloader=curl
							askForApp=false
						elif [[ $answerForApp == "2" ]]; then
							cout action "Installing wget..."
							sleep 1
							sudo apt-get install wget
							cout action "Setup wget as your downloader..."
							sleep 1
							downloader=wget
							askForApp=false
						elif [[ $answerForApp == "3" ]]; then
							cout action "Installing axel..."
							sleep 1
							sudo apt-get install axel
							cout action "Setup axel as your downloader..."
							sleep 1
							downloader=axel
							askForApp=false
						else
							cout error "Input error..."
						fi
					done
				elif [[ $answerForInstall == *[Nn]* ]]; then
						cout info "Suit yourself... Anyway, I can't procceed to next step if you don't have any downloader on your machine."
						cout action "Quiting..."
						sleep 1
						exit 1
				fi
			done
		else
			cout info "Found $apps"
			downloader=$(for app in $(dpkg -l | grep 'ii  curl\|ii  wget\|ii  axel' | awk {'print $2'}); do echo $app; done | head -1)
			cout action "Setup $downloader as your downloader"
		fi
	done
}

checkSource() {
	if [[ ! -f /tmp/Sublime.tar.bz2 ]]; then
		download_package
	fi
}

download_package() {
	cout action "Downloading package... This will take several minutes, depend on your connection"
	if [[ $arch == "i686" ]]; then
		if [[ $downloader == "curl" ]]; then
			$downloader $url32 -o /tmp/Sublime.tar.bz2
		elif [[ $downloader == "wget" ]]; then
			$downloader $url32 -O /tmp/Sublime.tar.bz2
		elif [[ $downloader == "axel" ]]; then
			$downloader $url32 -o /tmp/Sublime.tar.bz2
		fi
	else
		if [[ $downloader == "curl" ]]; then
			$downloader $url64 -o /tmp/Sublime.tar.bz2
		elif [[ $downloader == "wget" ]]; then
			$downloader $url64 -O /tmp/Sublime.tar.bz2
		elif [[ $downloader == "axel" ]]; then
			$downloader $url64 -o /tmp/Sublime.tar.bz2
		fi
	fi
	cout info "Done... File saved in /tmp/Sublime.tar.bz2"
}

installIcon() {
	echo -e "[Desktop Entry]
Name=Sublime Text 2
GenericName=Text Editor
Comment=The genius ways to code your life
Exec=/usr/bin/sublime
Icon=`echo $extractOutput`SublimeText2/Icon/256x256/sublime_text.png
Terminal=false
Type=Application
Categories=GNOME;GTK;Utility;TextEditor;Development;" > sublime.desktop
sudo mv sublime.desktop /usr/share/applications/sublime.desktop
}

extract_package() {
	cout action "Looking up target file..."
	if [[ ! -f /tmp/Sublime.tar.bz2 ]]; then
		cout error "File not found! Quiting..."
		sleep 1
		exit 1
	else
		cout action "Extracting package..."
		sleep 1
		tar -xvf /tmp/Sublime.tar.bz2 -C /tmp
		if [[ ! $? -eq 0 ]]; then
			cout error "Cannot extract your package!"
			exit 1
		fi
		cout action "Moving file..."
		sleep 1
		if [[ $extractOutput == ~/Applications/ ]]; then
			cout action "Checking Applications directory in your HOME directory..."
			if [[ ! -d ~/Applications ]]; then
				cout error "Applications directory not found!"
				sleep 1
				cout info "Creating Applications directory in your HOME directory..."
				sleep 1
				mkdir ~/Applications
				cout info "Done..."
				sleep 1
			fi
		fi
		mv /tmp/Sublime\ Text\ 2 $extractOutput/SublimeText2
		if [[ ! $? -eq 0 ]]; then
			cout error "Cannot moving"
			exit 1
		fi
		cout action "Creating linksys..."
		sleep 1
		sudo ln -sf $extractOutput/SublimeText2/sublime_text /usr/bin/sublime
		if [[ ! $? -eq 0 ]]; then
			exit 1
        fi
        installIcon
		cout info "Your sublime binary can be found on $extractOutput"		
		sleep 1
		cout info "Done... You can open your sublime by typing 'sublime' (without quotes) in your terminal, or launcher"
		sleep 1
		cout info "Bye..."
		exit 0
	fi
}
trap 'interrupt' INT
checkroot
sleep 1
checkarch
sleep 1
checkdownloader
sleep 1
checkSource
sleep 1
extract_package