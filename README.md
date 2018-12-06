<h1 align="center">JC Data</h1>

### In short:
- I'm using a BASH shell script to extract and process data from my website [“I watched a Movie!”](https://movies.jagdcake.com/)
- majority of the data comes from IMDb datasets, available [here](https://www.imdb.com/interfaces/)
- the data is visualized on a static website — [“JC Data”](https://data.jagdcake.com), again by using a BASH script

### Data extraction:
1. Download the necessary datafiles from [IMDb](https://www.imdb.com/interfaces/)
1. Find all IMDb movie title IDs, e.g. `tt0071853`, by using [ripgrep](https://github.com/BurntSushi/ripgrep) to search through my website's index file
1. Use ripgrep to search the datasets for the movie IDs and find…
    - all director IDs, e.g. `nm0000416`
    - main genre
    - runtime in minutes
    - release year
    - top 2 actor IDs, e.g. `nm0001037`
    - average IMDb rating
1. Use ripgrep to search the datasets for…
    - director IDs and find the names of every movie's director(s)
    - actor IDs and find the names of the 2 top billed actors from every movie
1. Search the index file for my ratings

### Data processing:
1. Do some basic math to find out how much time I've spent watching movies
1. Sort (by highest number and then alphabetically) the found data to create lists of the top 10 number of movies per…
    - genre
    - release year / decade
    - director
    - actor
1. Sort the found data to find the top…
    - genre
    - year
    - director
    - actor
    - rating
1. Determine if most of the movies I've watched are…
    - newer (top year>=2010)
    - new (top year>=2000)
    - old (top year>=1980)
    - older (top year<1980)
1. Translate IMDb's rating system to mine, by assigning an IMDb ratings range to every one of my ratings and comparing the average IMDb rating by it:
    - Sublime Lettuce = 9 to 10
    - Amazing Savory = 7.9 to 8.9
    - Great Onion = 6 to 7.8
    - Good Tomato = 5 to 5.9
    - Decent Carrot = 4 to 4.9
    - Bad Eggplant = 1 to 3.9
1. Give each rating a numerical value and sum the values of my ratings and the translated IMDb ratings, to determine how IMDb users rate movies compared to me — higher / lower / the same
1. Sort the ratings data to create lists of the number of movies per rating
