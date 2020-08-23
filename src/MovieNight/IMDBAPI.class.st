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
	^ Key ifNil: [ Key := AuthInfo default machine: 'imdb-api.key'; password ]
]

{ #category : #private }
IMDBAPI >> baseUrl [
	^'https://imdb-api.com/en/API'.
]

{ #category : #'imdb api' }
IMDBAPI >> detailsFor: anImdbId [
	^ self querySearchType: #Title with: anImdbId with: #Ratings
]

{ #category : #'imdb api' }
IMDBAPI >> findTitle: aTitle year: aYear [
	| expression json |
	expression := Character space join: { aTitle asString. aYear asString }.
	json := self querySearchType: #SearchMovie with: expression.
	^ (json at: #results) first
]

{ #category : #querying }
IMDBAPI >> querySearchType: aSearchType [
	^ self querySearchType: aSearchType with: nil
]

{ #category : #querying }
IMDBAPI >> querySearchType: aSearchType with: anExpresssion [
	| url json |
	url := self queryUrlForType: aSearchType with: anExpresssion.
	json := (ZnEasy get: url) contents.
	^ STON fromString: json
]

{ #category : #querying }
IMDBAPI >> querySearchType: aSearchType with: anExpression with: options [
  | postfix |
	postfix := $/ join: { anExpression value. $, join: options }.
	^ self querySearchType: aSearchType with: postfix 
]

{ #category : #private }
IMDBAPI >> queryUrlForType: type with: postfix [
  ^ $/ join: ({ self baseUrl. type. self apiKey. postfix } select: #isNotNil )	
]

{ #category : #'imdb api' }
IMDBAPI >> ratingForTitle: aTitle year: aYear [
	| title details |
	title := self findTitle: aTitle year: aYear.
	details := self detailsFor: (title at: #id).
	^ (details at: #imDbRating) asNumber
]

{ #category : #'imdb api' }
IMDBAPI >> top250Movies [
	| json |
	json := self querySearchType: #Top250Movies.
	^ json at: #items
]
