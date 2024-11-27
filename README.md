SQLite3 for Cuis Smalltalk
-----------------

Status: Does not work currently in Cuis 7.1


"SQLite is a software library that implements a self-contained, serverless, zero-configuration, 
transactional SQL database engine. SQLite is the most widely deployed SQL database engine in the world.
The source code for SQLite 
is in the public domain."
https://sqlite.org/

This repostitory contains the access code to the library for Cuis Smalltalk https://github.com/jvuletich/Cuis.
The code is nearly the same as the original for Squeak Smalltalk.


### Original Squeak files used for the port

* SQLite3-Core-ar.8.mcz
* SQLite3-Tests-ar.4.mcz

from www.squeaksource.com

Author: Andreas Raab

Licence: MIT


### Installation

You need a SQLite3 library from https://sqlite.org/download.html
in your Cuis directory.


    Feature require: 'FFI'.

### Porting history

1.
The files SQLite3-Core-ar.8.mcz and then SQLite3-Tests-ar.4.mcz could be filed in as is into Cuis.

2.
A fix in the following method was necessary

Removed method #basicSqueakToIso


old

    SqliteResult>>
    readStringAtAddress: anAddress
    	|deref i char|
    	deref := anAddress pointerAt: 1.
    	(deref allSatisfy: [:ea | ea = 0]) ifTrue: [^ nil].
    	^ String streamContents:
    		[:stream |
    		i := 1.
    		[(char := deref unsignedCharAt: i) asciiValue = 0] 
    			whileFalse:
    				[stream nextPut: char basicSqueakToIso.
    				 i := i + 1]]


					 
new

    SqliteResult>>
    readStringAtAddress: anAddress
    	|deref i char|
    	deref := anAddress pointerAt: 1.
    	(deref allSatisfy: [:ea | ea = 0]) ifTrue: [^ nil].
    	^ String streamContents:
    		[:stream |
    		i := 1.
    		[(char := deref unsignedCharAt: i) asciiValue = 0] 
    			whileFalse:
    				[stream nextPut: char.
    				 i := i + 1]]

					 
3.
All 5 tests out of 5 passed

4.
Then the packages were saved and renamed as *.pck.st
					 
