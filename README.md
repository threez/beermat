# Beermat ![Travis CI Status](https://secure.travis-ci.org/threez/beermat.png "Travis CI Status")

This is a database and a website for managing the consume of any type of liquids in a group. I made this system on my brothers request for managing his groups consume of beer and shots.

## Installation

This application is compatible with **rack** and various versions of **ruby**. I don't know of any incompatibilities.

### Installing the application

    gem install beermat

### Deploying the application

If you use [Phusion Passenger](http://www.modrails.com/index.html) you just have to put the following **config.ru** rack configuration file.

    require 'rubygems'
    require 'beermat'
    
    DB_PATH = "/db"
    PASSWD = "secret"
    
    # use a basic auth to save the beermat from unauthorized access
    use Rack::Auth::Basic do |username, password|
      password == PASSWD
    end
    
    # start the application
    run Beermat::Application.new(:db => DB_PATH)

## Database

The database must be easily changed by a user. It has to save the drinks the profiles (person) and the history of consume. Alongside it should keep track of the stock of drinks. Each database file must be editable by a user. The application should be enabled to cache all the data in the database. Changes should be appended and don't replace or delete a file. Therefore everything is a journal of changes. There should be no extra database configuration necessary. A directory name is the only configuration needed. Writing should be very efficient. Reading from the database can be inefficient, because the data are read only on the start of the application. 

Every other transaction will be executed in memory also. So that the important values are always precomputed. The internal cache should be accessible like a hash and should be unique to all of the requests. This way the application could be scaled on multiple servers also. But scaling the application might be not necessary in small groups.

In consequence the database will cause a lot of files an folders. Not surprising should the filesystem be able to deal with them efficiently.

### Structure

The structure of the database can be divided into several parts. Those parts are explained one by one. All examples pretend **/db** to be the place of the database.

#### Profile

The profile represents a person that is known by the system using a unique id. This id is a string chosen by the user. Something like "mmustermann" if your first and lastname is "Max Mustermann". The Profile is in the profiles subfolder. The files are YAML files and therefore easy to edit and extend. The structure is like this:

    Files in /db/profiles:
    hfischer.yaml    mmustermann.yaml

The contents of those file includes a **lastname**, a **firstname**, a **nickname** and an **picture\_url**. Here is an example:

    firstname: Herny
    lastname: Fischer
    nickname: Henni
    picture_url: http://some-server.com/pic1.jpg

#### Drinks

A drink is a drinkable liquid. It can be consumed once. It is necessary to choose a unique id for the liquid that will not change. For the sake of demonstation this will be duff beer. The example database structure is in the drinks subfolder.

    Files in /db/drinks:
    duff.yaml

The file contains data about a drink. Here is an example:

    name: Duff Beer 0,5l
    price: 1
    capacity: 0.5l
    warning_red: 5
    warning_yellow: 10
    picture_url: http://images.org/duff.png

* **price** is the price in euro per unit (or bottle)
* **capacity** is the amount of liquid in the bottle. There are 3 units that can be used **l**, **cl** and **ml**. (1l = 100cl = 1000ml)
* **warning_red** is an indicator for the user to show him, that the stock of unites is almost empty
* **warning_yellow** is an indicator for the user to show him, that the stock of unites is going to be empty soon

#### Journal

The journal keeps track of data that was changed in the system. For example that the stock was filled by a person or that someone consumed some drinks. The journal is saved under the subfolder **journal**.

Under the journal there are two more sub folders:

* **stock** is the folder where each drink has a log file. 
* **consume** is the folder where each consumer has a log of which drink he drunk.

The logs are just CSV files. The separator in all cases is a semicolon. There are no quotes around the values. Here is an example directory structure:

    Files in /db/journal/:
    stock    consume
    
    Files in /db/journal/stock:
    duff.csv
    
    Files in /db/journal/consume:
    hfischer.csv    mmustermann.csv

The names of the stock files correlates to the drinks id and the name of the consume log files correlates to the profile files. The names (id's) of the files have to match exactly (except the file extension like CSV and YAML). Those names or id's will be the connection beween the journal and the static data.

##### Format of the stock CSV files

As an example we show the contents of the duff beer log:

    2012-01-05T12:11:19+01:00;24
    2012-01-10T14:14:28+01:00;12
    2012-01-28T16:13:50+01:00;36
    
* **first column** contains the date and time (ISO8601) on which the stock change happend
* **second column** contains the amount by which the stock was changed (this number can be positive or negative)

Please note that the consume of the people will not change the stock logs. Normally they will just be changed because the stock was refilled or somehow changed.

##### Format of the consume CSV files

The consume of the profiles will be tracked in those files. An example log is shown below:
    
    2012-01-08T12:11:19+01:00;duff
    2012-01-12T14:14:28+01:00;duff
    2012-01-12T16:13:50+01:00;duff

* **first column** contains the date and time (ISO8601) on which the stock change happend
* **second column** the unique id of the drink that was consumed

## Example

An example of the database can be found at **spec/example\_db**
