'From Cuis 4.1 of 12 December 2012 [latest update: #1576] on 24 January 2013 at 3:26:29 pm'!
'Description '!
!classDefinition: #SQLiteConnection category: #'SQLite3-Core-Public'!
Object subclass: #SQLiteConnection
	instanceVariableNames: 'reference fileName txn'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SQLite3-Core-Public'!
!classDefinition: 'SQLiteConnection class' category: #'SQLite3-Core-Public'!
SQLiteConnection class
	instanceVariableNames: 'registry'!

!classDefinition: #SQLiteRecord category: #'SQLite3-Core-Public'!
Dictionary subclass: #SQLiteRecord
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SQLite3-Core-Public'!
!classDefinition: 'SQLiteRecord class' category: #'SQLite3-Core-Public'!
SQLiteRecord class
	instanceVariableNames: ''!

!classDefinition: #SqliteError category: #'SQLite3-Core-Support'!
ExternalStructure subclass: #SqliteError
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SQLite3-Core-Support'!
!classDefinition: 'SqliteError class' category: #'SQLite3-Core-Support'!
SqliteError class
	instanceVariableNames: ''!

!classDefinition: #SqliteLibrary category: #'SQLite3-Core-Support'!
ExternalLibrary subclass: #SqliteLibrary
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SQLite3-Core-Support'!
!classDefinition: 'SqliteLibrary class' category: #'SQLite3-Core-Support'!
SqliteLibrary class
	instanceVariableNames: 'default'!

!classDefinition: #SqliteReference category: #'SQLite3-Core-Support'!
ExternalStructure subclass: #SqliteReference
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SQLite3-Core-Support'!
!classDefinition: 'SqliteReference class' category: #'SQLite3-Core-Support'!
SqliteReference class
	instanceVariableNames: ''!

!classDefinition: #SqliteResult category: #'SQLite3-Core-Support'!
Object subclass: #SqliteResult
	instanceVariableNames: 'buffer rows columns columnNames index'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SQLite3-Core-Support'!
!classDefinition: 'SqliteResult class' category: #'SQLite3-Core-Support'!
SqliteResult class
	instanceVariableNames: ''!

!classDefinition: #SqliteResultBuffer category: #'SQLite3-Core-Support'!
ExternalStructure subclass: #SqliteResultBuffer
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'SQLite3-Core-Support'!
!classDefinition: 'SqliteResultBuffer class' category: #'SQLite3-Core-Support'!
SqliteResultBuffer class
	instanceVariableNames: ''!


!SQLiteConnection commentStamp: 'spd 5/19/2010 14:50' prior: 0!
I connect to sqlite3 databases.To create an in-memory database, set the fileName to ':memory:'.  See "http://www.sqlite.org/c3ref/open.html" for more info.!

!SQLiteConnection methodsFor: 'finalization' stamp: 'tbn 1/25/2010 19:58'!
actAsExecutor	super actAsExecutor.	fileName := nil! !

!SQLiteConnection methodsFor: 'public' stamp: 'ab 1/31/2003 16:20'!
changedRows	^ self isOpen		ifTrue: [SqliteLibrary default changedRows: reference]		ifFalse: [0]	! !

!SQLiteConnection methodsFor: 'private' stamp: 'tbn 1/25/2010 19:58'!
close	self unregister.	self isOpen ifTrue: [SqliteLibrary default close: reference].	reference := nil.! !

!SQLiteConnection methodsFor: 'private' stamp: 'ar 12/12/2011 20:50'!
commit	txn := false.	self execute: 'COMMIT' args: {}.! !

!SQLiteConnection methodsFor: 'prepared statements' stamp: 'ar 12/9/2011 19:23'!
execute: query args: args	^Array streamContents:[:s|		self execute: query args: args do:[:result| s nextPut: result].	].! !

!SQLiteConnection methodsFor: 'prepared statements' stamp: 'ar 12/12/2011 19:04'!
execute: query args: args do: aBlock	self isOpen ifFalse: [self open].	^SqliteLibrary default execute: query args: args on: reference do: aBlock.! !

!SQLiteConnection methodsFor: 'public' stamp: 'ab 1/29/2003 16:37'!
executeQuery: aString	^ self withResultForQuery: aString do:		[:result |		Array streamContents:			[:s |			result do: [:row | s nextPut: row]]]! !

!SQLiteConnection methodsFor: 'public' stamp: 'ab 12/16/2002 00:27'!
fileName	^ fileName! !

