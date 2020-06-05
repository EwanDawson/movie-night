Class {
	#name : #Wikipedia,
	#superclass : #Object,
	#category : #MovieNight
}

{ #category : #example }
Wikipedia class >> allFilmsSince: aYear [
	<script: 'self allFilmsSince: 2015'>
	^self new yearsInFilmFrom: aYear to: Date today year
]

{ #category : #constants }
Wikipedia >> baseUrl [
	^'https://en.wikipedia.org/wiki/'
]

{ #category : #'wikipedia - parsing' }
Wikipedia >> domForArticle: articleName [
	| page |
	page := (ZnEasy get: self baseUrl, articleName) entity.
	^(XMLHTMLParser on: page) parseDocument 
]

{ #category : #private }
Wikipedia >> extractFilmDetails: xml [
	| rows movieRows movieCells |
	rows := xml xpath: '//th[contains(text(),"Opening")]/ancestor::table/tbody/tr'.
	movieRows := rows select: [ :row | (row xpath: 'td') isNotEmpty ].
	movieCells := movieRows collect: [ :row | (row xpath: 'td[not(@*)]') collect: [ :cell | cell stringValue ] ].
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
