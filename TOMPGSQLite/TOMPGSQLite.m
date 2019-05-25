//
//  TOMPGSQLite.m
//  TOMPGSQLite
//
//  Created by Tom Metzger on 12/12/18.
//  Copyright © 2018 Tom. All rights reserved.
//

#import "TOMPGSQLite.h"
#import "Reachability.h"





@interface TOMPGSQLite ()
{
	Reachability *internetReachability;
}


// Postgres Connection
@property PGconn *pgConnection;


// SQLite "Connection"
@property sqlite3 *sqliteDatabase;

@end





@implementation TOMPGSQLite

- (id)initWithPostgresConfigration:(NSString *)configString andLocalSQLiteDatabaseNamed:(NSString *)databaseName
{
	[self checkForInternetConnection];
	
	
	_pgConnection = PQconnectdb(configString.UTF8String);
	
	if (PQstatus(_pgConnection) == CONNECTION_BAD)
	{
		NSLog(@"[TOMPGSQLite] ERROR: Could not connect to remote Postgres database.");
		PQfinish(_pgConnection);
		return self;
	}
	
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:[[documentsDirectory stringByAppendingPathComponent:@".private"] stringByAppendingPathComponent:databaseName]])
	{
		if (_verbose || _veryVerbose)
		{
			NSLog(@"[TOMPGSQLite] Local SQLite Database already exists in a writable directory.");
		}
		
		NSString *sqliteDatabasePath = [[documentsDirectory stringByAppendingPathComponent:@".private"] stringByAppendingPathComponent:databaseName];
		if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: SQLite database path: %@", sqliteDatabasePath);
		
		BOOL sqliteDatabaseOpened = sqlite3_open(sqliteDatabasePath.UTF8String, &_sqliteDatabase);
		
		if (sqliteDatabaseOpened != SQLITE_OK)
		{
			NSLog(@"[TOMPGSQLite] ERROR: Could open local SQLite database:\n   - %s", sqlite3_errmsg(_sqliteDatabase));
			return self;
		}
		
		
		return self;
	}
	else
	{
		NSString *sqliteDatabaseResourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:sqliteDatabaseResourcePath])
		{
			NSLog(@"[TOMPGSQLite] ERROR: Could not find local SQLite database.");
			return self;
		}
		
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:@".private"] isDirectory:NULL])
		{
			NSError *error;
			[[NSFileManager defaultManager] createDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:@".private"] withIntermediateDirectories:NO attributes:nil error:&error];
			
			if (error != nil)
			{
				NSLog(@"[TOMPGSQLite] ERROR: Could not create private writable directory for SQLite databse:\n   - %@", [error localizedDescription]);
				return self;
			}
		}
		
		NSString *sqliteDatabasePath = [[documentsDirectory stringByAppendingPathComponent:@".private"] stringByAppendingPathComponent:databaseName];
		if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: SQLite database path: %@", sqliteDatabasePath);
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:sqliteDatabasePath])
		{
			NSError *error;
			[[NSFileManager defaultManager] copyItemAtPath:sqliteDatabaseResourcePath toPath:sqliteDatabasePath error:&error];
			
			if (error != nil)
			{
				NSLog(@"[TOMPGSQLite] ERROR: Could note move local SQLite database to writable location:\n   - %@", [error localizedDescription]);
				return self;
			}
		}
		else
		{
			if (_verbose || _veryVerbose)
			{
				NSLog(@"[TOMPGSQLite] Local SQLite Database already exists in a writable directory.");
			}
		}
		
		BOOL sqliteDatabaseOpened = sqlite3_open(sqliteDatabasePath.UTF8String, &_sqliteDatabase);
		
		if (sqliteDatabaseOpened != SQLITE_OK)
		{
			NSLog(@"[TOMPGSQLite] ERROR: Could open local SQLite database:\n   - %s", sqlite3_errmsg(_sqliteDatabase));
			return self;
		}
		
		
		return self;
	}
}




