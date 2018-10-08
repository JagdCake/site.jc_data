#!/bin/bash

html_file=~/Documents/web_dev/3_my_sites/iwam/index.html

rg -o -N -e "(tt\d{7}/\?)|(tt\d{7}/\")" "$html_file"

