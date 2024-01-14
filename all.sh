#/!/bin/bash

echo "do you want to download the latest? (y/n)"
read LATEST
echo It\'s nice to meet you $LATEST

DIR=./calc
DIR_DL=$DIR/download
DIR_1=$DIR/step_1
DIR_2=$DIR/step_2

ALL_PHOTOS=all-photos
ALBUM_PHOTOS=album-photos

ALBUM_LIST=$DIR_2/$ALBUM_PHOTOS.txt
ALL_LIST=$DIR_2/$ALL_PHOTOS.txt

UNALBUMED_LIST=$DIR/unalbumed-files

GOOGLE_PHOTO_SEARCH=https://photos.google.com/search/

mkdir -p $DIR_DL/
mkdir -p $DIR_1/
mkdir -p $DIR_2/

download(){
    echo "don't be impatient. This takes a while..."
    rm $DIR_DL/*

    # list all albums
    # {"Path":"17 February 2013","Name":"17 February 2013","Size":-1,"MimeType":"inode/directory","ModTime":"2024-01-14T12:12:00+13:00","IsDir":true,"ID":"AHcsUy2nWqey-I0dC15otspu0JK2Z8rqVo0bBwK9rA-hdB_8gmG35MI6iKpHxzQBazzw5nYlhw-s"},
    # rclone lsjson -R gphoto:album > $DIR_DL/album-names.json

    # all photos in albums
    rclone lsjson -R gphoto:album/ > $DIR_DL/$ALBUM_PHOTOS.json

    # list all photos anywhere
    # {"Path":"20200429_090441.jpg","Name":"20200429_090441.jpg","Size":-1,"MimeType":"image/jpeg","ModTime":"2020-04-28T21:04:40Z","IsDir":false,"ID":"AHcsUy0oaBwZGmfIaLLCd05mIioZv-WPkKVIV4QnJnnxKmJwK6rDq4MWv6MDwR9RRAlP-PZ7IzAddXsdGlpERAid6GZbOe-ecA"},
    rclone lsjson -R gphoto:media/all > $DIR_DL/$ALL_PHOTOS.json
}

step_1 (){
    rm -f $DIR_1/*

    cat $DIR_DL/$ALL_PHOTOS.json | jp [*].Name  > $DIR_1/$ALL_PHOTOS.txt
    cat $DIR_DL/$ALBUM_PHOTOS.json | jp [*].Name > $DIR_1/$ALBUM_PHOTOS.txt
}

step_2 (){
    rm -f $DIR_2/*

    cat $DIR_1/$ALBUM_PHOTOS.txt | gsed 's/^...//' | gsed 's/[,"]*$//' | sort -u > $DIR_2/$ALBUM_PHOTOS.txt

    cat $DIR_1/$ALL_PHOTOS.txt | gsed 's/^...//' | gsed 's/[,"]*$//' | sort -u > $DIR_2/$ALL_PHOTOS.txt

    comm -23 $ALL_LIST $ALBUM_LIST   > $DIR_2/UNALBUMMED.txt

    gsed 's/^/https:\/\/photos.google.com\/search\//' $DIR_2/UNALBUMMED.txt > $UNALBUMED_LIST.md
    wc -l $UNALBUMED_LIST.md
}

rm -f $UNALBUMED_LIST.md

if [ "$LATEST" = "y" ]
then
    download
    step_1
    step_2
else
    step_1
    step_2
fi
exit

# sed 's/^...\(.*\)...$/\1/' file.txt

# awk '{gsub(/^[[:space:]]*/, ""); $0 = substr($0, 4); gsub(/[",]+$/, ""); print}' file.txt > output.txt

# comm -23 <(sort file1.txt) <(sort file2.txt)

# echo '  "02022009012.jpg",' | grep -o '[^",]*' | tr -d ' '

# cat gsed 's/^...//' 's/["',]*$//' file.txt > output.txt