!SQLiteConnection methodsFor: 'private' stamp: 'spd 5/19/2010 14:52'!
fileName: aString	"* Macs (tested OS 10.6.2) require an absolute file path to the database, Windows and Ubuntu do not	 * To create an in-memory database, pass ':memory:' as the argument."	fileName := aString! !

!SQLiteConnection methodsFor: 'finalization' stamp: 'ab 2/22/2003 23:15'!
finalize	self close.! !

!SQLiteConnection methodsFor: 'private' stamp: 'ab 12/16/2002 00:28'!
isOpen	^ reference notNil and: [reference getHandle anySatisfy: [:i | i > 0]]! !

!SQLiteConnection methodsFor: 'public' stamp: 'ab 12/16/2002 00:34'!
lastInsertId	^ self isOpen		ifTrue: [SqliteLibrary default lastInsertId: reference]		ifFalse: [0]	! !

!SQLiteConnection methodsFor: 'private' stamp: 'tbn 1/25/2010 19:58'!
open	reference := SqliteLibrary default open: fileName.	self register.! !

!SQLiteConnection methodsFor: 'finalization' stamp: 'ab 2/22/2003 22:31'!
register	self class registry add: self! !

!SQLiteConnection methodsFor: 'private' stamp: 'ar 12/12/2011 20:51'!
rollback	txn := false.	self execute: 'ROLLBACK' args: {}.! !

!SQLiteConnection methodsFor: 'private' stamp: 'ar 12/12/2011 20:50'!
transact	txn := true.	self execute: 'BEGIN TRANSACTION' args: {}.! !

!SQLiteConnection methodsFor: 'public' stamp: 'ar 12/12/2011 20:51'!
transaction: aBlock	"Wrap the given block inside a transaction"	| result |	txn ifNotNil:[^aBlock value].	[self transact.	result := aBlock value.	self commit.	] ifCurtailed:[self rollback].	^result! !

!SQLiteConnection methodsFor: 'finalization' stamp: 'ab 2/22/2003 22:32'!
unregister	self class registry remove: self ifAbsent: []! !

!SQLiteConnection methodsFor: 'public' stamp: 'tbn 1/25/2010 19:58'!
withResultForQuery: aString do: aBlock	|result|	self isOpen ifFalse: [self open].	result := SqliteLibrary default resultForQuery: aString on: reference.	^ [aBlock value: result] ensure: [result free]! !

!SQLiteConnection class methodsFor: 'instance creation' stamp: 'ab 12/16/2002 00:27'!
fileNamed: aString	^ self new fileName: aString! !

!SQLiteConnection class methodsFor: 'accessing' stamp: 'tbn 1/25/2010 19:58'!
registry	^ registry ifNil: [registry := WeakRegistry new]! !

!SQLiteRecord methodsFor: 'accessing' stamp: 'ar 12/9/2011 19:19'!
doesNotUnderstand: aMessage	"Allow read access with common selector names"	^self at: aMessage selector ifAbsent:[super doesNotUnderstand: aMessage].! !

!SQLiteRecord methodsFor: 'initialize' stamp: 'ar 12/9/2011 19:20'!
names: names values: values	names with: values do:[:n :v| self at: n put: v].! !

!SQLiteRecord class methodsFor: 'as yet unclassified' stamp: 'ar 12/9/2011 19:19'!
names: names values: values	^self new names: names values: values! !

!SqliteError methodsFor: 'accessing' stamp: 'hjh 1/24/2013 15:13'!
value	"This method was automatically generated"	^ExternalData fromHandle: (handle pointerAt: 1) type: ExternalType char asPointerType! !

!SqliteError methodsFor: 'accessing' stamp: 'hjh 1/24/2013 15:13'!
value: anObject	"This method was automatically generated"	handle pointerAt: 1 put: anObject getHandle.! !

!SqliteError class methodsFor: 'definitions' stamp: 'ab 12/15/2002 21:55'!
fields	"self defineFields"	^ #((value 'char*'))! !

!SqliteError class methodsFor: 'class initialization' stamp: 'ab 12/15/2002 22:17'!
initialize	self defineFields! !

!SqliteLibrary methodsFor: 'api' stamp: 'ar 12/8/2011 13:33'!
apiBindDouble: stmt with: index with: double	"int sqlite3_bind_double(sqlite3_stmt*, int, double);"	<cdecl: long 'sqlite3_bind_double' (ulong long double)>	^self externalCallFailed! !

