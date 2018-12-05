#!/bin/bash

build_script_dir=~/Documents/my_github/shell_scripts/scripts/

project_dir=~/Documents/web_dev/3_my_sites/data/website/
production_dir="$project_dir"/../docs/
template_dir=~/Documents/web_dev/1_templates/static_site/

html_dir=
css_dir=css
js_dir=js
images_dir=images

build() {
    filetype="$1"
    input="$2"
    output_dir="$3"

    "$build_script_dir"/./build_web_project.sh "$filetype" "$input" "$output_dir"
}

copy_files() {
    mkdir "$production_dir"/

    cp -r "$project_dir/$html_dir"/index.html "$production_dir/$html_dir"/
    # cp -r "$project_dir/$css_dir"/ "$production_dir/$css_dir"/
    # cp -r "$project_dir/$js_dir"/ "$production_dir/$js_dir"/
    cp -r "$project_dir/$images_dir"/ "$production_dir/$images_dir"/
}

build_all() {
    build html "$production_dir/$html_dir"/ "$production_dir/$html_dir"/
    # build css "$production_dir/$css_dir"/ "$production_dir/$css_dir"/
    # build js "$production_dir/$js_dir"/ "$production_dir/$js_dir"/
    # build svg "$production_dir/$images_dir"/ "$production_dir/$images_dir"/
    build png "$production_dir/$images_dir"/ "$production_dir/$images_dir"/
}

update_paths() {
    sed -i 's/src="js\/all.js"/src="js\/min.all.js"/g' "$production_dir/$html_dir"/*.html
}

switch_to_branch() {
    branch="$1"

    cd "$template_dir"/

    git checkout "$branch"

    cd ~-
}

copy_production_files() {
    prod_file="$1"
    destination="$2"

    switch_to_branch production
    cp "$template_dir/$prod_file" "$production_dir/$destination"/
    switch_to_branch development
}

copy_files
build_all
# update_paths
copy_production_files '404.html' ''

