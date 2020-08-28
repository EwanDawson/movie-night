"
A WikidataTest is a test class for testing the behavior of Wikidata
"
Class {
	#name : #WikidataTest,
	#superclass : #TestCase,
	#category : #'MovieNight-Tests'
}

{ #category : #test }
WikidataTest >> testInitialize [
	| client |
	client := Wikidata new client.
	self assert: client request url equals: Wikidata baseUrl asZnUrl.
]