!SqliteLibrary methodsFor: 'api' stamp: 'ar 12/8/2011 13:33'!
apiBindInt: stmt with: index with: value	"int sqlite3_bind_int(sqlite3_stmt*, int, int);"	<cdecl: long 'sqlite3_bind_int' (ulong long long)>	^self externalCallFailed! !

!SqliteLibrary methodsFor: 'api' stamp: 'ar 12/8/2011 13:33'!
apiBindNull: stmt with: index	"int sqlite3_bind_null(sqlite3_stmt*, int);"	<cdecl: long 'sqlite3_bind_null' (ulong long)>	^self externalCallFailed! !

!SqliteLibrary methodsFor: 'api' stamp: 'ar 12/8/2011 13:16'!
apiBindParameterCount: pStmt	"int sqlite3_bind_parameter_count(sqlite3_stmt*)"	<cdecl: long 'sqlite3_bind_parameter_count' (ulong)>	^ self externalCallFailed ! !

!SqliteLibrary methodsFor: 'api' stamp: 'ar 12/8/2011 13:34'!
apiBindText: stmt with: index with: value with: length with: destructor	"int sqlite3_bind_text(sqlite3_stmt*, int, const char*, int n, void(*)(void*));"	<cdecl: long 'sqlite3_bind_text' (ulong long char* long long)>	^self externalCallFailed! !

!SqliteLibrary methodsFor: 'api' stamp: 'cf 11/23/2005 15:31'!
apiChanges: sqlite	"int sqlite_changes(sqlite*)"	<cdecl: long 'sqlite3_changes' (SqliteReference)>	^ self externalCallFailed ! !

!SqliteLibrary methodsFor: 'api' stamp: 'cf 11/23/2005 15:15'!
apiClose: sqlite	"int sqlite3_close(sqlite3*)"	<cdecl: long 'sqlite3_close' (SqliteReference)>	^ self externalCallFailed ! !

!SqliteLibrary methodsFor: 'api' stamp: 'ar 12/8/2011 14:44'!
apiColumnCount: hStmt	"int sqlite3_column_count(sqlite3_stmt*);"	<cdecl: long 'sqlite3_column_count' (ulong)>	^self externalCallFailed! !

!SqliteLibrary methodsFor: 'api' stamp: 'ar 12/8/2011 13:51'!
apiColumnDouble: hStmt with: iCol	"double sqlite3_column_double(sqlite3_stmt*, int iCol);"	<cdecl: double 'sqlite3_column_double' (ulong long)>	^self externalCallFailed! !

!SqliteLibrary methodsFor: 'api' stamp: 'ar 12/8/2011 13:52'!
apiColumnInt: hStmt with: iCol	"int sqlite3_column_int(sqlite3_stmt*, int iCol);"	<cdecl: long 'sqlite3_column_int' (ulong long)>	^self externalCallFailed! !

!SqliteLibrary methodsFor: 'api' stamp: 'ar 12/9/2011 19:11'!
apiColumnName: hStmt with: iCol	"char* sqlite3_column_name(sqlite3_stmt*, int iCol);"	<cdecl: char* 'sqlite3_column_name' (ulong long)>	^self externalCallFailed! !

!SqliteLibrary methodsFor: 'api' stamp: 'ar 12/8/2011 13:52'!
apiColumnText: hStmt with: iCol	"char* sqlite3_column_int(sqlite3_stmt*, int iCol);"	<cdecl: char* 'sqlite3_column_text' (ulong long)>	^self externalCallFailed! !

!SqliteLibrary methodsFor: 'api' stamp: 'ar 12/8/2011 15:00'!
apiColumnType: hStmt with: iCol	"int sqlite3_column_type(sqlite3_stmt*, int iCol);"	<cdecl: long 'sqlite3_column_type' (ulong long)>	^self externalCallFailed! !

!SqliteLibrary methodsFor: 'api' stamp: 'cf 11/23/2005 15:52'!
apiErrorMessage: anSqlite	"const char *sqlite3_errmsg(sqlite3*)"	<cdecl: SqliteError 'sqlite3_errmsg' (SqliteReference)>	^ self externalCallFailed ! !

!SqliteLibrary methodsFor: 'api' stamp: 'ar 12/8/2011 14:12'!
apiFinalize: pStmt	"int sqlite3_finalize(sqlite3_stmt *pStmt);"	<cdecl: long 'sqlite3_finalize' (ulong)>	^self externalCallFailed! !

