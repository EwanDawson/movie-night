"
I an an interface to the IMDB API at 'https://imdb-api.com/'
"
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
	^ Key ifNil: [ Key := AuthInfo default machine: 'imdb-api.com'; password ]
]

{ #category : #private }
IMDBAPI >> baseUrl [
	^'https://imdb-api.com/en/API'.
]

{ #category : #querying }
IMDBAPI >> query: aSearchType [
	^ self query: aSearchType params: nil
]

{ #category : #querying }
IMDBAPI >> query: anAPI params: aCollection [
	| url json |
	url := self queryUrlForApi: anAPI path: aCollection.
	json := (ZnEasy get: url) contents.
	^ STON fromString: json
]

{ #category : #private }
IMDBAPI >> queryUrlForApi: type path: pathSegments [
	^ (ZnUrl fromString: self baseUrl)
		addPathSegment: type;
		addPathSegment: self apiKey;
		addPathSegments: (pathSegments ifNil: #())
]

{ #category : #'imdb api' }
IMDBAPI >> ratingForTitle: aTitle year: aYear [
	| title details |
	title := (self searchMovie: (Character space join: { aTitle. aYear })) first.
	details := self title: (title at: #id).
	^ (details at: #imDbRating) asNumber
]

{ #category : #'imdb api' }
IMDBAPI >> ratings: anImdbId [
	"See 'https://imdb-api.com/api/#Ratings-body'"
	
	^ self query: #Ratings params: { anImdbId }
]

{ #category : #'imdb api' }
IMDBAPI >> searchMovie: query [
	"Invoke the 'SearchMovie' API with the given query"

	| json |
	json := self query: #SearchMovie params: { query }.
	^ json at: #results
]

{ #category : #'imdb api' }
IMDBAPI >> title: anImdbId [
	| options |
	options := $, join: #( FullActor FullCast Posters Images Trailer Ratings Wikipedia ).
	^ self query: #Title params: { anImdbId . options }
]

{ #category : #'imdb api' }
IMDBAPI >> top250Movies [
	| json |
	json := self query: #Top250Movies.
	^ json at: #items
]
