#!/bin/bash

option="$1"

### File Paths ###
movies_html_file=~/Documents/web_dev/3_my_sites/iwam/index.html

processed_data_dir="$(pwd)/processed_data/"
last_update_file="$processed_data_dir"/last_update

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
    number_of_ids_before=$(bat "$movie_ids_file" 2>/dev/null | wc -l)
    # if the IDs file isn't empty, create a temporary HTML file with the already found IDs removed, so that 'ripgrep' can append only the newly found ones
    if [ $number_of_ids_before -gt 0 ]; then
        cp "$movies_html_file" /tmp/updated_html_file.html
        movies_html_file=/tmp/updated_html_file.html

        for id in $(bat "$movie_ids_file"); do
            sed -i "s/$id//" "$movies_html_file"
        done
    fi

    # find all / new IMDb IDs
    rg -o -N -e "(tt\d{7}/\?)|(tt\d{7}/\")" "$movies_html_file" | awk -F'/' '{ print $1 }' >> "$movie_ids_file"

    number_of_ids_after=$(bat "$movie_ids_file" | wc -l)
    ((number_of_new_ids=$number_of_ids_after - $number_of_ids_before))
}

find_my_ratings() {
    ratings=('Bad Eggplant' 'Decent Carrot' 'Good Tomato' 'Great Onion' 'Amazing Savory' 'Sublime Lettuce')

    rm "$my_ratings_file" 2>/dev/null
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

append_the_property() {
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

    # runs only when new IDs have been appended
    if [[ $number_of_new_ids -gt 0 && $number_of_ids_after -ne $number_of_new_ids ]]; then
        # TODO Fix:
        # this is the number of new movie IDs, but the number of actor IDs is double that, while director IDs vary, so not all actor / director names are appended to their respective files
        tail -n $number_of_new_ids "$ids_file" > /tmp/updated_ids_file
        ids_file=/tmp/updated_ids_file

        append_the_property
    # runs only the first time or if the processed data files have been deleted
    elif [ $number_of_ids_after -eq $number_of_new_ids ]; then
        append_the_property
    fi
}

show_number_of() {
    x_file="$1"
    # total number of items to display
    # (enter a number higher than the amount of items to show all items)
    total=$2

    # display the number (from highest to lowest) of movies for every X property
    sort "$x_file" | uniq -c | sort -k1,1nr -k2 | head -n $total
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
    total_hours_and_mins=$(echo "$hours hours and $minutes minutes")
    total_hours_and_mins_machine=$(echo "${hours}h ${minutes}m")
    echo "I've watched movies for a total of $total_hours_and_mins."

    longest_minutes=$(sort -n "$runtimes_file" | tail -n 1)
    calc_hours_and_minutes $longest_minutes
    longest_movie_runtime=$(echo "$hours hours and $minutes minutes")
    longest_movie_runtime_machine=$(echo "${hours}h ${minutes}m")
    echo "Longest movie: $longest_movie_runtime."

    shortest_minutes=$(sort -nr "$runtimes_file" | tail -n 1)
    calc_hours_and_minutes $shortest_minutes
    shortest_movie_runtime=$(echo "$hours hours and $minutes minutes")
    shortest_movie_runtime_machine=$(echo "${hours}h ${minutes}m")
    echo "Shortest movie: $shortest_movie_runtime."

    runtimes_number=$(bat "$runtimes_file" | wc -l)
    ((average_in_minutes=$total_minutes/$runtimes_number))
    calc_hours_and_minutes $average_in_minutes
    average_runtime=$(echo "$hours hours and $minutes minutes")
    average_runtime_machine=$(echo "${hours}h ${minutes}m")
    echo "Average runtime: $average_runtime."
}

show_days() {
    date_start='2016-06-01'
    date_last_update_machine=$(tail -n 1 "$last_update_file")

    date_start_s=$(date -d $date_start +%s)
    date_last_update_s=$(date -d $date_last_update_machine +%s)
    ((total_days_s=$date_last_update_s - $date_start_s))

    total_days=$(udunits2 -H "$total_days_s seconds" -W days | awk -F'x' '{ print $1 }' | awk -F'=' '{ print $2 }' | awk -F'.' '{ print $1 }' | tr -d '[:space:]')
    total_days_spent=$(udunits2 -H "$total_minutes minutes" -W days | awk -F'x' '{ print $1 }' |awk -F'=' '{ print $2 }' | awk -F'.' '{ print $1 }' | tr -d '[:space:]')
    percent_of_total_days=$(echo "scale=1; 100 * $total_days_spent / $total_days" | bc -l)

    echo "Out of $total_days days, I've spent $total_days_spent watching films. That's ${percent_of_total_days}% of my time."
}

show_imdb_ratings() {
    # had to pipe rating comparison to 'bc' because bash doesn't support float calculations
    for rating in $(bat "$imdb_ratings_file"); do
        if [ $(echo "$rating >= 9" | bc -l) -eq 1 ]; then
            ((lettuce_amount+=1))
        elif [ $(echo "$rating >= 7.9" | bc -l) -eq 1 ]; then
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

    echo "$lettuce_amount Sublime Lettuce"
    echo "$savory_amount Amazing Savory"
    echo "$onion_amount Great Onion"
    echo "$tomato_amount Good Tomato"
    echo "$carrot_amount Decent Carrot"
    echo "$eggplant_amount Bad Eggplant"
}

show_average_imdb_rating() {
    ratings_sum=$(awk '{ s+=$1 } END { print s }' "$imdb_ratings_file")
    number_of_ratings=$(bat "$imdb_ratings_file" | wc -l)

    average_rating=$(echo "scale=1; $ratings_sum / $number_of_ratings" | bc -l)

    echo -e "\nAverage IMDb rating: $average_rating"
}

show() {
    movie_number=$(bat "$movie_ids_file" | wc -l)
    echo -e "\nTotal number of movies: $movie_number\n"

    date_last_update_human=$(head -n 1 "$last_update_file")
    echo -e "\nLast update on the $date_last_update_human\n"

    top_genre=$(show_number_of "$genres_file" 1 | awk '{ print $2 }')
    echo -e "\nTop genre: $top_genre"

    echo -e "\nNumber of movies per genre:\n"
    show_number_of "$genres_file" 10
    # Source: https://askubuntu.com/a/439038/776543
    mapfile -t movies_per_genre < <(show_number_of "$genres_file" 10 ...)

    top_year=$(show_number_of "$years_file" 1 | awk '{ print $2 }')
    echo -e "\nTop year: $top_year"

    echo -e "\nNumber of movies per year:\n"
    show_number_of "$years_file" 10

    echo -e "\nNumber of movies per decade:\n"
    show_number_per_decade 10
    mapfile -t movies_per_decade < <(show_number_per_decade 10 ...)

    echo -e "\nMovie runtime information:\n"
    show_runtimes

    show_days

    top_director=$(show_number_of "$directors_file" 1 | awk '{ print $2,$3 }')
    echo -e "\nTop director: $top_director"

    echo -e "\nNumber of movies from different directors:\n"
    show_number_of "$directors_file" 10
    mapfile -t movie_directors < <(show_number_of "$directors_file" 10 ...)

    top_actor=$(show_number_of "$actors_file" 1 | awk '{ print $2,$3 }')
    echo -e "\nTop actor: $top_actor"

    echo -e "\nNumber of movies starring different actors:\n"
    show_number_of "$actors_file" 10
    mapfile -t movie_actors < <(show_number_of "$actors_file" 10 ...)

    my_top_rating=$(show_number_of "$my_ratings_file" 1 | awk '{ print $2,$3 }')
    echo -e "\nTop rating: $my_top_rating"

    echo -e "\nNumber of movies per rating:\n"
    show_number_of "$my_ratings_file" 6
    mapfile -t my_ratings < <(show_number_of "$my_ratings_file" 6 ...)

    echo -e "\nAverage IMDb ratings translated to my rating system:\n"
    show_imdb_ratings | sort -nr
    mapfile -t my_imdb_ratings < <(show_imdb_ratings ... | sort -nr)

    show_average_imdb_rating
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
    date "+%B %d, %Y" > "$last_update_file"
    date "+%F" >> "$last_update_file"
elif [ "$option" == 'show' ]; then
    show
elif [ "$option" == 'visualize' ]; then
    show > /dev/null
elif [ "$option" == 'help' ]; then
    usage
else
    usage
fi

