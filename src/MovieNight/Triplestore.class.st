"
I am a persisted collection of Triples, backed by a sqlite database.

You can create an instance of me by sending the #open: message to my class, providing the
filename of the sqlite database to be used for persistence. If the file does not yet exists,
a new database will be created and initialised with my schema.

You can add a new Entity-Attribute-Value Triple or update an existing one by sending me the
#forEntity:attribute:setValue: message. If I don't contain a Triple for that Entity-Attribute
pair, I'll create a new one and set it to the given value. If I do already contain such an
Entity-Attribute pair, I'll update the value to the value given. If the value of any Triple
I contain is updated, I'll immediately persist the change to my database.

My 'testing' protocol has methods for interrogating my state.

My 'querying' protocol has methods for finding Triples, attributes, and values, based on certain criteria.

Lifecycle

If you create an instance of me by sending an #open: message to my class, I'll open a connection to
my database when I'm instantiated. You can tell me to close my connection to my database by sending me
the #close message.

When I'm closed, you can no longer add or remove Triples to/from me, or update the value of any Triples I contain.

You can tell me to re-open the connection to my database by sending me the #open messsage.
"
Class {
	#name : #Triplestore,
	#superclass : #Object,
	#instVars : [
		'file',
		'eav',
		'db'
	],
	#category : #MovieNight
}

{ #category : #constants }
Triplestore class >> ddl [
  "Answer with an array of DDL statements to be executed to prep the database."
	^ #('CREATE TABLE IF NOT EXISTS triple (
		entity TEXT NOT NULL,
		attr TEXT NOT NULL,
		value TEXT NOT NULL
	);' 'CREATE UNIQUE INDEX IF NOT EXISTS triple_ev_IDX ON triple (entity,attr);' 'CREATE INDEX IF NOT EXISTS triple_av_IDX ON triple (attr,value);')
]

{ #category : #constructor }
Triplestore class >> open: aFilename [
	"Opens a SQLite triplestore database at the given filename"
	^ self new file: aFilename; open; yourself
]

{ #category : #private }
Triplestore >> addTriple: aCollection [
	| newTriple |
	newTriple := Triple
		for: aCollection
		onChange:
			[ :triple :newValue :oldValue | self tripleUpdated: triple newValue: newValue ].
	eav at: aCollection first at: aCollection second put: newTriple.
	^ newTriple
]

{ #category : #querying }
Triplestore >> allTriples [
	^ eav values flatCollect: [ :av | av values ]
]

{ #category : #querying }
Triplestore >> attributesOfEntity: anEntityId [
	^ Dictionary newFrom: ((eav at: anEntityId ifAbsent: [ ^ Dictionary empty ] ) collect: #value)
]

{ #category : #'initialize-release' }
Triplestore >> close [
	db close.
]

{ #category : #private }
Triplestore >> delete: aTriple [
	db
		execute: 'delete from triple where entity = ? and attr = ?'
		value: aTriple entity 
		value: aTriple attribute 
]

{ #category : #private }
Triplestore >> deleteAll [
	db execute: 'delete from triple'
]

{ #category : #accessing }
Triplestore >> file [
	^ file copy
]

{ #category : #accessing }
Triplestore >> file: anObject [
	file
		ifNil: [ file := anObject ifNotNil: [ :it | it asFileReference ] ifNil: [ self error: 'File cannot be nil' ] ]
		ifNotNil: [ self error: 'File is already set' ]
]

{ #category : #modifying }
Triplestore >> forEntity: anEntityId attribute: anAttributeId setValue: anObject [
	^ (self isValueDefinedForEntity: anEntityId attribute: anAttributeId)
		ifTrue: [ (self tripleForEntity: anEntityId attribute: anAttributeId)
				value: anObject;
				yourself ]
		ifFalse: [ self
				addTriple:
					{anEntityId.
					anAttributeId.
					anObject} ]
]

{ #category : #initialization }
Triplestore >> initialize [
	self initialize: nil
]

{ #category : #initialization }
Triplestore >> initialize: anInteger [
	"Initialize the store to hold an initial `anInteger` number of triples"
	eav := anInteger ifNil: [ Dictionary new ] ifNotNil: [ Dictionary new: anInteger ]
]

{ #category : #testing }
Triplestore >> isEmpty [
	^ eav isEmpty
]

{ #category : #testing }
Triplestore >> isNotEmpty [
	^ self isEmpty not.
]

{ #category : #testing }
Triplestore >> isValueDefinedForEntity: anEntityId attribute: anAttributeId [
	^ (eav at: anEntityId at: anAttributeId ifAbsent: nil) isNotNil
]

{ #category : #private }
Triplestore >> load [
	| results |
	results := (db execute: 'select entity, attr, value from triple')
		rows.
	self initialize: results size.
	results
		do: [ :row | 
			self
				forEntity: row first value
				attribute: row second value
				setValue: row third value ]
]

{ #category : #'initialize-release' }
Triplestore >> open [
	db := (SQLite3Connection on: self file pathString)
		open;
		yourself.
	self class ddl do: [ :ddl | db execute: ddl ].
	self load
]

{ #category : #modifying }
Triplestore >> removeAll [
	self deleteAll.
	self initialize.
]

{ #category : #querying }
Triplestore >> tripleForEntity: anEntityId attribute: anAttributeId [
	^ eav at: anEntityId at: anAttributeId ifAbsent: nil
]

{ #category : #private }
Triplestore >> tripleUpdated: triple newValue: anObject [
	anObject
		ifNil: [ self delete: triple ]
		ifNotNil: [ self upsert: triple ]
]

{ #category : #querying }
Triplestore >> triplesForEntity: anEntityId [
	^ (eav at: anEntityId ifAbsent: [ Dictionary empty ]) values 
]

{ #category : #private }
Triplestore >> upsert: aTriple [
	db
		execute: 'insert into triple (entity, attr, value) values (?, ?, ?) on conflict (entity, attr) do update set value = excluded.value'
		value: aTriple entity
		value: aTriple attribute
		value: aTriple value.
]

{ #category : #querying }
Triplestore >> valueOfEntity: anEntityId attribute: anAttributeId [
	^ (self tripleForEntity: anEntityId attribute: anAttributeId)
		ifNil: nil
		ifNotNil: [ :triple | triple value ]
]
