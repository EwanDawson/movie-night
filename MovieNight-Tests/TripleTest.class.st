"
A TripleTest is a test class for testing the behavior of Triple
"
Class {
	#name : #TripleTest,
	#superclass : #TestCase,
	#category : #'MovieNight-Tests'
}

{ #category : #tests }
TripleTest >> testAttribute [
	| triple |
	triple := Triple entity: #E attribute: #A1 value: #V.
	self assert: triple attribute equals: #A1.
	self should: [ triple attribute: #A2 ] raise: Error
]

{ #category : #tests }
TripleTest >> testEntity [
	| triple |
	triple := Triple entity: #E1 attribute: #A value: #V.
	self assert: triple entity equals: #E1.
	self should: [ triple entity: #E2 ] raise: Error
]

{ #category : #tests }
TripleTest >> testNil [
	self
		should: [ Triple entity: nil attribute: #A value: #V ]
		raise: Error.
	self
		should: [ Triple entity: #E attribute: nil value: #V ]
		raise: Error.
	Triple entity: #E attribute: #A value: nil
]

{ #category : #tests }
TripleTest >> testValue [
	| triple change |
	change := Dictionary new.
	triple := Triple entity: #E attribute: #A value: 123 onChange: [ :t :new :old |
		self assert: t entity equals: #E.
		self assert: t attribute equals: #A.
		self assert: t value equals: new.
		change at: #new put: new; at: #old put: old].
	self assert: triple value equals: 123.
	triple value: 456.
	self assert: (change at: #old) equals: 123.
	self assert: (change at: #new) equals: 456.
	self assert: triple value equals: 456.
]

{ #category : #tests }
TripleTest >> testValueChangeBlockNotInvokedWhenNewValueEqualsOldValue [
	| triple |
	triple := Triple
		entity: #E
		attribute: #A
		value: 123
		onChange: [ :t :new :old | self error: 'Value is unchanged' ].
	triple value: 123
]
