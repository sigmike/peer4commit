FROM opensuse
RUN zypper -n install -t pattern  devel_basis 
RUN zypper -n install sqlite3-devel nodejs ruby ruby-devel git postgresql-devel mysql-devel libmysqlclient-devel gcc-c++ vim
RUN mkdir /peer4commit
WORKDIR /peer4commit
RUN gem install bundler --no-format-executable
# ADD . /peer4commit
# RUN bundler install
