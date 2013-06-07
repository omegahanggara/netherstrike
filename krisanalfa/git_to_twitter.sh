#!/usr/bin/env bash
# Author: Krisan Alfa Timur

command -v twidge > /dev/null
if [[ $? -eq 0 ]]; then
    if [[ -d .git ]]; then
        read_git_hub=$(cat .git/config | grep github);
        if [[ $read_git_hub == "" ]]; then
            echo "This commit will not posted on Twitter";
            git push origin master
        else
            hashtag=$(cat .git/config | grep url | awk -F: '{print $2}' | sed 's/\.git$//g' | awk -F/ '{print $2}');
            repo=$(cat .git/config | grep url | awk -F: '{print $2}' | sed 's/\.git$//g');
            github_url="https://www.github.com";
            comit_message=$(git log --pretty=oneline | head -n 1 | cut -d\  -f2-);
            rev_number=$(git log --pretty=oneline | head -n 1 | awk -F ' ' '{print $1}');
            url="$github_url/$repo/commit/$rev_number";
            echo "Will be posted on Twitter"
            echo "GitHub URL = $url";
            echo "Commit message = $comit_message";
            twidge update "Update on $hashtag. $comit_message $url #$hashtag";
            git push origin master
        fi
    else
        echo "Not in git repo folder. Exiting."
    fi
else
    echo "You don't have twidge installed on your system. Please Googling to find out how."
fi
