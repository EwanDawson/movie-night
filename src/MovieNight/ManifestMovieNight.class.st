"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestMovieNight,
	#superclass : #PackageManifest,
	#category : #'MovieNight-Manifest'
}

{ #category : #'code-critics' }
ManifestMovieNight class >> ruleRBNotEliminationRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#Triplestore #isNotEmpty #false)) #'2020-08-16T12:33:25.489929+01:00') )
]
