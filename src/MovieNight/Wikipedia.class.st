"
I am an interface to Wikipedia.

I can extract structured data about certain topics from some Wikipedia articles. I make certain assumptions about the structure of the articles I access - if the structure changes, I may break.

I provide data as simple collections and dictionaries.

My public API is organised into protocols based on topic.

My most basic operation is to retrieve the HTML DOM for an article:

```
Wikipedia new domForArticle: 'Smalltalk'
```
"
Class {
	#name : #Wikipedia,
	#superclass : #Object,
	#instVars : [
		'client',
		'cache'
	],
	#classInstVars : [
		'default'
	],
	#category : #MovieNight
}

{ #category : #example }
Wikipedia class >> allFilmsSince: aYear [
	<script: 'self allFilmsSince: 2015'>
	^self new yearsInFilmFrom: aYear to: Date today year
]

{ #category : #constants }
Wikipedia class >> baseUrl [
	^'https://en.wikipedia.org/wiki/'
]

{ #category : #caching }
Wikipedia class >> pageCache [
	^ TTLCache new
		timeToLive: 1 day;
		maximumWeight: 100;
		yourself
]

{ #category : #'wikipedia - parsing' }
Wikipedia >> domForArticle: articleName [
	| page |
	page := (ZnEasy get: self class baseUrl, articleName) entity.
	^(XMLHTMLParser on: page) parseDocument
]

{ #category : #private }
Wikipedia >> extractFilmDetails: xml [
	| rows movieRows movieCells |
	rows := xml xpath: '//th[contains(text(),"Opening")]/ancestor::table/tbody/tr'.
	movieRows := rows select: [ :row | (row xpath: 'td') isNotEmpty ].
	movieCells := movieRows collect: [ :row | (row xpath: 'td[not(@*)]') collect: [ :cell | cell stringValue trim] ].
	^ movieCells
			collect: [ :row | {
				'title' -> (row at: 1).
				'studio' -> (row at: 2).
				'cast_crew' -> (row at: 3).
				'genres' -> (row at: 4).
				'medium' -> (row at: 5).
				} asOrderedDictionary ]
			thenReject: [ :movie | (movie at: 'title') isNil ]
]

{ #category : #'wikipedia - film' }
Wikipedia >> yearInFilm: anInteger [
  | article |
	article := self domForArticle: anInteger asString, '_in_film'.
	^ (self extractFilmDetails: article) collect: [ :film | film at: 'year' put: anInteger. film ]
]

{ #category : #'wikipedia - film' }
Wikipedia >> yearsInFilmFrom: from to: to [
	^(from to: to) flatCollect: [ :year | self yearInFilm: year ]
]
