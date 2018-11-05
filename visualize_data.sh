source main.sh visualize

index_file=~/Documents/web_dev/3_my_sites/data/index.html

add_data() {
    keyword="$1"
    data="$2"

    sed -i "s/$keyword/$data/" "$index_file"
}

