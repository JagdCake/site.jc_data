#!/bin/bash

# enter "download" to download data
# enter "generate" to generate data
# enter "show" to display the collected data
mode="$1"

### File Paths ###
movies_html_file=~/Documents/web_dev/3_my_sites/iwam/index.html

processed_data_dir="$(pwd)/processed_data/"
movie_ids_file="$processed_data_dir"/movie_ids
director_ids_file="$processed_data_dir"/director_ids
actor_ids_file="$processed_data_dir"/actor_ids

genres_file="$processed_data_dir"/genres
runtimes_file="$processed_data_dir"/runtimes
years_file="$processed_data_dir"/years
directors_file="$processed_data_dir"/directors
actors_file="$processed_data_dir"/actors
my_ratings_file="$processed_data_dir"/my_ratings
imdb_ratings_file="$processed_data_dir"/imdb_ratings

# datafiles
raw_data_storage_dir=~/Desktop/
raw_data_dir="$(pwd)/raw_data/"
# basic movie information
basics_data="$raw_data_dir"/title.basics.tsv
# ids of the director(s) and writer(s)
crew_data="$raw_data_dir"/title.crew.tsv
# basic person information
names_data="$raw_data_dir"/name.basics.tsv
# cast IDs and character names
cast_data="$raw_data_dir"/title.principals.tsv
# average ratings
ratings_data="$raw_data_dir"/title.ratings.tsv
### ###

