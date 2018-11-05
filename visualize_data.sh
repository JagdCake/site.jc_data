source main.sh visualize

index_file=~/Documents/web_dev/3_my_sites/data/index.html

add_data() {
    keyword="$1"
    data="$2"

    sed -i "s/$keyword/$data/" "$index_file"
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

    sed -i "s/$keyword/$(echo -n ${data_arr[@]})/" "$index_file"

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

add_data_to_section() {
    section="$1"

    if [ "$section" == 'dates' ]; then
        add_data "date_last_update_machine" "$date_last_update_machine"
        add_data "date_last_update_human" "$date_last_update_human"
        add_data "movie_number" "$movie_number"
    elif [ "$section" == 'days' ]; then
        add_data "total_days_machine" "$total_days"
        add_data "total_days" "$total_days"
        add_data "total_days_spent_machine" "$total_days_spent"
        add_data "total_days_spent" "$total_days_spent"
        add_data "percent_of_total_days" "$percent_of_total_days"
    elif [ "$section" == 'hours' ]; then
        add_data "total_hours_and_mins_machine" "$total_hours_and_mins_machine"
        add_data "total_hours_and_mins" "$total_hours_and_mins"
    elif [ "$section" == 'runtime long' ]; then
        add_data "longest_movie_runtime_machine" "$longest_movie_runtime_machine"
        add_data "longest_movie_runtime" "$longest_movie_runtime"
    elif [ "$section" == 'runtime short' ]; then
        add_data "shortest_movie_runtime_machine" "$shortest_movie_runtime_machine"
        add_data "shortest_movie_runtime" "$shortest_movie_runtime"
    elif [ "$section" == 'runtime average' ]; then
        add_data "average_runtime_machine" "$average_runtime_machine"
        add_data "average_runtime" "$average_runtime"
    elif [ "$section" == 'genre text' ]; then
        add_data "top_genre" "$top_genre"
    elif [ "$section" == 'genre list' ]; then
        add_array_data  "movies_per_genre" "${movies_per_genre[@]}"
    elif [ "$section" == 'years text' ]; then
        add_data "movie_age_adjective" $(movie_age_adjective)
        add_data "top_year" "$top_year"
    elif [ "$section" == 'years list' ]; then
        add_array_data "movies_per_decade" "${movies_per_decade[@]}"
    elif [ "$section" == 'director text' ]; then
        add_data "top_director" "$top_director"
    elif [ "$section" == 'director list' ]; then
        add_array_data  "movie_directors" "${movie_directors[@]}"
    elif [ "$section" == 'actor text' ]; then
        add_data "top_actor" "$top_actor"
    elif [ "$section" == 'actor list' ]; then
        add_array_data  "movie_actors" "${movie_actors[@]}"
    elif [ "$section" == 'my ratings text' ]; then
        add_data "my_top_rating" "$(echo $my_top_rating | pluralize)"
    elif [ "$section" == 'my ratings list' ]; then
        add_array_data "my_ratings" "${my_ratings[@]}"
    fi
}

add_data_to_article() {
    article=$1

    if [ $article -eq 1 ]; then
        add_data_to_section 'dates'
        add_data_to_section 'days'
        add_data_to_section 'hours'
    elif [ $article -eq 2 ]; then
        add_data_to_section 'runtime long'
        add_data_to_section 'runtime short'
        add_data_to_section 'runtime average'
    elif [ $article -eq 3 ]; then
        add_data_to_section 'genre text'
        add_data_to_section 'genre list'
    elif [ $article -eq 4 ]; then
        add_data_to_section 'years text'
        add_data_to_section 'years list'
    elif [ $article -eq 5 ]; then
        add_data_to_section 'director text'
        add_data_to_section 'director list'
    elif [ $article -eq 6 ]; then
        add_data_to_section 'actor text'
        add_data_to_section 'actor list'
    elif [ $article -eq 8 ]; then
        add_data_to_section 'my ratings text'
        add_data_to_section 'my ratings list'
    fi
}

add_data_to_article 1
add_data_to_article 2
add_data_to_article 3
add_data_to_article 4
add_data_to_article 5
add_data_to_article 6
add_data_to_article 8