!SqliteLibrary methodsFor: 'api' stamp: 'cf 11/23/2005 15:32'!
apiFreeTable: buffer	"void sqlite3_free_table(char **result)"	<cdecl: void 'sqlite3_free_table' (SqliteResultBuffer)>	^ self externalCallFailed! !

!SqliteLibrary methodsFor: 'api' stamp: 'cf 11/23/2005 15:34'!
apiGetTable: anSqlite sql: sql buffer: result rows: nRows columns: nColumns error: errBuffer	"int sqlite3_get_table(  sqlite*,  char *sql,  char ***result,  int *nrow,  int *ncolumn,  char **errmsg	)"	<cdecl: long 'sqlite3_get_table' (SqliteReference char* SqliteResultBuffer* long* long* SqliteError*)>	^ self externalCallFailed ! !

!SqliteLibrary methodsFor: 'api' stamp: 'cf 11/23/2005 15:35'!
apiLastInsertId: sqlite	"long long int sqlite3_last_insert_rowid(sqlite3*)"	<cdecl: longlong 'sqlite3_last_insert_rowid' (SqliteReference)>	^ self externalCallFailed ! !

!SqliteLibrary methodsFor: 'api' stamp: 'cf 11/22/2005 21:59'!
apiOpen: dbName sqlite: sqlite	"int sqlite3_open(const char*, sqlite3**);"	<cdecl: long 'sqlite3_open' (char* SqliteReference*)>	^ self externalCallFailed! !

!SqliteLibrary methodsFor: 'api' stamp: 'ar 12/8/2011 13:11'!
apiPrepareV2: db with: zSql with: nByte with: ppStmt with: pzTail	"int sqlite3_prepare_v2(	  sqlite3 *db,            /* Database handle */	  const char *zSql,       /* SQL statement, UTF-8 encoded */	  int nByte,              /* Maximum length of zSql in bytes. */	  sqlite3_stmt **ppStmt,  /* OUT: Statement handle */	  const char **pzTail     /* OUT: Pointer to unused portion of zSql */	);"	<cdecl: long 'sqlite3_prepare_v2' (SqliteReference char* long ulong* ulong*)>	^ self externalCallFailed ! !

!SqliteLibrary methodsFor: 'api' stamp: 'ar 12/8/2011 13:51'!
apiStep: hStmt	"int sqlite3_step(sqlite3_stmt*);"	<cdecl: long 'sqlite3_step' (ulong)>	^self externalCallFailed! !

!SqliteLibrary methodsFor: 'accessing' stamp: 'ar 12/8/2011 15:11'!
bindArg: arg at: index in: stmt	arg == true ifTrue:[^self apiBindInt: stmt with: index with: 1].	arg == false ifTrue:[^self apiBindInt: stmt with: index with: 0].	arg ==  nil ifTrue:[^self apiBindNull: stmt with: index].	arg isInteger ifTrue:[^self apiBindInt: stmt with: index with: arg].	arg isFloat ifTrue:[^self apiBindDouble: stmt with: index with: arg].	arg isString ifTrue:[^self apiBindText: stmt with: index with: arg with: arg size with: -1].	(arg isKindOf: DateAndTime) ifTrue:[ | string |		string := String streamContents:[:s|			arg printYMDOn: s withLeadingSpace: false.			s nextPut: $T.			arg printHMSOn: s.		].		^self bindArg: string at: index in: stmt	].	self error: 'Cannot bind argument'! !

!SqliteLibrary methodsFor: 'accessing' stamp: 'ab 1/31/2003 16:20'!
changedRows: anSqliteRef	^ self apiChanges: anSqliteRef! !

!SqliteLibrary methodsFor: 'accessing' stamp: 'cf 11/23/2005 15:36'!
checkError: anError	|message|	(anError getHandle allSatisfy: [:i | i = 0]) ifTrue: [^ self].	message := anError value fromCString.	anError free.	self error: message	! !

!SqliteLibrary methodsFor: 'accessing' stamp: 'ar 12/8/2011 14:32'!
checkErrorInteger: anError	|message|	(anError = 0) ifTrue: [^self].	"Get the errmsg"	message := 'Result Code: ', anError asString.	self error: message! !

