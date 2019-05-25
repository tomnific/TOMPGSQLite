# TOMPGSQLite
This library was developed to make it easier to manage data between a remote and local relational database in iOS apps, by using a different, optimized, DBMS for the local and remote copy (SQLite and Postgres, respectively).
 
It accomplishes this by using the standard library for each (`sqlite3` for SQLite and `libpq` for Postgres) under the hood. Don't worry though, you won't need to interact with either of those at all.

<br>

## Documentation

A more proper tutorial is coming (hopefully) soon. In the meantime, the code is internally documented quite well, and is accessible via Xcode's Quick Help. 

<br>

## Dependencies
In order to use TOMPGSQLite, you need the following libraries (which are included here in the repo

* `libpq.framework`
* `libsqlite3.tbd`

### Dependency Disclaimer
Even though I have included the dependency libraries, I am not the owner or producer of these dependencies. Including them was to make it easier for users to utilize TOMPGSQLite, and should in no way be construed as a claim to ownership over them. 

<br>

## Contact 
Please report all bugs to the "Issues" page here on GitHub. 
If you've got a cool project that uses TOMPGSQLite, have suggestions for improvements, or you just want to say hi, you can contact me here: <br>

Twitter: <br>
[@tomnific](https://www.twitter.com/tomnific "Tom's Twitter") <br>

Email: <br>
[tom@southernderd.us](tom@southernderd.us "Tom's Email") <br>
