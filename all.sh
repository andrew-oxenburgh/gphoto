#/!/bin/bash

DIR=./output

mkdir -p $DIR/
rm $DIR/*

echo "don't be impatient. This takes a while..."


# list all albums
# {"Path":"17 February 2013","Name":"17 February 2013","Size":-1,"MimeType":"inode/directory","ModTime":"2024-01-14T12:12:00+13:00","IsDir":true,"ID":"AHcsUy2nWqey-I0dC15otspu0JK2Z8rqVo0bBwK9rA-hdB_8gmG35MI6iKpHxzQBazzw5nYlhw-s"},
rclone lsjson -R gphoto:album > $DIR/album-names.json

# all photos in albums
rclone lsjson -R gphoto:album/ > $DIR/album-photos.json

# list all photos anywhere
# {"Path":"20200429_090441.jpg","Name":"20200429_090441.jpg","Size":-1,"MimeType":"image/jpeg","ModTime":"2020-04-28T21:04:40Z","IsDir":false,"ID":"AHcsUy0oaBwZGmfIaLLCd05mIioZv-WPkKVIV4QnJnnxKmJwK6rDq4MWv6MDwR9RRAlP-PZ7IzAddXsdGlpERAid6GZbOe-ecA"},
rclone lsjson -R gphoto:media/all > $DIR/photos-all.json
