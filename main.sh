#!/bin/bash

# enter regen to regenerate the data
mode="$1"

html_file=~/Documents/web_dev/3_my_sites/iwam/index.html
basics_file=./title.basics.tsv


if [ "$mode" == 'regen' ]; then
    # find all IMDb IDs
    ids=($(rg -o -N -e "(tt\d{7}/\?)|(tt\d{7}/\")" "$html_file" | awk -F'/' '{ print $1 }'))

    for id in "${ids[@]}"; do
        # finds the main genre
       rg "$id" "$basics_file" | awk -F"\t" '{ print $9 }' | awk -F',' '{ print $1 }' >> ./genres
    done
fi

