"
A TriplestoreTest is a test class for testing the behavior of Triplestore
"
Class {
	#name : #TriplestoreTest,
	#superclass : #TestCase,
	#instVars : [
		'triplestore'
	],
	#category : #'MovieNight-Tests'
}

{ #category : #accessing }
TriplestoreTest class >> resources [
	^ {TriplestoreResource}
]

{ #category : #running }
TriplestoreTest >> setUp [
	super setUp.
	triplestore := TriplestoreResource current triplestore.
	self assert: triplestore allTriples isEmpty 
]

{ #category : #running }
TriplestoreTest >> tearDown [
	super tearDown.
	triplestore removeAll
]

{ #category : #tests }
TriplestoreTest >> testAllTriples [
	| triple1 triple2 |
	self assertCollection: triplestore allTriples hasSameElements: {}.
	triple1 := triplestore forEntity: #E attribute: #A setValue: #V.
	self
		assertCollection: triplestore allTriples
		hasSameElements: {triple1}.
	triple2 := triplestore forEntity: #E attribute: #B setValue: #W.
	self
		assertCollection: triplestore allTriples
		hasSameElements:
			{triple1.
			triple2}
]

{ #category : #tests }
TriplestoreTest >> testAttributesOfEntity [
	| tripleEA |
	self
		assert: (triplestore attributesOfEntity: #E)
		equals: Dictionary empty.
	tripleEA := triplestore forEntity: #E attribute: #A setValue: #V.
	self
		assert: (triplestore attributesOfEntity: #E)
		equals: (Dictionary newFromPairs: {#A . #V}).
	triplestore forEntity: #E attribute: #B setValue: #W.
	self
		assert: (triplestore attributesOfEntity: #E)
		equals: (Dictionary newFromPairs: {#A . #V . #B . #W}).
	triplestore forEntity: #E attribute: #B setValue: #X.
	self
		assert: (triplestore attributesOfEntity: #E)
		equals: (Dictionary newFromPairs: {#A . #V . #B . #X}).
	triplestore forEntity: #F attribute: #A setValue: #V.
	self
		assert: (triplestore attributesOfEntity: #E)
		equals: (Dictionary newFromPairs: {#A . #V . #B . #X}).
	tripleEA value: #Z.
	self
		assert: (triplestore attributesOfEntity: #E)
		equals: (Dictionary newFromPairs: {#A . #Z . #B . #X})
]

{ #category : #tests }
TriplestoreTest >> testEmptyTriplestore [
	self assert: triplestore isEmpty.
	self assert: triplestore allTriples isEmpty.
]

{ #category : #tests }
TriplestoreTest >> testForEntityAttributeSetValue [
	| triple |
	triple := triplestore forEntity: #E attribute: #A setValue: #V.
	self
		assert: triple entity equals: #E;
		assert: triple attribute equals: #A;
		assert: triple value equals: #V.
	triplestore forEntity: #E attribute: #A setValue: #W.
	self assert: triple value equals: #W
]

{ #category : #tests }
TriplestoreTest >> testIsEmpty [
	self assert: triplestore isEmpty.
	triplestore forEntity: #E attribute: #A setValue: #V.
	self deny: triplestore isEmpty
]

{ #category : #tests }
TriplestoreTest >> testIsNotEmpty [
	self deny: triplestore isNotEmpty.
	triplestore forEntity: #E attribute: #A setValue: #V.
	self assert: triplestore isNotEmpty
]

{ #category : #tests }
TriplestoreTest >> testIsValueDefinedForEntityAttribute [
	self deny: (triplestore isValueDefinedForEntity: #E attribute: #A).
	self deny: (triplestore isValueDefinedForEntity: #E attribute: #B).
	self deny: (triplestore isValueDefinedForEntity: #F attribute: #A).
	triplestore forEntity: #E attribute: #A setValue: #V.
	self assert: (triplestore isValueDefinedForEntity: #E attribute: #A).
	self deny: (triplestore isValueDefinedForEntity: #E attribute: #B).
	self deny: (triplestore isValueDefinedForEntity: #F attribute: #A)
]

{ #category : #tests }
TriplestoreTest >> testRemoveAll [
	| triple1 triple2 |
	
	self
		assertEmpty: triplestore allTriples;
		shouldnt: [ triplestore removeAll ]
			raise: Error
			description: 'Sending #removeAll to an empty Triplestore should be a no-op'.
	triple1 := triplestore forEntity: #E attribute: #A setValue: #V.
	triplestore removeAll.
	
	"Triple is not known to the Triplestore anymore"
	self assert: triple1 value equals: #V.
	self
		assert: (triplestore valueOfEntity: #E attribute: #A)
		equals: nil.
	"Triple can be updated independently of Triplestore"
	triple1 value: #W.
	self
		assert: (triplestore valueOfEntity: #E attribute: #A)
		equals: nil.
		
	"If a new Triple for the same entity and attribute is added to the Triplestore, they are independent of each other"
	triple2 := triplestore forEntity: #E attribute: #A setValue: #V.
	self
		assert: triple1 value equals: #W;
		assert: triple2 value equals: #V.
	triple1 value: #X.
	self assert: triple2 value equals: #V.
	triple2 value: #Y.
	self assert: triple1 value equals: #X
]

{ #category : #tests }
TriplestoreTest >> testTripleForEntityAttribute [
	| triple |
	self assert: (triplestore tripleForEntity: #E attribute: #A) equals: nil.
	triple := triplestore forEntity: #E attribute: #A setValue: #V.
	self assert: (triplestore tripleForEntity: #E attribute: #A) equals: triple.
]

{ #category : #tests }
TriplestoreTest >> testTriplesForEntity [
	| triple1 triple2 |
	self
		assertCollection: (triplestore triplesForEntity: #E)
		hasSameElements: {}.
	triple1 := triplestore forEntity: #E attribute: #A setValue: #V.
	self
		assertCollection: (triplestore triplesForEntity: #E)
		hasSameElements: {triple1}.
	triple2 := triplestore forEntity: #E attribute: #B setValue: #W.
	self
		assertCollection: (triplestore triplesForEntity: #E)
		hasSameElements:
			{triple1.
			triple2}.
	triplestore forEntity: #F attribute: #B setValue: #W.
	self
		assertCollection: (triplestore triplesForEntity: #E)
		hasSameElements:
			{triple1.
			triple2}
]

{ #category : #tests }
TriplestoreTest >> testValueOfEntityAttribute [
  | triple |
	self assert: (triplestore valueOfEntity: #E attribute: #A) equals: nil.
	triple := triplestore forEntity: #E attribute: #A setValue: #V.
	self assert: (triplestore valueOfEntity: #E attribute: #A) equals: #V.
	triplestore forEntity: #E attribute: #A setValue: #W.
	self assert: (triplestore valueOfEntity: #E attribute: #A) equals: #W.
	triple value: #X.
	self assert: (triplestore valueOfEntity: #E attribute: #A) equals: #X.
]
