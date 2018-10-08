#!/bin/bash

# enter regen to regenerate the data
# enter download to download new data
mode="$1"

html_file=~/Documents/web_dev/3_my_sites/iwam/index.html

download_data() {
    cd ./raw_data/
    wget -P https://datasets.imdbws.com/title.basics.tsv.gz && unpigz title.basics.tsv.gz

    cd ..
    basics_file=./raw_data/title.basics.tsv
}

find_ids() {
    # find all IMDb IDs
    ids=($(rg -o -N -e "(tt\d{7}/\?)|(tt\d{7}/\")" "$html_file" | awk -F'/' '{ print $1 }'))
}

find_genres() {
    for id in "${ids[@]}"; do
        # finds the main genre
       rg "$id" "$basics_file" | awk -F"\t" '{ print $9 }' | awk -F',' '{ print $1 }' >> ./processed_data/genres
    done
}

if [ "$mode" == 'regen' ]; then
    find_ids
    find_genres
elif [ "$mode" == 'download' ]; then
    download_data
fi

# display the number of movies from every genre
sort genres | uniq -c

