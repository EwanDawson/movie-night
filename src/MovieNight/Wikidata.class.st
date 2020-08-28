"
I am a client for Wikidata.

I use an instance on ZnClient to communicate with query.wikidata.org.
"
Class {
	#name : #Wikidata,
	#superclass : #Object,
	#instVars : [
		'client'
	],
	#category : #MovieNight
}

{ #category : #private }
Wikidata class >> baseUrl [
	^ 'https://query.wikidata.org/sparql'
]

{ #category : #accessing }
Wikidata >> client [
	^ client
]

{ #category : #accessing }
Wikidata >> client: anObject [
	client := anObject
]

{ #category : #initialization }
Wikidata >> initialize [
	client := ZnClient new
		systemPolicy;
		accept: 'application/sparql-results+xml;charset=utf-8' asZnMimeType;
		url: self class baseUrl;
		contentReader: [ :entity | (XMLDOMParser on: entity) parseDocument ]
]

{ #category : #accessing }
Wikidata >> query: aSparqlQuery [
	"Send the query to wikidata and answer the XML response"

	client queryAt: #query put: aSparqlQuery.
	^ client get
]
