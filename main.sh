#!/bin/bash

option="$1"

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
    mode="$1"

    datafiles=('https://datasets.imdbws.com/title.basics.tsv.gz' 'https://datasets.imdbws.com/title.crew.tsv.gz' 'https://datasets.imdbws.com/name.basics.tsv.gz' 'https://datasets.imdbws.com/title.principals.tsv.gz' 'https://datasets.imdbws.com/title.ratings.tsv.gz')

    if [ "$mode" == 'refresh' ]; then
        for datafile in "${datafiles[@]}"; do
            wget -P "$raw_data_storage_dir"/ "$datafile"
        done &&
        unpigz "$raw_data_storage_dir"/*.tsv.gz
    else
        for datafile in "${datafiles[@]}"; do
            datafile_name=$(echo "$datafile" | awk -F'/' '{ print $NF }' | awk -F'.gz' '{ print $1 }')
            exa "$raw_data_dir"/"$datafile_name" > /dev/null 2>&1

            # check if the datafile hasn't already been downloaded
            if [ $? != 0 ]; then
                wget -P "$raw_data_storage_dir"/ "$datafile"
            fi
        done &&
        unpigz -q "$raw_data_storage_dir"/*.tsv.gz
    fi &&

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

    # display the number (from highest to lowest) of movies for every X property
    sort "$x_file" | uniq -c | sort -nr | head -n $total
}

show_number_per_decade() {
    total=$1

    # remove the last digit from every year
    # Source: https://stackoverflow.com/questions/31135251/how-to-set-the-field-separator-to-an-empty-string/31135446#31135446
    # also, sort the resulting numbers and print only the unique ones
    for decade in $(bat "$years_file" | awk -F '' '{ print $1$2$3 }' | sort -nr | uniq); do
        number=$(rg -N $decade "$years_file" | wc -l)
        echo "$number ${decade}0s"
    done | head -n $total
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

    shortest_minutes=$(sort -nr "$runtimes_file" | tail -n 1)
    calc_hours_and_minutes $shortest_minutes
    echo "Shortest movie: $hours hour and $minutes minutes."

    runtimes_number=$(bat "$runtimes_file" | wc -l)
    ((average_in_minutes=$total_minutes/$runtimes_number))
    calc_hours_and_minutes $average_in_minutes
    echo "Average runtime: $hours hours $minutes minutes."
}

show_imdb_ratings() {
    # had to pipe rating comparison to 'bc' because bash doesn't support float calculations
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

show_average_imdb_rating() {
    ratings_sum=$(awk '{ s+=$1 } END { print s }' "$imdb_ratings_file")
    number_of_ratings=$(bat "$imdb_ratings_file" | wc -l)

    average_rating=$(echo "scale=1; $ratings_sum / $number_of_ratings" | bc -l)

    echo -e "\nAverage IMDb rating: $average_rating"
}

usage() {
  printf "\tUsage:\n"
  printf "\t./main.sh [OPTION]\n\n"
  printf "\tOptions:\n"
  printf "\t  download\tDownload datafiles.\n"
  printf "\t  refresh\tRefresh datafiles by redownloading.\n"
  printf "\t  generate\tGenerate data.\n"
  printf "\t  show\t\tShow generated data.\n"
  printf "\t  help\t\tShow help screen."
  printf "\n\n"
}

if [ "$option" == 'download' ]; then
    download_data
elif [ "$option" == 'refresh' ]; then
    download_data 'refresh'
elif [ "$option" == 'generate' ]; then
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
elif [ "$option" == 'show' ]; then
    echo -e "\nNumber of movies per genre:\n"
    show_number_of "$genres_file" 10

    echo -e "\nNumber of movies per year:\n"
    show_number_of "$years_file" 10

    echo -e "\nNumber of movies per decade:\n"
    show_number_per_decade 10

    echo -e "\nMovie runtime information:\n"
    show_runtimes

    echo -e "\nNumber of movies from different directors:\n"
    show_number_of "$directors_file" 10

    echo -e "\nNumber of movies starring different actors:\n"
    show_number_of "$actors_file" 10

    echo -e "\nNumber of movies per rating:\n"
    show_number_of "$my_ratings_file" 6

    echo -e "\nAverage IMDb ratings translated to my rating system:\n"
    # Source: https://askubuntu.com/a/439038/776543
    mapfile -t my_imdb_ratings < <(show_imdb_ratings ... | sort -nr)
    echo "${my_imdb_ratings[@]}"

    show_average_imdb_rating
elif [ "$option" == 'help' ]; then
    usage
else
    usage
fi

