Class {
	#name : #MovieBase,
	#superclass : #Object,
	#instVars : [
		'location',
		'db',
		'movies'
	],
	#classInstVars : [
		'aFileName',
		'location'
	],
	#category : #MovieNight
}

{ #category : #accessing }
MovieBase class >> convertFrom: moviebaseFilename toTriplestore: triplestoreFilename [
  <script:  'self convertFrom: ''movies.db'' toTriplestore: ''triplestore.db'''>
	| moviebase triples attrs |
	triples := SQLite3Connection on: 'triplestore.db'.
	triples open; beginTransaction.
	moviebase := self new location: 'movies.db'; open; refresh; yourself.
	attrs :=  { #title. #studio. #castAndCrew. #genres. #medium. #year. #seen. #rewatchable }.
	moviebase movies associationsDo: [ :movie |
		| id data |
		id := 'moviebase:', movie key asString.
		data := movie value.
		attrs do: [ :attr |
			| attrName attrValue |
			attrValue := data perform: attr.
			attrValue ifNotNil: [
			attrName := attr asString.
			triples execute: 'insert into triples values (?, ?, ?)' with: { id. attrName. attrValue asString trim }
		]].
	].
	triples commitTransaction.
	moviebase close.
	triples close.

]

{ #category : #constants }
MovieBase class >> databasePrepDDL [
^ '
  create table if not exists movie (
    id integer primary key,
    title text,
    studio text,
    cast_crew text,
    genres text,
    medium text,
    year integer,
    seen integer default 0 not null,
    rewatchable integer default 0 not null
  );'
]

{ #category : #conversion }
MovieBase class >> rowAsMovie: aMovieTableRow [
	| dict |
	dict := aMovieTableRow asDictionary.
	dict at: 'castAndCrew' put: (dict removeKey: 'cast_crew').
	dict at: 'seen' put: ((dict at: 'seen') = 1).
	dict at: 'rewatchable' put: ((dict at: 'rewatchable') = 1).
	^ Movie for: dict

]

{ #category : #command }
MovieBase >> add: aMovie [
  | id movie |
	db execute: 'insert into movie (title, studio, cast_crew, genres, medium, year) values (? , ?, ?, ?, ?, ?)'
		 with: (#(title studio cast_crew genres medium year) collect: [ :k | aMovie at: k]).
	id := (db execute: 'select last_insert_rowid()') onlyValue.
	movie := Movie for: aMovie.
	self manage: movie withId: id.
	^ movie.
]

{ #category : #'initialize-release' }
MovieBase >> close [
	db ifNotNil: [ db close ]
]

{ #category : #query }
MovieBase >> findWithTitle: aString releasedIn: aYear [
	^ self movies detect: [ :movie | movie title = aString and: [ movie year = aYear ] ]
]

{ #category : #initialization }
MovieBase >> initialize [ 
	movies := OrderedDictionary new.
]

{ #category : #testing }
MovieBase >> isManaged: aMovieId [
	^ movies includesKey: aMovieId
]

{ #category : #accessing }
MovieBase >> location [
	^ location copy
]

{ #category : #accessing }
MovieBase >> location: aFileName [ 
	location := aFileName copy
]

{ #category : #private }
MovieBase >> manage: aMovie withId: anInteger [
	movies at: anInteger put: aMovie.
	aMovie property: #seen whenChangedDo: [ self save: anInteger ].
	aMovie property: #rewatchable whenChangedDo: [ self save: anInteger ].
]

{ #category : #private }
MovieBase >> manageOrRefresh: aMovie withId: aMovieId [
	(self isManaged: aMovieId)
		ifTrue: [
			| managed |
			managed := self managed: aMovieId.
			managed property: #seen rawValue: aMovie seen.
			managed property: #rewatchable rawValue: aMovie rewatchable ]
		ifFalse: [ 
			self manage: aMovie withId: aMovieId ]
]

{ #category : #private }
MovieBase >> managed: aMovieId [
	^ movies at: aMovieId 
]

{ #category : #accessing }
MovieBase >> movies [
	^ movies
]

{ #category : #'initialize-release' }
MovieBase >> open [
	db := SQLite3Connection on: location.
	db open; execute: self class databasePrepDDL.
]

{ #category : #query }
MovieBase >> refresh [
	(db execute: 'select * from movie') rows do: [ :row |
			| movie |
			movie := self class rowAsMovie: row.
			self manageOrRefresh: movie withId: (row at: 'id')].
]

{ #category : #private }
MovieBase >> save: aMovieId [
	(movies at: aMovieId) ifNotNil: [ :movie |
		db execute: 'update movie set (seen, rewatchable) = (?, ?) where id = ?'
		   value: movie seen
		   value: movie rewatchable
		   value: aMovieId]
]
