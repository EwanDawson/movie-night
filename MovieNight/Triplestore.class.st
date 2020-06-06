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

{ #category : #testing }
Triplestore >> includesEntity: anEntityId attribute: anAttributeId [
	^ (eav at: anEntityId at: anAttributeId ifAbsent: nil) isNotNil
]

{ #category : #private }
Triplestore >> index: aTriple [
	eav at: aTriple entity at: aTriple attribute put: aTriple.
]

{ #category : #initialization }
Triplestore >> initialize [
	eav := Dictionary new
]

{ #category : #private }
Triplestore >> load [
	| size triples |
	size := (db execute: 'select count(*) from triple') onlyValue asInteger.
	triples := (db execute: 'select entity, attr, value from triple') rows
		collect: [ :row | self newTriple: row ]
		into: (OrderedCollection new: size).
	eav removeAll.
	triples do: [ :triple | self index: triple ]
]

{ #category : #private }
Triplestore >> newTriple: aCollection [
	^ Triple for: aCollection onChange: [ :t :new :old |
		(self includesEntity: t entity attribute: t attrbute)
			ifTrue: [ self upsert: t ]
			ifFalse: [ self error: 'This triple has been deleted' ]]
]

{ #category : #'initialize-release' }
Triplestore >> open [
	db := SQLite3Connection on: self file.
	db open; execute: self class ddl.
	self load.
]

{ #category : #removing }
Triplestore >> removeEntity: anEnityId attribute: anAttributeId [
	| triple |
	(self includesEntity: anEnityId attribute: anAttributeId)
		ifFalse: [ ^ self ].
	triple := self tripleForEntity: anEnityId attribute: anAttributeId.
	self delete: triple.
	self unindex: triple
]

{ #category : #adding }
Triplestore >> storeEntity: anEntityId attribute: anAttributeId value: anObject [
	(self includesEntity: anEntityId attribute: anAttributeId)
		ifTrue: [ ^ (self tripleForEntity: anEntityId attribute: anAttributeId) value: anObject ]
		ifFalse: [
			| triple |
			triple := self newTriple: { anEntityId . anAttributeId . anObject }.
			self upsert: triple.
			self index: triple.
			^ triple ]
]

{ #category : #lookup }
Triplestore >> tripleForEntity: anEntityId attribute: anAttributeId [
	^ eav at: anEntityId at: anAttributeId
]

{ #category : #lookup }
Triplestore >> triplesForEntity: anEntityId [
	^ (eav at: anEntityId) values 
]

{ #category : #private }
Triplestore >> unindex: aTriple [
	(eav at: aTriple entity) removeKey: aTriple attribute.
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
