//
//  TOMPGSQLite.h
//  TOMPGSQLite
//
//  Created by Tom Metzger on 12/12/18.
//  Copyright © 2018 Tom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <libpq/libpq-fe.h>
#import <sqlite3.h>





//! Project version number for TOMPGSQLite.
FOUNDATION_EXPORT double TOMPGSQLiteVersionNumber;

//! Project version string for TOMPGSQLite.
FOUNDATION_EXPORT const unsigned char TOMPGSQLiteVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <TOMPGSQLite/PublicHeader.h>





/*!
 @class TOMPGSQLite
 
 @brief The @c TOMPGSQLite class
 
 @discussion This class was developed to make it easier to manage data between a remote and local relational database in iOS apps, by using a different, optimized, DBMS for the local and remote copy (SQLite and Postgres, respectively).
 
 It accomplishes this by using the standard library for each (@c sqlite3 for SQLite and @c libpq for Postgres) under the hood. Don't worry though, you won't need to interact with either of those at all.
 
 @note @c <libpq/libpq-fe.h> and @c <sqlite3.h> need to be included in your app, as this is not an umbrella library.
 
 @author Tom Metzger
 @version 1.0
 @copyright © 2019, Tom Metzger
 */
@interface TOMPGSQLite : NSObject

// Log Or Not
/*! @brief Determines whether or not error logging is enabled. */
@property BOOL verbose;
/*! @brief Determines whether or not additional logging is enabled. */
@property BOOL veryVerbose;


// Only local database operations allowed
/*! @brief Activated either manually, or automatically if a lack of internet connection is detected. Determines whether or not to allow remote Postgres operations */
@property BOOL offlineMode;


// Write Protectors
/*! @brief Determines whether writing to Postgres is allowed. Off by default. */
@property BOOL preventWriteToPostgres;
/*! @brief Determines whether writing to SQLite is allowed. Off by default. */
@property BOOL preventWriteToSQLite;



// Initialization Functions
/*!
 @brief Initializes the @c TOMPGSQLite object.
 
 @discussion Initializes the remote Postgres connection using a typical configuration string, and opens the local PGSQLite database (and copies it to a writable location if necessary).
 
 @code
 TOMPGSQLite *databaseManager = [[TOMPGSQLite alloc] initWithPostgresConfigration:@"user=admin dbname=sample_db" andLocalSQLiteDatabaseNamed:@"sampledb.sql"];
 @endcode
 
 @param configString A Postgres connection configuration string, just like you'd normally use to connect to Postgres.
 @param databaseName The name of your SQLite database. It needs to be in the Resources Directory (preferably), or in the Documents Directory in order to be found.
 
 @return @c id - After initializing everything, it returns itself (or @c nil if it could not be initialized).
 */
- (id)initWithPostgresConfigration:(NSString *)configString andLocalSQLiteDatabaseNamed:(NSString *)databaseName;

/*!
 @brief Opens a new connection to a remote Postgres database.
 
 @discussion Opens a new connection to a remote Postgres database. If a connection is currently open, it is closed first.
 
 @code
 [manager openPGConnectionWithConfiguration:@"user=admin dbname=sample_db"];
 @endcode
 
 @param configurationString A Postgres connection configuration string, just like you'd normally use to connect to Postgres.

 @return @c Void - there isn't anything to return.
 */
- (void)openPGConnectionWithConfiguration:(NSString *)configurationString;

/*!
 @brief Opens a SQLite database.
 
 @discussion Opens a SQLite database. If one is currently open, it is closed first.
 
 @code
 [manager openSQLiteDatabaseNamed:@"user=admin dbname=sample_db"];
 @endcode
 
 @param databaseName The name of your SQLite database. It needs to be in the Resources Directory (preferably), or in the Documents Directory in order to be found.

 @return @c Void - there isn't anything to return.
 */
- (void)openSQLiteDatabaseNamed:(NSString *)databaseName;


