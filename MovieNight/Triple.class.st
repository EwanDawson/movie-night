"
I represent an Entity-Attribute-Value (EAV) triple.

My entity, attribute and value properties are arbitrary values, although normal I expect my
entity and attribute properties to by symbols.

My entity and attribute properties must not be nil, and cannot be updated once set.

My value property is observable (I use the TObservable trait to implement observability of this property).
Users can specify a block to be invoked when my value property changes. The block will be called with
three arguments: myself, the new value of my value property, and the old value of my value property.
The block will only be called if the old and new values are not equal.

To construct instances of me, use one of my class methods in the ""instance creation"" protocol. For example:

	triple := Triple
		entity: #entity123
		attribute: #name
		value: 'my entity'
		onChange: [ :triple :newValue :oldValue |
			| message |
			message := String streamContents: [ :s |
				s << triple entity << $/ << triple attribute << ': ' << oldValue << ' <- ' << newValue ].
			Transcript show: message; cr].
		
	triple value: 'your entity'
	
Will result in the following Transcript output:

  ""entity123/name: my entity -> your entity""
"
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
