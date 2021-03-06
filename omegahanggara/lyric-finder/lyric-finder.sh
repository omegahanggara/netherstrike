#!/usr/bin/env bash

# Variable #
artist=
song=
azlyricURL="http://www.azlyrics.com/lyrics/"
fullURL=
version="Alpha 1"
codename="Ravage"

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
	artist=$(echo $inputArtist | sed 's/ //g' | tr 'A-Z' 'a-z' | sed "s/'//g")
}

function askSong()
{
	cin info "Enter song here : "
	read inputSong
	song=$(echo $inputSong | sed 's/ //g' | tr 'A-Z' 'a-z' | sed "s/'//g")
	fullURL=$azlyricURL/$artist/$song.html
}

function doCurl()
{
	curl --silent --user-agent "Mozilla/4.73 [en] (X11; U; Linux 2.2.15 i686)" $fullURL
}

function getLyric()
{
	cout action "Finding lyric..."
	doCurl | grep -n " start of lyrics" > /dev/null 2>&1
	if [[ $? -eq 1 ]]; then
		cout warning "Lyric is not found!"
		askToTypeAgain=true
		while [[ $askToTypeAgain == "true" ]]; do
			echo "1. I got typo"
			echo "2. Help me to find it"
			cin info "Choose your option: "
			read answerToTypeAgain
			if [[ $answerToTypeAgain == "1" ]]; then
				askToTypeAgain=false
				askArtist
				askSong
			elif [[ $answerToTypeAgain == "2" ]]; then
				askToTypeAgain=false
				cout action "Find a solution based on what you type..."
				sleep 1
				artisToBeSearched=$(echo $inputArtist | sed 's/ /+/g' | tr 'A-Z' 'a-z')
				cout info "Your artist = $inputArtist"
				sleep 1
				songToBeSearched=$(echo $inputSong | sed 's/ /+/g' | tr 'A-Z' 'a-z')
				cout info "Your song = $inputSong"
				sleep 1
				findSolution
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
			echo "1. Save the lyric"
			echo "2. Show lyric instead saving it"
			cin info "What we do with this result? "
			read answerToSave
			if [[ $answerToSave == "1" ]]; then
				askToSave=false
				if [[ -d "$HOME/Lyric" ]]; then
					doCurl | sed -n "$from,$to"p | sed 's/<[^>]\+>//g' > "$HOME/Lyric/$inputArtist-$inputSong.txt"
				else
					cout warning "Lyric folder is not found in your $HOME directory! Create a new one..."
					sleep 1
					mkdir $HOME/Lyric
					doCurl | sed -n "$from,$to"p | sed 's/<[^>]\+>//g' > "$HOME/Lyric/$inputArtist-$inputSong.txt"
				fi
				cout info "The result saved on your $HOME/Lyric directory with name $inputArtist-$inputSong.txt"
			elif [[ $answerToSave == "2" ]]; then
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

function findSolution()
{	
	keyword="$artisToBeSearched+$songToBeSearched"
	googleURL="http://www.google.com/search?q=$keyword"
	solutionresult=$(curl --silent --user-agent "Mozilla/4.73 [en] (X11; U; Linux 2.2.15 i686)" $googleURL | awk -F "Showing results for" {'print $2'} | awk -F "Search instead for" {'print $1'} | awk -F '=UTF-8">'  {'print $2'} | sed 's/<[^>]\+>//g' | head)
	if [[ $solutionresult == "" ]]; then
		cout warning "WTF, that song doesn't exsist!"
	else
		cout info "Based on google search, I found a solution below this: $(echo $solutionresult)"
		askToValidatingTheSolution=true
		while [[ $askToValidatingTheSolution == "true" ]]; do
			cin info "Is that you mean? (Y/n) "
			read answerToValidatingTheSolution
			if [[ $answerToValidatingTheSolution == *[Yy]* ]] || [[ $answerToValidatingTheSolution == "" ]]; then
				askToValidatingTheSolution=false
				cout info "OK"
				newKeyword=$(echo $solutionresult | sed 's/ /+/g')
				googleURL="http://www.google.com/search?q=$newKeyword+azlyrics"
				baseURL="http://www.azlyrics.com"
				lyricsURL=$(curl --silent --user-agent "Mozilla/4.73 [en] (X11; U; Linux 2.2.15 i686)" $googleURL | awk -F "http://www.azlyrics.com" {'print $2'} | awk -F "&amp" {'print $1'})
				fullURL=$(echo $baseURL$lyricsURL | sed 's/ //g')			
				getLyric
			elif [[ $answerToValidatingTheSolution == *[Nn]* ]]; then
				askToValidatingTheSolution=false
				cout info "WTF"
			else
				cout warning "I can't find a solution, quiting!"
				sleep 1
				exit 1
			fi
		done
	fi
}

doAll()
{
	checkInternetConnection
	askArtist
	askSong
	getLyric
}

version()
{
	echo $version
}

about()
{
	echo "######################################"
	echo "### Lyric Finder by Omega Hanggara ###"
	echo "###        Version $version         ###"
	echo "###        Codename $codename         ###"
	echo "######################################"
	echo ""
}

usage()
{
	about
	echo "Option"
	echo "-i : Using interactive mode"
	echo "-h : Show help option"
	echo ""
	cout info "Usage : bash lyric-finder.sh [OPTION]"
}

# Main Program #
case $1 in
	-i)
		doAll
		;;
	-h)
	usage
		;;
	-v)
	version
		;;
	*)
	usage
		;;
esac