#!/bin/bash

# enter regen to regenerate the data
mode="$1"

html_file=~/Documents/web_dev/3_my_sites/iwam/index.html
basics_file=./title.basics.tsv

find_ids() {
    # find all IMDb IDs
    ids=($(rg -o -N -e "(tt\d{7}/\?)|(tt\d{7}/\")" "$html_file" | awk -F'/' '{ print $1 }'))
}

find_genres() {
    for id in "${ids[@]}"; do
        # finds the main genre
       rg "$id" "$basics_file" | awk -F"\t" '{ print $9 }' | awk -F',' '{ print $1 }' >> ./genres
    done
}

if [ "$mode" == 'regen' ]; then
    find_ids
    find_genres
fi

# display the number of movies from every genre
sort genres | uniq -c

