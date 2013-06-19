#!/usr/bin/env bash

# Variable #

# Function #
function cin() {
	if [ "$1" == "action" ] ; then output="\e[01;32m[>]\e[00m" ; fi
	if [ "$1" == "info" ] ; then output="\e[01;33m[i]\e[00m" ; fi
	if [ "$1" == "warning" ] ; then output="\e[01;31m[w]\e[00m" ; fi
	if [ "$1" == "error" ] ; then output="\e[01;31m[e]\e[00m" ; fi
	output="$output $2"
	echo -en "$output"
}
 
function cout() {
	if [ "$1" == "action" ] ; then output="\e[01;32m[>]\e[00m" ; fi
	if [ "$1" == "info" ] ; then output="\e[01;33m[i]\e[00m" ; fi
	if [ "$1" == "warning" ] ; then output="\e[01;31m[w]\e[00m" ; fi
	if [ "$1" == "error" ] ; then output="\e[01;31m[e]\e[00m" ; fi
	output="$output $2"
	echo -e "$output"
}

function checkInternetConnection()
{
	cout action "Checking Internet Connection..."
	sleep 1
	command -v dig > /dev/null 2>&1
	if [[ $? = 0 ]]; then
		dig www.google.com +time=3 +tries=1 @8.8.8.8 > /dev/null 2>&1
		if [[ $? -eq 0 ]]; then
			cout info "Good, you have Internet Connection..."
			azlyricURL="http://www.azlyrics.com/lyrics"
		else
			cout error "You don't have Internet Connection!"
			sleep 1
			cout info "This script requiring Internet Connection!"
			sleep 1
			cout info "Make sure you have Internet Connection, then execute this script again"
			sleep 1
			cout action "Quiting..."
			sleep 2
			exit 1
		fi
	fi
}

function askArtist()
{
	cin info "Enter artist's name here : "
	read inputArtist
	typoArtist=true
	while [[ $typoArtist == "true" ]]; do
		cin info "Typo? (y/N) "
		read answerTypoArtist
		if [[ $answerTypoArtist == *[Yy]* ]]; then
			typoArtist=false
			askArtist
		elif [[ $answerTypoArtist == *[Nn]* ]] || [[ $answerTypoArtist == "" ]]; then
			typoArtist=false
			cout info "Your artist is $inputArtist"
			artist=$(echo $inputArtist | sed 's/ //g' | tr 'A-Z' 'a-z')
		else
			typoArtist=true
		fi
	done
}

function askSong()
{
	cin info "Enter song here : "
	read inputSong
	typoSong=true
	while [[ $typoSong == "true" ]]; do
		cin info "Typo? (y/N) "
		read answertypoSong
		if [[ $answertypoSong == *[Yy]* ]]; then
			typoSong=false
			askArtist
		elif [[ $answertypoSong == *[Nn]* ]] || [[ $answertypoSong == "" ]]; then
			typoSong=false
			cout info "Your song is $inputSong"
			song=$(echo $inputSong | sed 's/ //g' | tr 'A-Z' 'a-z')
		else
			typoSong=true
		fi
	done
}

function doCurl()
{
	curl --silent --user-agent "Mozilla/4.73 [en] (X11; U; Linux 2.2.15 i686)" $azlyricURL/$artist/$song.html
}

function getLyric()
{
	cout action "Finding lyric..."
	doCurl | grep -n " start of lyrics" > /dev/null 2>&1
	if [[ $? -eq 1 ]]; then
		cout warning "Lyric is not found, check your artist and song again!"
		askToTypeAgain=true
		while [[ $askToTypeAgain == "true" ]]; do
			cout info "Type again? (Y/n) "
			read answerToTypeAgain
			if [[ $answerToTypeAgain == *[Yy]* ]] || [[ $answerToTypeAgain == "" ]]; then
				askToTypeAgain=false
				askArtist
				askSong
			elif [[ $answerToTypeAgain == *[Nn]* ]]; then
				askToTypeAgain=false
				cout warning "Quiting..."
				sleep 1
				exit 1
			else
				cout warning "Please type a valid answer!"
			fi
		done
	else
		cout info "Lyric found..."
		from=$(doCurl | grep -n "start of lyrics" | awk -F ':' {'print $1'})
		to=$(doCurl | grep -n "end of lyrics" | awk -F ':' {'print $1'})
		askToSave=true
		while [[ $askToSave == "true" ]]; do
			cin info "Do you want to save the result? (Y/n) "
			read answerToSave
			if [[ $answerToSave == *[Yy]* ]] || [[ $answerToSave == "" ]]; then
				askToSave=false
				doCurl | sed -n "$from,$to"p | sed 's/<[^>]\+>//g' > $HOME/$song.txt
				cout info "The result saved on your $HOME directory with name $song.txt"
			elif [[ $answerToSave == *[Nn]* ]]; then
				askToSave=false
				cout action "Print the result..."
				sleep 1
				reset
				doCurl | sed -n "$from,$to"p | sed 's/<[^>]\+>//g'
			else
				cout warning "Choose a valid answer!"
			fi
		done
	fi
}

# Main Program #
checkInternetConnection
askArtist
askSong
getLyric