// Postgres Functions
/*!
 @brief Sends data to the Postgres database with a SQL query.
 
 @discussion Sends data to the Postgres database with a SQL query (@c INSERT, @c UPDATE, etc).
 
 @code
 [manager sendDataToPostgres:@"CREATE TABLE sample_data(note VARCHAR(255));"];
 @endcode
 
 @warning There is no automatic checking to prevent the execution of a query that retrives data.
 
 @param query The query you'd like Postgres to execute.
 
 @return @c Void - there isn't anything to return.
 */
- (void)sendDataToPostgres:(NSString *)query;

/*!
 @brief Retrieves data from the Postgres database with a SQL query.
 
 @discussion Retrieves data from the Postgres database with a SQL query (@c SELECT).
 
 @code
 [manager sendDataToPostgres:@"SELECT * FROM sample_data;"];
 @endcode
 
 @note The names of the columns are not automatically retrieved or tracked.
 
 @warning There is no automatic checking to prevent the execution of a query that creates data
 
 @param query The query you'd like Postgres to execute.
 
 @return @c NSArray - a 2D array of all the rows with all their columns returned by the query.
 */
- (NSArray *)getDataFromPostgres:(NSString *)query;


// SQLite Functions
/*!
 @brief Sends data to the SQLite database with a SQL query.
 
 @discussion Sends data to the SQLite database with a SQL query (@c INSERT, @c UPDATE, etc).
 
 @code
 [manager sendDataToSQLite:@"CREATE TABLE sample_data(note VARCHAR(255));"];
 @endcode
 
 @warning There is no automatic checking to prevent the execution of a query that retrives data.
 
 @param query The query you'd like SQLite to execute.
 
 @return @c Void - there isn't anything to return.
 */
- (void)sendDataToSQLite:(NSString *)query;

/*!
 @brief Retrieves data from the SQLite database with a SQL query.
 
 @discussion Retrieves data from the SQLite database with a SQL query (@c SELECT).
 
 @code
 [manager getDataFromSQLite:@"SELECT * FROM sample_data;"];
 @endcode
 
 @note The names of the columns are not automatically retrieved or tracked.
 
 @warning There is no automatic checking to prevent the execution of a query that creates data
 
 @param query The query you'd like SQLite to execute.
 
 @return @c NSArray - a 2D array of all the rows with all their columns returned by the query.
 */
- (NSArray *)getDataFromSQLite:(NSString *)query;


// Synchronization - TODO
//- (void)autoSync;
//- (void)syncPostgresToSQLite;
//- (void)syncSQLiteToPostgres;


// Recheck Internet Connectivity
/*!
 @brief Asynchronously checks if an internet connection is present and activates Offline Mode if it isn't.
 
 @discussion Asynchronously checks if an internet connection is present and activates Offline Mode if it isn't. It accomplishes this using the Reachability librry, which is inherently asynchronous.
 
 @code
 [manager checkForInternetConnection];
 @endcode
 
 @return @c Void - there isn't anything to return. When it finishes it's asynchronous operation, it will set @c offlineMode to the appropriate value.
 */
- (void)checkForInternetConnection;


// Cleanup
/*!
 @brief Cleanly closes the Postgres connection and the SQLite database.
 
 @discussion Cleanly closes the Postgres connection and the SQLite database. Should be called after all database operations are complete.
 
 @code
 [manager quit];
 @endcode
 
 @return @c Void - there isn't anything to return.
 */
- (void)quit;

/*!
 @brief Cleanly closes the Postgres connection.
 
 @discussion Cleanly closes the Postgres connection. Should be called after all database operations are complete.
 
 @code
 [manager closePostgresConnection];
 @endcode
 
 @return @c Void - there isn't anything to return.
 */
- (void)closePostgresConnection;

/*!
 @brief Cleanly closes the SQLite connection.
 
 @discussion Cleanly closes the SQLite connection. Should be called after all database operations are complete.
 
 @code
 [manager closeSQLiteDatabase];
 @endcode
 
 @return @c Void - there isn't anything to return.
 */
- (void)closeSQLiteDatabase;

@end


