Class {
	#name : #Triple,
	#superclass : #Object,
	#traits : 'TObservable',
	#classTraits : 'TObservable classTrait',
	#instVars : [
		'#entity',
		'#attribute',
		'#value => ObservableSlot'
	],
	#category : #MovieNight
}

{ #category : #'instance creation' }
Triple class >> entity: anEntityId attribute: anAttributeId value: aValue [
	^ self entity: anEntityId attribute: anAttributeId value: aValue onChange: nil
]

{ #category : #'instance creation' }
Triple class >> entity: anEntityId attribute: anAttributeId value: aValue onChange: aBlock [
	"
	onChange block will be evaluated when the value is changed. The new value and old value are
	passed to the block (using cull:value:). An example onChange block:
	
	[ :triple :new :old | Transcript show: triple enity; cr; show: old; show: ' -> '; show: new; cr ]
	"
	| triple |
	triple := self new
		entity: anEntityId;
		attribute: anAttributeId;
		value: aValue;
		yourself.
	triple property: #value whenChangedDo: [ :new :old | aBlock value: triple value: new value: old ].
	^ triple
]

{ #category : #'instance creation' }
Triple class >> for: aCollection [
	^ self for: aCollection onChange: nil
]

{ #category : #'instance creation' }
Triple class >> for: aCollection onChange: aBlock [
	^ self entity: (aCollection at: 1) attribute: (aCollection at: 2) value: (aCollection at: 3) onChange: aBlock
]

{ #category : #accessing }
Triple >> attribute [
	^ attribute copy
]

{ #category : #accessing }
Triple >> attribute: anObject [
	attribute
		ifNil: [
			attribute := anObject
				ifNotNil: #value
				ifNil: [ self error: 'Attribute may not be nil' ] ]
		ifNotNil: [ self error: 'Attribute already set' ]
	
]

{ #category : #accessing }
Triple >> entity [
	^ entity
]

{ #category : #accessing }
Triple >> entity: anObject [
	entity
		ifNil: [
			entity := anObject
				ifNotNil: #value
				ifNil: [ self error: 'Entity may not be nil' ] ]
		ifNotNil: [ self error: 'Entity already set' ]
]

{ #category : #initialization }
Triple >> initialize [
	
	self class initializeSlots: self.
	super initialize.
]

{ #category : #accessing }
Triple >> value [
	^ value
]

{ #category : #accessing }
Triple >> value: anObject [
	value = anObject ifTrue: [ ^ self ].
	value := anObject ifNotNil: #value
]
