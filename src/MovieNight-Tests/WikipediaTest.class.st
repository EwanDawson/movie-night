"
A WikipediaTest is a test class for testing the behavior of Wikipedia
"
Class {
	#name : #WikipediaTest,
	#superclass : #TestCase,
	#instVars : [
		'wiki'
	],
	#category : #'MovieNight-Tests'
}

{ #category : #running }
WikipediaTest >> setUp [
	super setUp.
	wiki := Wikipedia new
]

{ #category : #test }
WikipediaTest >> testYearInFilm [
	"Taken from https://en.wikipedia.org/wiki/1990_in_film"
  | year1990 downtown |
	year1990 := wiki yearInFilm: 1990.
	self assert: year1990 size equals: 196.

	downtown := year1990 first.
	self assert: (downtown at: #title) equals: 'Downtown'.
	self assert: (downtown at: #studio) equals: '20th Century Fox'.
	self assert: (downtown at: #cast_crew) equals: 'Richard Benjamin (director); Nat Mauldin (screenplay); Anthony Edwards, Forest Whitaker, Penelope Ann Miller, Joe Pantoliano, David Clennon, Art Evans, Rick Aiello, Roger Aaron Brown, Ron Canada, Wanda De Jesus, Francis X. McCarthy, Kimberly Scott, Danuel Pipoly, Vinnie Curto'.
	self assert: (downtown at: #genres) equals: 'Action, Comedy'.
	self assert: (downtown at: #medium) equals: 'Live action'.
	self assert: (downtown at: #year) equals: 1990.

]

{ #category : #tests }
WikipediaTest >> testYearsInFilmFromTo [
	self assert: (wiki yearsInFilmFrom: 1990 to: 1990) size equals: 196.
]
