#!/bin/bash

html_file=~/Documents/web_dev/3_my_sites/iwam/index.html
basics_file=./title.basics.tsv

# find all IMDb IDs
ids=($(rg -o -N -e "(tt\d{7}/\?)|(tt\d{7}/\")" "$html_file" | awk -F'/' '{ print $1 }'))


