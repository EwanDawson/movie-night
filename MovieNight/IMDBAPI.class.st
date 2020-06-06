Class {
	#name : #IMDBAPI,
	#superclass : #Object,
	#classVars : [
		'Key'
	],
	#category : #MovieNight
}

{ #category : #private }
IMDBAPI >> apiKey [
	^ Key ifNil: [ Key := 'imdb-api.key' asFileReference contents ]
]

{ #category : #private }
IMDBAPI >> baseUrl [
	^'https://imdb-api.com/en/API/'.
]

{ #category : #querying }
IMDBAPI >> top250Movies [
	| json |
	json := (ZnEasy get: (self baseUrl), 'Top250Movies', (self apiKey)) contents.
	^ (STON fromString: json) at: 'items'
]
