SQLite3 for Cuis
-----------------

### Original Squeak files used for the port

* SQLite3-Core-ar.8.mcz
* SQLite3-Tests-ar.4.mcz

from www.squeaksource.com

Author: Andreas Raab

Licences: MIT


### Installation

You need a SQLite3 library from https://sqlite.org/download.html
in your Cuis directory.

If you alrerady have installed FFI in Cuis 

do

    | slash |

    slash _ FileDirectory slash.
    {
         '..', slash, 'Cuis-SQLite3', slash, 'SQLite3-Core.pck.st' .
         '..', slash, 'Cuis-SQLite3', slash, 'SQLite3-Tests.pck.st' .
    }

    do:

    [ :fileName | CodePackageFile installPackageStream:
	
                 (FileStream concreteStream readOnlyFileNamed: fileName)
    ]   


otherwise download Cuis-FFI from https://github.com/hhzl/Cuis-FFI
into a sibling directory and do

    | slash |

    slash _ FileDirectory slash.
    {
		 '..', slash, 'Cuis-FFI', slash, 'FFI.pck.st' .
		 '..', slash, 'Cuis-SQLite3', slash, 'SQLite3-Core.pck.st' .
         '..', slash, 'Cuis-SQLite3', slash, 'SQLite3-Tests.pck.st' .
    }

    do:

    [ :fileName | CodePackageFile installPackageStream:
	
                 (FileStream concreteStream readOnlyFileNamed: fileName)
    ]   

	


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
					 
