#/!/bin/bash

# This is VERY rough little script.
# There are false positives, so be aware.
# gPhotos sometimes mangles the urls if there are 2 underscores in the query
# I hate bash scripts, but here we are

DIR=./calc
DIR_DL=$DIR/download
DIR_1=$DIR/step_1
DIR_2=$DIR/step_2

ALL_PHOTOS=all-photos
ALBUM_PHOTOS=album-photos

ALBUM_LIST=$DIR_2/$ALBUM_PHOTOS.txt
ALL_LIST=$DIR_2/$ALL_PHOTOS.txt

UNALBUMED_LIST=./unalbumed-files

GOOGLE_PHOTO_SEARCH=https://photos.google.com/search/

mkdir -p $DIR_DL/
mkdir -p $DIR_1/
mkdir -p $DIR_2/

rm -f $UNALBUMED_LIST.md

download() {
    echo "don't be impatient. This takes a while. Like a couple of minutes..."
    rm -f $DIR_DL/*

    # all photos in albums
    rclone lsjson -R gphoto:album/ >$DIR_DL/$ALBUM_PHOTOS.json

    # list all photos anywhere
    # {"Path":"20200429_090441.jpg","Name":"20200429_090441.jpg","Size":-1,"MimeType":"image/jpeg","ModTime":"2020-04-28T21:04:40Z","IsDir":false,"ID":"AHcsUy0oaBwZGmfIaLLCd05mIioZv-WPkKVIV4QnJnnxKmJwK6rDq4MWv6MDwR9RRAlP-PZ7IzAddXsdGlpERAid6GZbOe-ecA"},
    rclone lsjson -R gphoto:media/all >$DIR_DL/$ALL_PHOTOS.json
}

step_1() {
    rm -f $DIR_1/*

    cat $DIR_DL/$ALL_PHOTOS.json | jp [*].Name >$DIR_1/$ALL_PHOTOS.txt
    cat $DIR_DL/$ALBUM_PHOTOS.json | jp [*].Name >$DIR_1/$ALBUM_PHOTOS.txt
}

step_2() {
    rm -f $DIR_2/*

    cat $DIR_1/$ALBUM_PHOTOS.txt | gsed 's/^...//' | gsed 's/[,"]*$//' | sort -u >$DIR_2/$ALBUM_PHOTOS.txt
    cat $DIR_1/$ALL_PHOTOS.txt | gsed 's/^...//' | gsed 's/[,"]*$//' | sort -u >$DIR_2/$ALL_PHOTOS.txt
    comm -23 $ALL_LIST $ALBUM_LIST >$DIR_2/UNALBUMMED.txt
    gsed 's/^/https:\/\/photos.google.com\/search\//' $DIR_2/UNALBUMMED.txt >$UNALBUMED_LIST.md
    wc -l $UNALBUMED_LIST.md
}

help() {
    echo "Program: Creates a pretty rough list of urls of Google photos not in albums"
    echo "Output: a markdown file with urls to photos not in albums"
    echo "Requires: rclone (https://rclone.org/) to be installed and configured"
    echo "Requires: jp (https://github.com/jmespath/jp) to be installed"
    echo "Warning: Download will take a little while"
    echo "Usage: [options]"
    echo "Options:"
    echo "  -h, --help           Display this help message"
    echo "  -n, --no_download    don't do download"
}

NO_DOWNLOAD=DOWNLOAD
HELP=NO_HELP

for i in "$@"; do
    case $i in
    --no_download | -n)
        NO_DOWNLOAD=NO_DOWNLOAD
        shift # past argument=value
        ;;
    --help | -h)
        HELP=HELP
        shift # past argument=value
        ;;
    *) ;;
    esac
done

# echo $HELP
# echo $NO_DOWNLOAD

if [ "$HELP" = "HELP" ]; then
    help
    exit
fi

if [ "$NO_DOWNLOAD" = "DOWNLOAD" ]; then
    download
fi

step_1
step_2
