#!/bin/env bash
#
# Bing上获取每日壁纸, 按小时循环设置
#
if ! which curl > /dev/null;
then
    echo "curl Not Installed"
    exit
fi

if ! which feh > /dev/null;
then
   echo "feh Not Installed"
   exit
fi

if ! which jq > /dev/null;
then
    echo "jq Not Installed"
    exit
fi

marketoption=("en-US" "zh-CN" "ja-JP" "en-AU" "en-UK" "de-DE" "en-NZ" "en-CA")
directory="$HOME/Pictures/Bing Wallpaper"
resolution=$(xrandr |grep "*" |awk '{print $1}')
host="http://global.bing.com"
idx=-1 #  -1 today, 0 tomorrow 1 the day before yesterday
mkdir -p "$directory"

for market in ${marketoption[*]}
do
    file="$directory/$(date +%y%m%d)_$market.jpg"

    if [ -f "$file" ]
    then
        continue
    else
        url="/HPImageArchive.aspx?format=js&idx=$idx&n=1&pid=hp&FORM=HPCNEN&setmkt=$market&setlang=zh-CN&video=0&quiz=1&fav=1"
        imgurl=$(curl -s $host$url | jq -r '.images[0].url')
        if [ -n $imgurl ]
        then
            try=0
            while [ $try -lt 5 ]
            do
                imgurl=$(echo $imgurl | sed "s/1920x1080/$resolution/")
                if curl -s $host$imgurl -o "$file"
                then
                    break
                else
                    try=$(( $try + 1 ))
                    echo "try $try to fetch: $host$imgurl"
                    sleep 5
                fi
            done
        fi
    fi
done

choose=$(( $(date +%-H)%${#marketoption[@]} ))
market=${marketoption[$choose]}
img="$directory/$(date +%y%m%d)_$market.jpg"
if [ -f "$img" ]
then
    DISPLAY=:0.0 feh --bg-fill "$img"
fi
