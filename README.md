PostgreSQL [![Swift Version](https://img.shields.io/badge/Swift-3.0.2-orange.svg)](https://swift.org/download/#releases) [![Platforms](https://img.shields.io/badge/Platforms-macOS%20|%20Linux-lightgray.svg)](https://swift.org/download/#releases) [![Build Status](https://travis-ci.org/DavidSkrundz/PostgreSQL.svg?branch=master)](https://travis-ci.org/DavidSkrundz/PostgreSQL) [![Codebeat Status](https://codebeat.co/badges/a017ffc7-5420-4901-a217-0dd505c70c7c)](https://codebeat.co/projects/github-com-davidskrundz-postgresql) [![Codecov](https://codecov.io/gh/DavidSkrundz/PostgreSQL/branch/master/graph/badge.svg)](https://codecov.io/gh/DavidSkrundz/PostgreSQL)
==========

A Swift wrapper for libpq-9.6


Use
---
```Swift
let database = Database()
	.withHost("localhost")
	.withPort(5432)
	.withDatabaseName("postgres")
	.withConnectTimeout(5)
	.withApplicationName("TestApplication")
let connection = try database.connect()
let result = connection.execute("CREATE SCHEMA test")
```


Supported Types
---------------
All types that are not listed are represented as a `String`

###### Native Support
 - smallint (`Int16`)
 - integer (`Int32`)
 - bigint (`Int64`)
 - real (`Float`)
 - double precision (`Double`)
 - smallserial (`Int16`, reads as a smallint)
 - serial (`Int32`, reads as a integer)
 - bigserial (`Int64`, reads as a bigint)
 - varchar(n) (`String`)
 - char(n) (`String`)
 - text (`String`)
 - boolean (`Bool`)

###### Limited Support
 - bytea (`[UInt8]`, only supports Hex Format)


Requires
--------
######maxOS
```
$ brew install postgres
```

######Linux
```
$ echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" | sudo tee -a /etc/apt/sources.list.d/pgdg.list
$ wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
$ sudo apt-get update
$ sudo apt-get install libpq-dev
$ sudo apt-get postgresql
```
