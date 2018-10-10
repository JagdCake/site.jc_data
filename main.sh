#!/bin/bash

# enter "download" to download data
# enter "generate" to generate data
# enter "show" to display the collected data
mode="$1"

### File Paths ###
movies_html_file=~/Documents/web_dev/3_my_sites/iwam/index.html

movie_ids_file=./processed_data/movie_ids
director_ids_file=./processed_data/director_ids

genres_file=./processed_data/genres
runtimes_file=./processed_data/runtimes
years_file=./processed_data/years

# datafiles
# basic movie information
basics_data=./raw_data/title.basics.tsv
# ids of the director(s) and writer(s)
crew_data=./raw_data/title.crew.tsv
# basic person information
names_data=./raw_data/name.basics.tsv
### ###

download_data() {
    datafiles=('https://datasets.imdbws.com/title.basics.tsv.gz' 'https://datasets.imdbws.com/title.crew.tsv.gz' 'https://datasets.imdbws.com/name.basics.tsv.gz')

    for datafile in "${datafiles[@]}"; do
        wget -P ~/Desktop/ "$datafile"
    done &&
    unpigz ~/Desktop/*.tsv.gz

    cd ./raw_data/
    ln -s ~/Desktop/*.tsv 2>/dev/null
}

find_movie_ids() {
    # find all IMDb IDs
    rg -o -N -e "(tt\d{7}/\?)|(tt\d{7}/\")" "$html_file" | awk -F'/' '{ print $1 }' >> "$movie_ids_file"
}

find_director_ids() {
    for id in $(bat "$movie_ids_file"); do
        # finds the IDs of directors
        rg "$id" "$crew_data" | awk -F"\t" '{ print $2 }' >> "$director_ids_file"
    done

    sed -i 's/,/\n/g' "$director_ids_file"
}

find_genres() {
    for id in $(bat "$movie_ids_file"); do
        # finds the main genre
       rg "$id" "$basics_data" | awk -F"\t" '{ print $9 }' | awk -F',' '{ print $1 }' >> "$genres_file"
    done
}

find_runtimes() {
    for id in $(bat "$movie_ids_file"); do
        # finds the runtimes in minutes
        rg "$id" "$basics_data" | awk -F"\t" '{ print $8 }' >> "$runtimes_file"
    done
}

find_years() {
    for id in $(bat "$movie_ids_file"); do
        # finds the release year
        rg "$id" "$basics_data" | awk -F"\t" '{ print $6 }' >> "$years_file"
    done
}

show_number_of() {
    x_file="$1"
    # total number of items to display
    # (enter a number higher than the amount of items to show all items)
    total=$2

    # display the number (from highest to lowest) of movies for every X property
    sort "$x_file" | uniq -c | sort -nr | head -n $total
}

calc_hours_and_minutes() {
    minutes=$1

    ((hours=$minutes/60))
    ((minutes=$minutes%60))
}

show_runtimes() {
    total_minutes=$(awk '{ s+=$1 } END { print s }' "$runtimes_file")
    calc_hours_and_minutes $total_minutes
    echo "I've watched movies for a total of $hours hours and $minutes minutes."

    longest_minutes=$(sort -n "$runtimes_file" | tail -n 1)
    calc_hours_and_minutes $longest_minutes
    echo "Longest movie: $hours hours and $minutes minutes."

    runtimes_number=$(bat "$runtimes_file" | wc -l)
    ((average_in_minutes=$total_minutes/$runtimes_number))
    calc_hours_and_minutes $average_in_minutes
    echo "Average runtime: $hours hours $minutes minutes."
}

if [ "$mode" == 'download' ]; then
    download_data
elif [ "$mode" == 'generate' ]; then
    find_movie_ids
    find_director_ids
    find_genres
    find_runtimes
    find_years
elif [ "$mode" == 'show' ]; then
    show_number_of "$genres_file" 3
    show_number_of "$years_file" 3
    show_runtimes
fi

