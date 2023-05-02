# README for R Packages With Pagination

R Packages is a simple web application that displays a list of R packages and their details with pagination. It uses data from the Comprehensive R Archive Network (CRAN), which is a network of servers that store and distribute R packages. The application fetches package data from the CRAN server, extracts the required information using regular expressions, and stores it in a local database. The information is then displayed in a tabular format on a web page, with pagination links to navigate between pages.

## Requirments
Requirements
Ruby 2.7+, 
Ruby on Rails 6.1+, 
PostgreSQL, 
Redis-server

## Installation
1) Download the project and navigate to its directory.
```
cd R_Package_Indexer
```

2) Install the required dependencies using Bundler.
```
bundle install
```

3) Create and migrate the database.
```
rails db:create db:migrate
```

4) Start the redis server for the cache.
```
redis-server
```

5) Start the server
```
rails server
```

6) Open a web browser and navigate to 
```
http://localhost:3000/packages
```

7) You can  also install the whenever gem in order to activate the cronjob that is in schedule.rb and it's running each night at 12am. It fetches all the packages and it's updating the cache
```
gem install whenever
whenever --update-crontab
```

## Usage

The application displays a list of R packages and their details with pagination. By default, it has a "wannabe pagination" to select the first 5000 characters from the PACKAGES.gz file in order to not make too many calls for taking the details from the first time. You can navigate between pages using the pagination links at the bottom of the page. At midnight of the night, the cronjob will run and will fetch and cache all of them so the navigation between the pages will be instant.


Just an idea: I had also another idea at the beginning to present in the list just the name and the version and to create a button to a show page where I will call the details page(http://cran.r-project.org/src/contrib/name_version.tar.gz) when it's accessed but in the end, I choose this option with cache and the cronjob.