!SqliteLibrary methodsFor: 'accessing' stamp: 'tbn 1/25/2010 19:52'!
close: anSqliteRef	| err |	err := self apiClose: anSqliteRef.	self checkErrorInteger: err.! !

!SqliteLibrary methodsFor: 'accessing' stamp: 'ar 12/12/2011 19:04'!
execute: query args: args on: sqliteRef do: aBlock	"Execute the given query, binding the arguments as needed"	| ppStmt hStmt code colCount result value err names rval |	ppStmt := WordArray new: 1.	(err := self apiPrepareV2: sqliteRef with: query with: query size with: ppStmt with: nil) == 0		ifFalse:[self error: 'sqlite_prepare_v2 failed: ', err printString].	hStmt := ppStmt at: 1.	(self apiBindParameterCount: hStmt) = args size 		ifFalse:[self error:'Argument count mismatch'].	1 to: args size do:[:idx|		self bindArg: (args at: idx) at: idx in: hStmt.	].	colCount := nil.	[code := self apiStep: hStmt.	code = 100] whileTrue:[		colCount ifNil:[			colCount := self apiColumnCount: hStmt.			result := Array new: colCount.			names := Array new: colCount.			1 to: colCount do:[:i|				names at: i put: (self apiColumnName: hStmt with: i-1) asSymbol.			].		].		1 to: colCount do:[:i| | colIdx |			colIdx := i-1.			(self apiColumnType: hStmt with: colIdx) caseOf: {				[1] -> [value := self apiColumnInt: hStmt with: colIdx].				[2] -> [value := self apiColumnDouble: hStmt with: colIdx].				[3] -> [value := self apiColumnText: hStmt with: colIdx].				[4] -> [self error: 'Blobs are not supported'].				[5] -> [value := nil].			}.			result at: i put: value.		].		rval := aBlock numArgs = result size 			ifTrue:[aBlock valueWithArguments: result]			ifFalse:[aBlock value: (SQLiteRecord names: names values: result)].	].	self apiFinalize: hStmt.	code = 101 ifFalse:[self error: 'Error code: ', code printString].	^rval! !

!SqliteLibrary methodsFor: 'accessing' stamp: 'ab 12/16/2002 01:30'!
freeResultBuffer: aResultBuffer	self apiFreeTable: aResultBuffer! !

!SqliteLibrary methodsFor: 'accessing' stamp: 'ab 12/16/2002 00:23'!
lastInsertId: anSqliteRef	^ self apiLastInsertId: anSqliteRef! !

!SqliteLibrary methodsFor: 'accessing' stamp: 'cf 11/23/2005 15:22'!
open: aString	|err ref|	ref := SqliteReference new.	err := self apiOpen: aString sqlite: ref.	self checkErrorInteger: err.	^ ref! !

!SqliteLibrary methodsFor: 'accessing' stamp: 'tbn 1/25/2010 19:52'!
resultForQuery: aString on: sqliteRef	|nrows ncols buffer err|	nrows := WordArray new: 1.	ncols := WordArray new: 1.	err := SqliteError new.	buffer := SqliteResultBuffer new.	self apiGetTable: sqliteRef sql: aString buffer: buffer rows: nrows columns: ncols error: err.	self checkError: err.	^ SqliteResult buffer: buffer rows: nrows first columns: ncols first! !

!SqliteLibrary class methodsFor: 'accessing' stamp: 'tbn 1/25/2010 19:53'!
default	^ default ifNil: [default := super new]! !

!SqliteLibrary class methodsFor: 'accessing' stamp: 'tbn 4/1/2008 20:04'!
moduleName	"Was: ^ 'sqlite'"	^ 'sqlite3'! !

!SqliteReference methodsFor: 'accessing' stamp: 'hjh 1/24/2013 15:13'!
value	"This method was automatically generated"	^ExternalData fromHandle: (handle pointerAt: 1) type: ExternalType void asPointerType! !

!SqliteReference methodsFor: 'accessing' stamp: 'hjh 1/24/2013 15:13'!
value: anObject	"This method was automatically generated"	handle pointerAt: 1 put: anObject getHandle.! !

!SqliteReference class methodsFor: 'field definition' stamp: 'cf 11/22/2005 21:38'!
fields	"self defineFields"	^ #((value 'void*'))! !

!SqliteReference class methodsFor: 'class initialization' stamp: 'cf 11/22/2005 21:58'!
initialize	"SqliteReference initialize"	self defineFields! !

