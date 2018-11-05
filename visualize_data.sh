source main.sh visualize

index_file=~/Documents/web_dev/3_my_sites/data/index.html

add_data() {
    keyword="$1"
    data="$2"

    sed -i "s/$keyword/$data/" "$index_file"
}

add_array_data() {
    keyword="$1"
    # Source: https://stackoverflow.com/a/16462240/8980616
    shift 1
    data=("$@")

    for i in "${data[@]}"; do
        data_arr+=("<li>${i}<\/li>")
    done

    sed -i "s/$keyword/$(echo -n ${data_arr[@]})/" "$index_file"

    data_arr=()
}

