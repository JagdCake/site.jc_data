#!/bin/bash

# enter regen to regenerate the data
# enter download to download new data
mode="$1"

html_file=~/Documents/web_dev/3_my_sites/iwam/index.html
ids_file=./processed_data/ids
genres_file=./processed_data/genres
runtimes_file=./processed_data/runtimes
# basic movie information
basics_file=./raw_data/title.basics.tsv

download_data() {
    wget -P ~/Desktop/ 'https://datasets.imdbws.com/title.basics.tsv.gz' &&
    unpigz ~/Desktop/title.basics.tsv.gz

    cd ./raw_data/
    ln -s ~/Desktop/title.basics.tsv 2>/dev/null
}

find_ids() {
    # find all IMDb IDs
    rg -o -N -e "(tt\d{7}/\?)|(tt\d{7}/\")" "$html_file" | awk -F'/' '{ print $1 }' >> "$ids_file"
}

find_genres() {
    for id in $(bat "$ids_file"); do
        # finds the main genre
       rg "$id" "$basics_file" | awk -F"\t" '{ print $9 }' | awk -F',' '{ print $1 }' >> "$genres_file"
    done
}

find_runtimes() {
    for id in $(bat "$ids_file"); do
        # finds the runtimes in minutes
        rg "$id" "$basics_file" | awk -F"\t" '{ print $8 }' >> "$runtimes_file"
    done
}

if [ "$mode" == 'regen' ]; then
    find_ids
    find_genres
    find_runtimes
elif [ "$mode" == 'download' ]; then
    download_data
fi

show_genres() {
    # display the number (from highest to lowest) of movies from every genre
    sort "$genres_file" | uniq -c | sort -nr
}

show_runtimes() {
    total_minutes=$(awk '{ s+=$1 } END { print s }' "$runtimes_file")
    ((hours=$total_minutes/60))
    ((minutes=$total_minutes%60))
    echo "I've watched movies for a total of $hours hours and $minutes minutes."

    longest_minutes=$(sort -n "$runtimes_file" | tail -n 1)
    ((hours=$longest_minutes/60))
    ((minutes=$longest_minutes%60))
    echo "Longest movie: $hours hours and $minutes minutes."
}

