Class {
	#name : #IMDBAPI,
	#superclass : #Object,
	#category : #MovieNight
}

{ #category : #configuring }
IMDBAPI class >> apiKey [
	^ 'imdb-api.key' asFileReference contents
]

{ #category : #constants }
IMDBAPI class >> baseUrl [
	^'https://imdb-api.com/en/API/Top250Movies/'.
]

{ #category : #fetching }
IMDBAPI class >> top250Movies [
	| json |
	json := (ZnEasy get: (self baseUrl), 'Top250Movies', (self apiKey)) contents.
	^ (STON fromString: json) at: 'items'
]
