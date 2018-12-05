source main.sh visualize

website=../docs/index.html

add_data() {
    keyword="$1"
    data="$2"

    sed -i "s/$keyword/$data/" "$website"
}

pluralize() {
    sed -e 's/Lettuce/Lettuces/' -e 's/Savory/Savories/' -e 's/Onion/Onions/' -e 's/Tomato/Tomatoes/' -e 's/Carrot/Carrots/' -e 's/Eggplant/Eggplants/'
}

add_array_data() {
    keyword="$1"
    # Source: https://stackoverflow.com/a/16462240/8980616
    shift 1
    data=("$@")

    for i in "${data[@]}"; do
        i=$(echo "$i" | pluralize)
        data_arr+=("<li>${i}<\/li>")
    done

    sed -i "s/$keyword/$(echo -n ${data_arr[@]})/" "$website"

    data_arr=()
}

movie_age_adjective() {
    if [ $top_year -ge 2010 ]; then
        adjective='newer'
    elif [ $top_year -ge 2000 ]; then
        adjective='new'
    elif [ $top_year -ge 1980 ]; then
        adjective='old'
    else
        adjective='older'
    fi

    echo "$adjective"
}

rating_stars() {
    ratings=("$@")

    stars=0
    for rating in "${ratings[@]}"; do
        number_of_ratings="$(echo "$rating" | awk '{ print $1 }')"
        rating="$(echo "$rating" | awk '{ print $2,$3 }')"

        # assign a numerical value to every rating and multiply the number of ratings by it, so that the ratings can be compared
        if [ "$rating" == 'Sublime Lettuce' ]; then
            ((stars=$stars + $number_of_ratings * 6))
        elif [ "$rating" == 'Amazing Savory' ]; then
            ((stars=$stars + $number_of_ratings * 5))
        elif [ "$rating" == 'Great Onion' ]; then
            ((stars=$stars + $number_of_ratings * 4))
        elif [ "$rating" == 'Good Tomato' ]; then
            ((stars=$stars + $number_of_ratings * 3))
        elif [ "$rating" == 'Decent Carrot' ]; then
            ((stars=$stars + $number_of_ratings * 2))
        elif [ "$rating" == 'Bad Eggplant' ]; then
            ((stars=$stars + $number_of_ratings * 1))
        fi
    done
}

ratings_adjective() {
    rating_stars "${my_ratings[@]}"
    my_stars=$stars
    rating_stars "${my_imdb_ratings[@]}"
    imdb_stars=$stars

    if [ $my_stars -gt $imdb_stars ]; then
        adjective='lower'
    elif [ $my_stars -lt $imdb_stars ]; then
        adjective='higher'
    elif [ $my_stars -eq $imdb_stars ]; then
        adjective='the same'
    fi

    echo "$adjective"
}

# Article 1
# section dates
add_data "date_last_update_machine" "$date_last_update_machine"
add_data "date_last_update_human" "$date_last_update_human"
add_data "movie_number" "$movie_number"
# section days
add_data "total_days_machine" "$total_days"
add_data "total_days" "$total_days"
add_data "total_days_spent_machine" "$total_days_spent"
add_data "total_days_spent" "$total_days_spent"
add_data "percent_of_total_days" "$percent_of_total_days"
# section hours
add_data "total_hours_and_mins_machine" "$total_hours_and_mins_machine"
add_data "total_hours_and_mins" "$total_hours_and_mins"

# Article 2
# section runtime long
add_data "longest_movie_runtime_machine" "$longest_movie_runtime_machine"
add_data "longest_movie_runtime" "$longest_movie_runtime"
# section runtime short
add_data "shortest_movie_runtime_machine" "$shortest_movie_runtime_machine"
add_data "shortest_movie_runtime" "$shortest_movie_runtime"
# section runtime average
add_data "average_runtime_machine" "$average_runtime_machine"
add_data "average_runtime" "$average_runtime"

# Article 3
# section genre text
add_data "top_genre" "$top_genre"
# section genre list
add_array_data "movies_per_genre" "${movies_per_genre[@]}"

# Article 4
# section years text
add_data "movie_age_adjective" $(movie_age_adjective)
add_data "top_year" "$top_year"
# section years list
add_array_data "movies_per_decade" "${movies_per_decade[@]}"

# Article 5
# section director text
add_data "top_director" "$top_director"
# section director list
add_array_data "movie_directors" "${movie_directors[@]}"

# Article 6
# section actor text
add_data "top_actor" "$top_actor"
# section actor list
add_array_data "movie_actors" "${movie_actors[@]}"

# Article 8
# section my ratings text
add_data "my_top_rating" "$(echo $my_top_rating | pluralize)"
# section my ratings list
add_array_data "my_ratings" "${my_ratings[@]}"

# Article 9
# section imdb ratings text
add_data "ratings_adjective" "$(ratings_adjective)"
# section imdb ratings list
add_array_data "my_imdb_ratings" "${my_imdb_ratings[@]}"

