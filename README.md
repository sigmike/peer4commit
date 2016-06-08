Peer4commit
==========

[![peercoin tip for next commit](http://peer4commit.com/projects/1.svg)](http://peer4commit.com/projects/1)
[![bitcoin tip for next commit](http://tip4commit.com/projects/560.svg)](http://tip4commit.com/projects/560)

Donate peercoins to open source projects or make commits and get tips for it.

Official site: http://peer4commit.com/

Development
===========

To run peer4commit in development mode follow these instructions:

* Install [Ruby](https://www.ruby-lang.org/en/downloads/) 1.9+

* Install the [bundler](http://bundler.io/) gem (you may need root):
```
gem install bundler
```

* Install [git](http://git-scm.com/downloads)

* Clone the repository
```
git clone git@github.com:sigmike/peer4commit.git
cd peer4commit
```

or using docker:
```
cd $DIR # where dir is the git cloned repository
docker build -t <username>/peer4commit .
docker run -ti -v $PWD:/peer4commit <username>/peer4commit /bin/bash
then you will be in the container, in the peer4commit directory
where you can bundle install and change files
```

* Install the sqlite3 development libraries

* Install the gems (without the production gems):
```
bundle install --without mysql postgresql
```

* Create `database.yml`.
```
cp config/database.yml{.sample,}
```

* Create `config.yml`
```
cp config/config.yml{.example,}
```

* Edit `config.yml`

* Initialize the database
```
    bundle exec rake db:migrate
```

* Make sure `ppcoind` is running with RPC enabled

* Run the server


    bundle exec rails server

* Connect to the server at http://localhost:3000/


To update the project balances run this command:
```
    bundle exec rails runner "BalanceUpdater.work"
```

To retreive commits and send tips on project that do not hold tips:
```
    bundle exec rails runner "BitcoinTipper.work"
```

License
=======

[MIT License](https://github.com/sigmike/peer4commit/blob/master/LICENSE)

Based on [Tip4commit](http://tip4commit.com/), [MIT License](https://github.com/tip4commit/tip4commit/blob/master/LICENSE), copyright (c) 2013-2014 tip4commit