download_data() {
    datafiles=('https://datasets.imdbws.com/title.basics.tsv.gz' 'https://datasets.imdbws.com/title.crew.tsv.gz' 'https://datasets.imdbws.com/name.basics.tsv.gz' 'https://datasets.imdbws.com/title.principals.tsv.gz' 'https://datasets.imdbws.com/title.ratings.tsv.gz')

    for datafile in "${datafiles[@]}"; do
        datafile_name=$(echo "$datafile" | awk -F'/' '{ print $NF }' | awk -F'.gz' '{ print $1 }')
        exa "$raw_data_dir"/"$datafile_name" > /dev/null 2>&1

        # check if the datafile hasn't already been downloaded
        if [ $? != 0 ]; then
            wget -P "$raw_data_storage_dir"/ "$datafile"
        fi
    done &&
    unpigz -q "$raw_data_storage_dir"/*.tsv.gz &&

    ln -s "$raw_data_storage_dir"/*.tsv "$raw_data_dir"/ 2>/dev/null
}

find_movie_ids() {
    # find all IMDb IDs
    rg -o -N -e "(tt\d{7}/\?)|(tt\d{7}/\")" "$movies_html_file" | awk -F'/' '{ print $1 }' >> "$movie_ids_file"
}

find_my_ratings() {
    ratings=('Bad Eggplant' 'Decent Carrot' 'Good Tomato' 'Great Onion' 'Amazing Savory' 'Sublime Lettuce')

    for rating in "${ratings[@]}"; do
        rg -o -N ">$rating<" "$movies_html_file" | sed -e 's/[>|<]//g' >> "$my_ratings_file"
    done
}

select_the_property() {
    if [ "$property" == 'director IDs' ]; then
        # finds the IDs of all directors
        awk -F"\t" '{ print $2 }'
    elif [ "$property" == 'genres' ]; then
        # finds the main genre
        awk -F"\t" '{ print $9 }' | awk -F"," '{ print $1 }'
    elif [ "$property" == 'runtimes' ]; then
        # finds the runtimes in minutes
        awk -F"\t" '{ print $8 }'
    elif [ "$property" == 'years' ]; then
        # finds the release year
        awk -F"\t" '{ print $6 }'
    elif [ "$property" == 'directors' ]; then
        # finds the name of every director
        awk -F"\t" '{ print $2 }'
    elif [ "$property" == 'actor IDs' ]; then
        # finds the IDs of the 2 top billed actors
        awk -F"\t" '{ print $3 }'
    elif [ "$property" == 'actors' ]; then
        # finds the names of the 2 top billed actors
        awk -F"\t" '{ print $2 }'
    elif [ "$property" == 'IMDb ratings' ]; then
        # finds the average IMDb rating
        awk -F"\t" '{ print $2 }'
    fi
}

find_the_property() {
    property="$1"

    if [ "$property" == 'director IDs' ]; then
        ids_file="$movie_ids_file"
        datafile="$crew_data"
        output_file="$director_ids_file"
    elif [ "$property" == 'genres' ]; then
        ids_file="$movie_ids_file"
        datafile="$basics_data"
        output_file="$genres_file"
    elif [ "$property" == 'runtimes' ]; then
        ids_file="$movie_ids_file"
        datafile="$basics_data"
        output_file="$runtimes_file"
    elif [ "$property" == 'years' ]; then
        ids_file="$movie_ids_file"
        datafile="$basics_data"
        output_file="$years_file"
    elif [ "$property" == 'directors' ]; then
        ids_file="$director_ids_file"
        datafile="$names_data"
        output_file="$directors_file"
    elif [ "$property" == 'actor IDs' ]; then
        ids_file="$movie_ids_file"
        datafile="$cast_data"
        output_file="$actor_ids_file"
    elif [ "$property" == 'actors' ]; then
        ids_file="$actor_ids_file"
        datafile="$names_data"
        output_file="$actors_file"
    elif [ "$property" == 'IMDb ratings' ]; then
        ids_file="$movie_ids_file"
        datafile="$ratings_data"
        output_file="$imdb_ratings_file"
    fi

    if [ "$property" != 'actor IDs' ]; then
        for id in $(bat "$ids_file"); do
            # adding the '-N' flag seems to make ripgrep a bit faster
            rg -N "$id" "$datafile" | select_the_property >> "$output_file"
        done
    else
        for id in $(bat "$ids_file"); do
            # search for the 2 top billed actors by their 'order' (1 and 2)
            rg -N -e ""$id"\t(1\t|2)" "$datafile" | select_the_property >> "$output_file"
        done
    fi

    if [ "$property" == 'director IDs' ]; then
        sed -i 's/,/\n/g' "$director_ids_file"
    fi
}

show_number_of() {
    x_file="$1"
    # total number of items to display
    # (enter a number higher than the amount of items to show all items)
    total=$2

    # display the number (from highest to lowest) of movies for every X property and show the output in a table
    sort "$x_file" | uniq -c | sort -nr | head -n $total | bat
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

show_imdb_ratings() {
    for rating in $(bat "$imdb_ratings_file"); do
        if [ $(echo "$rating >= 9" | bc -l) -eq 1 ]; then
            ((lettuce_amount+=1))
        elif [ $(echo "$rating >= 7.7" | bc -l) -eq 1 ]; then
            ((savory_amount+=1))
        elif [ $(echo "$rating >= 6" | bc -l) -eq 1 ]; then
            ((onion_amount+=1))
        elif [ $(echo "$rating >= 5" | bc -l) -eq 1 ]; then
            ((tomato_amount+=1))
        elif [ $(echo "$rating >= 4" | bc -l) -eq 1 ]; then
            ((carrot_amount+=1))
        else
            ((eggplant_amount+=1))
        fi
    done

    echo "$lettuce_amount Sublime Lettuces"
    echo "$savory_amount Amazing Savories"
    echo "$onion_amount Great Onions"
    echo "$tomato_amount Good Tomatoes"
    echo "$carrot_amount Decent Carrots"
    echo "$eggplant_amount Bad Eggplants"
}

if [ "$mode" == 'download' ]; then
    download_data
elif [ "$mode" == 'generate' ]; then
    find_movie_ids
    find_the_property 'director IDs'
    find_the_property 'genres'
    find_the_property 'runtimes'
    find_the_property 'years'
    find_the_property 'directors'
    find_the_property 'actor IDs'
    find_the_property 'actors'
    find_my_ratings
    find_the_property 'IMDb ratings'
elif [ "$mode" == 'show' ]; then
    show_number_of "$genres_file" 10
    show_number_of "$years_file" 10
    show_runtimes
    show_number_of "$directors_file" 10
    show_number_of "$actors_file" 10
    show_number_of "$my_ratings_file" 6
fi

