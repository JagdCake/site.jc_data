#!/bin/bash

set -e

build() {
    ~/Documents/my_github/shell_scripts/scripts/./build_web_project.sh "$1" "$2" "$3"
}

uncomment() {
    # uncomment the CSP
    sed -i 's/<!-- //' ./docs/index.html
    sed -i 's/ -->//' ./docs/index.html
}

fix_paths() {
    sed -i 's/\/css\/tachyons.min.css/css\/tachyons_purged.min.css/g' ./docs/index.html
}

build_html() {
    build html ./docs/index.html ./docs/
}

# build_css() {
    # cp -r ./symfony/public/css/tachyons.min.css ./docs/css/
    # uncss ./docs/index.html > ./docs/css/tachyons.min.css
    #  build css ./docs/css/tachyons_purged.min.css ./docs/css/
# }

first_build() {
    uncomment
    fix_paths
    build_html
    # build_css
}

update_build() {
    uncomment
    fix_paths
    build_html
}

if [ ! -z "$1" ]; then
    "$1"
else
    printf "Usage:\n"
    printf "  ./build_static_site.sh [FUNCTION NAME]\n\n"
    printf "Grouped functions:\n"
    printf "  first_build — when building for the first time\n\n"
    printf "  update_build — after updating the site with new data\n\n"
    printf "Functions:\n"
    printf "  uncomment\n\n"
    printf "  fix_paths\n\n"
    printf "  build_html\n\n"
    # printf "  build_css\n\n"
    printf "\n"

    exit 1
fi

