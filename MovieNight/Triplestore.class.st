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
	^ '
	CREATE TABLE IF NOT EXISTS triple (
		entity TEXT NOT NULL,
		attr TEXT NOT NULL,
		value TEXT NOT NULL
	);
	
	CREATE UNIQUE INDEX IF NOT EXISTS triple_ev_IDX ON triple (entity,attr);
	CREATE INDEX IF NOT EXISTS triple_av_IDX ON triple (attr,value);'
]

{ #category : #constructor }
Triplestore class >> open: aFilename [
	"Opens a SQLite triplestore database at the given filename"
	^ self new file: aFilename; open; yourself
]

{ #category : #lookup }
Triplestore >> attributesOfEntity: anEntityId [
	^ Dictionary newFrom: ((eav at: anEntityId) collect: #value)
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

{ #category : #accessing }
Triplestore >> file [
	^ file copy
]

{ #category : #accessing }
Triplestore >> file: anObject [
	file
		ifNil: [ file := anObject ifNotNil: #value ifNil: [ self error: 'File cannot be nil' ] ]
		ifNotNil: [ self error: 'File is already set' ]
]

{ #category : #adding }
Triplestore >> forEntity: anEntityId attribute: anAttributeId setValue: anObject [
	^ (self tripleForEntity: anEntityId attribute: anAttributeId) value: anObject; yourself 
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
Triplestore >> isValueDefinedForEntity: anEntityId attribute: anAttributeId [
	^ (eav at: anEntityId at: anAttributeId ifAbsent: nil) isNotNil
]

{ #category : #private }
Triplestore >> load [
	| results |
	results := (db execute: 'select entity, attr, value from triple') rows.
	self initialize: results size.
	results do: [ :row |
		| triple |
		triple := self tripleForEntity: row first attribute: row second.
		triple property: #value rawValue: row third value ]
]

{ #category : #private }
Triplestore >> newTriple: aCollection [
	^ Triple for: aCollection onChange: [ :triple :newValue :oldValue |
			newValue
				ifNil: [ self delete: triple ]
				ifNotNil: [ self upsert: triple ]]
]

{ #category : #'initialize-release' }
Triplestore >> open [
	db := SQLite3Connection on: self file.
	db open; execute: self class ddl.
	self load.
]

{ #category : #lookup }
Triplestore >> tripleForEntity: anEntityId attribute: anAttributeId [
	^ eav at: anEntityId at: anAttributeId ifAbsentPut: [ self newTriple: { anEntityId. anAttributeId }  ]
]

{ #category : #lookup }
Triplestore >> triplesForEntity: anEntityId [
	^ (eav at: anEntityId) values 
]

{ #category : #private }
Triplestore >> upsert: aTriple [
	db
		execute: 'insert into triple (entity, attr, value) values (?, ?, ?) on conflict (entity, attr) do update set value = excluded.value'
		value: aTriple entity
		value: aTriple attribute
		value: aTriple value.
]

{ #category : #lookup }
Triplestore >> valueOfEntity: anEntityId attribute: anAttributeId [
	^ (self tripleForEntity: anEntityId attribute: anAttributeId) value
]
