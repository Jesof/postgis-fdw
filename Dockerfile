FROM jesof/postgis:11.3-2.5.2

MAINTAINER Jesof <jesof.jes@gmail.com>

ENV ORACLE_MAJOR 12.2
ENV ORACLE_VERSION 12.2.0.1.0-2

ADD oracle /tmp/oracle

RUN dpkg -i /tmp/oracle/oracle-instantclient${ORACLE_MAJOR}-basic_${ORACLE_VERSION}_amd64.deb
RUN dpkg -i /tmp/oracle/oracle-instantclient${ORACLE_MAJOR}-devel_${ORACLE_VERSION}_amd64.deb
RUN dpkg -i /tmp/oracle/oracle-instantclient${ORACLE_MAJOR}-odbc_${ORACLE_VERSION}_amd64.deb
RUN dpkg -i /tmp/oracle/oracle-instantclient${ORACLE_MAJOR}-sqlplus_${ORACLE_VERSION}_amd64.deb
RUN dpkg -i /tmp/oracle/oracle-instantclient${ORACLE_MAJOR}-tools_${ORACLE_VERSION}_amd64.deb

ENV ORACLE_HOME /usr/lib/oracle/${ORACLE_MAJOR}/client64/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/lib/oracle/${ORACLE_MAJOR}/client64/lib
ENV PATH $PATH:$ORACLE_HOME

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
  build-essential make curl ca-certificates libcurl4-gnutls-dev \
  libc6-dev libaio1 \
  unixodbc unixodbc-dev \
  postgresql-client-common libpq-dev \
  postgresql-server-dev-11 &&\
  rm -rf /var/lib/apt/lists/*

RUN curl ftp://ftp.freetds.org/pub/freetds/stable/freetds-1.1.6.tar.gz | tar zxv -C /tmp &&\
  cd /tmp/freetds-1.1.6 &&\
  ./configure --prefix=/usr --with-tdsver=7.4 &&\
  make &&\
  make install

RUN curl -L https://github.com/tds-fdw/tds_fdw/archive/v2.0.0-alpha.3.tar.gz | tar zxv -C /tmp &&\
  cd /tmp/tds_fdw-2.0.0-alpha.3 &&\
  make USE_PGXS=1 &&\
  make USE_PGXS=1 install

RUN curl -L https://github.com/laurenz/oracle_fdw/archive/ORACLE_FDW_2_1_0.tar.gz | tar zxv -C /tmp &&\
  cd /tmp/oracle_fdw-ORACLE_FDW_2_1_0 &&\
  make &&\
  make install