- (void)openPGConnectionWithConfiguration:(NSString *)configurationString
{
	[self checkForInternetConnection];
	
	
	if (_pgConnection != nil || PQstatus(_pgConnection) == CONNECTION_OK)
	{
		[self closePostgresConnection];
	}
	
	
	_pgConnection = PQconnectdb(configurationString.UTF8String);
	
	if (PQstatus(_pgConnection) == CONNECTION_BAD)
	{
		NSLog(@"[TOMPGSQLite] ERROR: Could not connect to remote Postgres database.");
		PQfinish(_pgConnection);
	}
}




- (void)openSQLiteDatabaseNamed:(NSString *)databaseName
{
	if (_sqliteDatabase != nil)
	{
		[self closeSQLiteDatabase];
	}
	
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:[[documentsDirectory stringByAppendingPathComponent:@".private"] stringByAppendingPathComponent:databaseName]])
	{
		if (_verbose || _veryVerbose)
		{
			NSLog(@"[TOMPGSQLite] Local SQLite Database already exists in a writable directory.");
		}
		
		NSString *sqliteDatabasePath = [[documentsDirectory stringByAppendingPathComponent:@".private"] stringByAppendingPathComponent:databaseName];
		if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: SQLite database path: %@", sqliteDatabasePath);
		
		BOOL sqliteDatabaseOpened = sqlite3_open(sqliteDatabasePath.UTF8String, &_sqliteDatabase);
		
		if (sqliteDatabaseOpened != SQLITE_OK)
		{
			NSLog(@"[TOMPGSQLite] ERROR: Could open local SQLite database:\n   - %s", sqlite3_errmsg(_sqliteDatabase));
			return;
		}
		
		
		return;
	}
	else
	{
		NSString *sqliteDatabaseResourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:sqliteDatabaseResourcePath])
		{
			NSLog(@"[TOMPGSQLite] ERROR: Could not find local SQLite database.");
			return;
		}
		
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:[documentsDirectory stringByAppendingPathComponent:@".private"] isDirectory:NULL])
		{
			NSError *error;
			[[NSFileManager defaultManager] createDirectoryAtPath:[documentsDirectory stringByAppendingPathComponent:@".private"] withIntermediateDirectories:NO attributes:nil error:&error];
			
			if (error != nil)
			{
				NSLog(@"[TOMPGSQLite] ERROR: Could not create private writable directory for SQLite databse:\n   - %@", [error localizedDescription]);
				return;
			}
		}
		
		NSString *sqliteDatabasePath = [[documentsDirectory stringByAppendingPathComponent:@".private"] stringByAppendingPathComponent:databaseName];
		if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: SQLite database path: %@", sqliteDatabasePath);
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:sqliteDatabasePath])
		{
			NSError *error;
			[[NSFileManager defaultManager] copyItemAtPath:sqliteDatabaseResourcePath toPath:sqliteDatabasePath error:&error];
			
			if (error != nil)
			{
				NSLog(@"[TOMPGSQLite] ERROR: Could note move local SQLite database to writable location:\n   - %@", [error localizedDescription]);
				return;
			}
		}
		else
		{
			if (_verbose || _veryVerbose)
			{
				NSLog(@"[TOMPGSQLite] Local SQLite Database already exists in a writable directory.");
			}
		}
		
		BOOL sqliteDatabaseOpened = sqlite3_open(sqliteDatabasePath.UTF8String, &_sqliteDatabase);
		
		if (sqliteDatabaseOpened != SQLITE_OK)
		{
			NSLog(@"[TOMPGSQLite] ERROR: Could open local SQLite database:\n   - %s", sqlite3_errmsg(_sqliteDatabase));
			return;
		}
		
		
		return;
	}
}




