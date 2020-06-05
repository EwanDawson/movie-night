Class {
	#name : #Movie,
	#superclass : #Object,
	#traits : 'TObservable',
	#classTraits : 'TObservable classTrait',
	#instVars : [
		'#year',
		'#title',
		'#rank',
		'#imdbRating',
		'#imageUrl',
		'#castAndCrew',
		'#studio',
		'#medium',
		'#genres',
		'#seen => ObservableSlot',
		'#rewatchable => ObservableSlot'
	],
	#category : #MovieNight
}

{ #category : #'instance creation' }
Movie class >> for: aDictionary [
	^ self new initialize: aDictionary; yourself.	
]

{ #category : #accessing }
Movie >> castAndCrew [
	^ castAndCrew copy
]

{ #category : #accessing }
Movie >> genres [
	^ genres copy
]

{ #category : #accessing }
Movie >> imageUrl [
	^ imageUrl copy 
]

{ #category : #accessing }
Movie >> imdbRating [
	^ imdbRating
]

{ #category : #initialization }
Movie >> initialize [
	
	self class initializeSlots: self.
	super initialize.
]

{ #category : #initialization }
Movie >> initialize: aDictionary [
	title := (aDictionary at: 'title').
	castAndCrew := (aDictionary at: 'castAndCrew').
	studio := (aDictionary at: 'studio').
	medium := (aDictionary at: 'medium').
	genres := (aDictionary at: 'genres').
	year := (aDictionary at: 'year').
	seen := (aDictionary at: 'seen').
	rewatchable := (aDictionary at: 'rewatchable').

]

{ #category : #accessing }
Movie >> medium [
	^ medium copy 
]

{ #category : #accessing }
Movie >> rank [
	^ rank
]

{ #category : #accessing }
Movie >> rewatchable [
	^ rewatchable
]

{ #category : #accessing }
Movie >> rewatchable: aBoolean [
	rewatchable := aBoolean.
	rewatchable ifTrue: [ seen := true ]
]

{ #category : #accessing }
Movie >> seen [
	^ seen
]

{ #category : #accessing }
Movie >> seen: aBoolean [
	seen := aBoolean.
	seen ifFalse: [ rewatchable := false ]
]

{ #category : #accessing }
Movie >> studio [
	^ studio copy
]

{ #category : #accessing }
Movie >> title [
	^ title copy
]

{ #category : #accessing }
Movie >> year [
	^ year
]