!SqliteResult methodsFor: 'public' stamp: 'ab 12/16/2002 01:58'!
atEnd	^ index > (rows + 1 * columns)! !

!SqliteResult methodsFor: 'public' stamp: 'ab 1/29/2003 16:06'!
columnNames	^ columnNames! !

!SqliteResult methodsFor: 'accessing' stamp: 'tbn 1/25/2010 19:54'!
currentAddress	|bytes base current|	bytes := buffer value getHandle asByteArrayPointer.	base := bytes unsignedLongAt: 1.	current := base + (index - 1 * 4).	bytes unsignedLongAt: 1 put: current.	^ bytes asExternalPointer 	! !

!SqliteResult methodsFor: 'public' stamp: 'ab 12/16/2002 01:56'!
do: aBlock	self reset.	rows timesRepeat: [aBlock value: self nextRow].	! !

!SqliteResult methodsFor: 'public' stamp: 'tbn 1/25/2010 19:54'!
free	SqliteLibrary default freeResultBuffer: buffer.	buffer := nil.! !

!SqliteResult methodsFor: 'public' stamp: 'ab 12/16/2002 01:58'!
nextKeysAndValuesDo: aBlock	self atEnd ifTrue: [self error: 'Trying to read past end of results'].	columnNames do:		[:ea |		aBlock value: ea value: self nextString]! !

!SqliteResult methodsFor: 'public' stamp: 'tbn 1/25/2010 19:54'!
nextRow	|row|	row := Dictionary new.	self nextKeysAndValuesDo: [:k :v | row at: k put: v].	^ row! !

!SqliteResult methodsFor: 'accessing' stamp: 'tbn 1/25/2010 19:55'!
nextString	|str|	buffer ifNil: [self error: 'Result has been freed'].	str := self readString.	index := index + 1.	^ str! !

!SqliteResult methodsFor: 'public' stamp: 'ab 1/29/2003 16:34'!
nextValues	^ columnNames collect: [:ea | self nextString]! !

!SqliteResult methodsFor: 'reading' stamp: 'tbn 1/25/2010 19:55'!
readColumns	columnNames := OrderedCollection new.	columns timesRepeat: [columnNames add: self nextString]! !

!SqliteResult methodsFor: 'reading' stamp: 'ab 12/16/2002 01:47'!
readString	^ self readStringAtAddress: (self currentAddress)! !

!SqliteResult methodsFor: 'reading' stamp: 'hjh 1/24/2013 15:20'!
readStringAtAddress: anAddress	|deref i char|	deref := anAddress pointerAt: 1.	(deref allSatisfy: [:ea | ea = 0]) ifTrue: [^ nil].	^ String streamContents:		[:stream |		i := 1.		[(char := deref unsignedCharAt: i) asciiValue = 0] 			whileFalse:				[stream nextPut: char.				 i := i + 1]]! !

!SqliteResult methodsFor: 'public' stamp: 'tbn 1/25/2010 19:55'!
reset	index := 1.	self readColumns.! !

!SqliteResult methodsFor: 'accessing' stamp: 'tbn 1/25/2010 19:55'!
setBuffer: aResultBuffer rows: nRows columns: nColumns	buffer := aResultBuffer.	rows := nRows.	columns := nColumns.	self reset.! !

!SqliteResult class methodsFor: 'instance creation' stamp: 'ab 12/16/2002 01:41'!
buffer: aResultBuffer rows: nRows columns: nColumns	^ self new setBuffer: aResultBuffer rows: nRows columns: nColumns! !

!SqliteResultBuffer methodsFor: 'accessing' stamp: 'hjh 1/24/2013 15:13'!
value	"This method was automatically generated"	^ExternalData fromHandle: (handle pointerAt: 1) type: ExternalType void asPointerType! !

!SqliteResultBuffer methodsFor: 'accessing' stamp: 'hjh 1/24/2013 15:13'!
value: anObject	"This method was automatically generated"	handle pointerAt: 1 put: anObject getHandle.! !

!SqliteResultBuffer class methodsFor: 'field definition' stamp: 'ab 12/16/2002 00:35'!
fields	"self defineFields"	^ #((value 'void*'))! !

!SqliteResultBuffer class methodsFor: 'class initialization' stamp: 'ab 1/14/2003 15:28'!
initialize	self defineFields! !
SqliteError initialize!
SqliteReference initialize!
SqliteResultBuffer initialize!
