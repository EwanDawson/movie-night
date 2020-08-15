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
	<baseline>
	spec
		for: #common
		do: [ "Dependencies"
			self xmlParser: spec.
			self sqlite3: spec.

			"Packages"
			spec
				package: 'MovieNight'
                    with: [ spec requires: #('SQLite3' 'XMLParser') ];
				package: 'MovieNight-Tests'
					with: [ spec requires: #('MovieNight') ] ]
]

{ #category : #accessing }
BaselineOfMovieNight >> projectClass [
	^ MetacelloCypressBaselineProject
]

{ #category : #baselines }
BaselineOfMovieNight >> sqlite3: spec [
	spec baseline: 'SQLite3' with: [ spec repository: 'github://pharo-rdbms/Pharo-SQLite3/src' ]
]

{ #category : #baselines }
BaselineOfMovieNight >> xmlParser: spec [
	spec
		baseline: 'XMLParser'
		with: [ spec repository: 'github://pharo-contributions/XML-XMLParser/src' ]
]