- (void)sendDataToPostgres:(NSString *)query
{
	if (_verbose || _veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Executing Postgres query: %@...", query);
	
	
	if (_offlineMode)
	{
		NSLog(@"[TOMPGSQLite] ISSUE: Offline Mode is activated.");
		return;
	}
	else
	{
		if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Offline Mode is not activated.");
	}
	
	if (_preventWriteToPostgres)
	{
		NSLog(@"[TOMPGSQLite] ISSUE: Write Blocking to Postgres is activated.");
		return;
	}
	else
	{
		if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Write Blocking to Postgres is not activated.");
	}
	
	
	if (_verbose || _veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Executing Query: %@...", query);
	PGresult *results = PQexec(_pgConnection, query.UTF8String);
	
	if (PQresultStatus(results) != PGRES_COMMAND_OK)
	{
		NSLog(@"[TOMPGSQLite] ERROR: Could not execute Postgres query:\n   - %s", PQerrorMessage(_pgConnection));
		PQclear(results);
		return;
	}
	else
	{
		if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Query executed fine.");
	}
	
	
	if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Clearing query results...");
	PQclear(results);
}




- (NSArray *)getDataFromPostgres:(NSString *)query
{
	if (_verbose || _veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Executing Postgres query: %@...", query);
	
	
	if (_offlineMode)
	{
		NSLog(@"[TOMPGSQLite] ISSUE: Offline Mode is activated.");
		return nil;
	}
	else
	{
		if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Offline Mode is not activated.");
	}
	
	
	PGresult *results = PQexec(_pgConnection, query.UTF8String);
	
	if (PQresultStatus(results) != PGRES_TUPLES_OK)
	{
		NSLog(@"[TOMPGSQLite] ERROR: Could not execute Postgres query:\n   - %s", PQerrorMessage(_pgConnection));
		PQclear(results);
		return nil;
	}
	else
	{
		if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Query executed fine.");
	}
	
	int rowCount = PQntuples(results);
	int columnCount = PQnfields(results);
	
	if (_verbose || _veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Row Count: %d, Column Count: %d", rowCount, columnCount);
	
	NSMutableArray *resultsTable = [[NSMutableArray alloc] init];
	for (int i = 0; i < rowCount; i++)
	{
		NSMutableArray *resultsRow = [[NSMutableArray alloc] init];
		for (int j = 0; j < columnCount; j++)
		{
			[resultsRow addObject:[NSString stringWithUTF8String: PQgetvalue(results, i, j)]];
			if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Value of column: %s", PQgetvalue(results, i, j));
		}
		if (_verbose || _veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Value of row: %@", resultsRow);
		[resultsTable addObject:resultsRow];
		if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Results Table is now: %@", resultsTable);
	}
	
	if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Clearing query results...");
	PQclear(results);
	
	
	if (_verbose || _veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Final Results Table: %@", resultsTable);
	
	
	return (NSArray *)resultsTable;
}




- (void)sendDataToSQLite:(NSString *)query
{
	if (_verbose || _veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Executing SQLite query: %@...", query);
	
	
	if (_preventWriteToSQLite)
	{
		NSLog(@"[TOMPGSQLite] ISSUE: Write Blocking to SQLite is activated.");
		return;
	}
	else
	{
		if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Write Blocking to SQLite is not activated.");
	}
	
	
	sqlite3_stmt *compiledStatement;
	BOOL prepareStatmentResult = sqlite3_prepare_v2(_sqliteDatabase, query.UTF8String, -1, &compiledStatement, NULL);
	
	if (prepareStatmentResult != SQLITE_OK)
	{
		NSLog(@"[TOMPGSQLite] ERROR: Could not prepare SQLite query:\n   - %s", sqlite3_errmsg(_sqliteDatabase));
		return;
	}
	else
	{
		if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Query prepared fine.");
	}
	
	
	int executedQueryResults = sqlite3_step(compiledStatement);
	
	if (executedQueryResults != SQLITE_DONE)
	{
		NSLog(@"[TOMPGSQLite] ERROR: Could not execute SQLite query:\n   - %s", sqlite3_errmsg(_sqliteDatabase));
	}
	
	
	if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Finalizing compiled statement...");
	sqlite3_finalize(compiledStatement);
}




- (NSArray *)getDataFromSQLite:(NSString *)query
{
	if (_verbose || _veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Executing SQLite query: %@...", query);
	
	
	sqlite3_stmt *compiledStatement;
	BOOL prepareStatmentResult = sqlite3_prepare_v2(_sqliteDatabase, query.UTF8String, -1, &compiledStatement, NULL);
	
	if (prepareStatmentResult != SQLITE_OK)
	{
		NSLog(@"[TOMPGSQLite] ERROR: Could not prepare SQLite query:\n   - %s", sqlite3_errmsg(_sqliteDatabase));
		return nil;
	}
	else
	{
		if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Query prepared fine.");
	}
	
	
	NSMutableArray *resultsTable = [[NSMutableArray alloc] init];
	while (sqlite3_step(compiledStatement) == SQLITE_ROW)
	{
		NSMutableArray *resultsRow = [[NSMutableArray alloc] init];
		
		int columnCount = sqlite3_column_count(compiledStatement);
		for (int i = 0; i < columnCount; i++)
		{
			char *columnAsString = (char *)sqlite3_column_text(compiledStatement, i);
			
			if (columnAsString != NULL)
			{
				[resultsRow addObject:[NSString stringWithUTF8String:columnAsString]];
			}
			
			if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Value of column: %s", columnAsString);
		}
		
		if (_verbose || _veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Value of row: %@", resultsRow);
		
		[resultsTable addObject:resultsRow];
		if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Results Table is now: %@", resultsTable);
	}
	
	
	if (_verbose || _veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Final Results Table: %@", resultsTable);
	
	
	if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Finalizing compiled statement...");
	sqlite3_finalize(compiledStatement);
	
	
	return (NSArray *)resultsTable;
}




- (void)quit
{
	if (_verbose || _veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Quitting...");
	
	
	if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Closing Postgres connection...");
	PQfinish(_pgConnection);
	if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Postgres connection closed.");
	
	
	if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Closing SQLite databse...");
	sqlite3_close(_sqliteDatabase);
	if (_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: SQLite database closed.");
	
	
	if (_verbose || _veryVerbose) NSLog(@"[TOMPGSQLite] INFO: All Connections Closed Successfully.");
}




- (void)closePostgresConnection
{
	if (_verbose || _veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Closing Postgres connection...");
	PQfinish(_pgConnection);
	if (_verbose || _veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Postgres connection closed.");
}




- (void)closeSQLiteDatabase
{
	if (_verbose || _veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Closing SQLite databse...");
	sqlite3_close(_sqliteDatabase);
	if (_verbose || _veryVerbose) NSLog(@"[TOMPGSQLite] INFO: SQLite database closed.");
}




- (void)checkForInternetConnection
{
	if (self->_verbose || self->_veryVerbose) NSLog(@"[TOMPGSQLite] INFO: Checking for an internet connection...");
	
	
	internetReachability = [Reachability reachabilityWithHostname:@"www.dev.reveraemulator.com"];
	
	
	// Internet is reachable
	internetReachability.reachableBlock = ^(Reachability*reach)
	{
		self->_offlineMode = NO;
		
		if (self->_verbose || self->_veryVerbose)
		{
			NSLog(@"[TOMPGSQLite] INFO: An internet conenction is present.");
		}
	};
	
	
	// Internet is not reachable
	internetReachability.unreachableBlock = ^(Reachability*reach)
	{
		NSLog(@"[TOMPGSQLite] ISSUE: No intetnet connection. Entering Offline Mode.");
		self->_offlineMode = YES;
	};
	
	
	[internetReachability startNotifier];
}

@end
