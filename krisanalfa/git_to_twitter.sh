#!/usr/bin/env bash
# Author: Krisan Alfa Timur

command -v twidge > /dev/null
if [[ $? -eq 0 ]]; then
    if [[ -d .git ]]; then
        read_git_hub=$(cat .git/config | grep github);
        if [[ $read_git_hub == "" ]]; then
            echo "This commit will not posted on Twitter";
            # git push origin master
        else
            git log --pretty=oneline > /dev/null 2>&1
            if [[ $? -eq 0 ]]; then
                hashtag=$(cat .git/config | grep url | awk -F: '{print $2}' | sed 's/\.git$//g' | awk -F/ '{print $2}');
                repo=$(cat .git/config | grep url | awk -F: '{print $2}' | sed 's/\.git$//g');
                github_url="https://www.github.com";
                comit_message=$(git log --pretty=oneline | head -n 1 | cut -d\  -f2-);
                rev_number=$(git log --pretty=oneline | head -n 1 | awk -F ' ' '{print $1}');
                url="$github_url/$repo/commit/$rev_number";
                tweets="Update on $hashtag. $comit_message $url #$hashtag";
                # echo "Will be posted on Twitter"
                # echo "GitHub URL: $url";
                # echo "Commit message = $comit_message";
                # echo "Hashtag: $hashtag";
                # echo "Your tweets: $tweets";
                echo -e "$tweets\n" >> ~/.githubTweets.lst;                  # logging
                # cat ~/.githubTweets.lst | uniq > ~/.githubTweets.lst   # removing duplicate entry
                # exist=$(cat ~/.githubTweets.lst | grep "$tweets");
                # echo $exist;
                # if [[ $exist == "" ]]; then
                #     twidge update "$tweets";
                #     echo "Posting to twitter."
                # else
                #     echo "You have tweet that tweet!"
                # fi
                # echo "Pushing codes to $github_url/$repo"
                # git push origin master
            else
                echo "You just initialize this repo and there is no commit for it."
            fi
        fi
    else
        echo "Not in git repo folder. Exiting."
    fi
else
    echo "You don't have twidge installed on your system. Please Googling to find out how."
fi
