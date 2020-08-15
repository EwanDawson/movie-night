"
I am a Baseline for loading MovieNight using Montecello. See my superclass for instructions on how to use me.
"
Class {
	#name : #BaselineOfMovieNight,
	#superclass : #BaselineOf,
	#category : #BaselineOfMovieNight
}

{ #category : #baselines }
BaselineOfMovieNight >> baseline: spec [
	spec for: #common do: [ spec package: 'MovieNight' ]
]
