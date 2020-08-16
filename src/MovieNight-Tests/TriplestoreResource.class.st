"
I am a TestResource that sets up, proves, and tears down a Triplestore instance
for use in testing.
"
Class {
	#name : #TriplestoreResource,
	#superclass : #TestResource,
	#instVars : [
		'triplestore'
	],
	#category : #'MovieNight-Tests'
}

{ #category : #'as yet unclassified' }
TriplestoreResource class >> triplestoreFile [
	"Answer a unique FileReference in a location on the filesystem suitable for temporary files"
	^ FileReference newTempFilePrefix: self name suffix: '.sqlite'
]

{ #category : #running }
TriplestoreResource >> setUp [
	super setUp.
	triplestore := Triplestore open: self class triplestoreFile
]

{ #category : #running }
TriplestoreResource >> tearDown [
	super tearDown.
	[ triplestore close.
	triplestore file delete ]
		ifError: [ "Ignore any errors when tearing down this resource" ]
]

{ #category : #accessing }
TriplestoreResource >> triplestore [
	^ triplestore
]
