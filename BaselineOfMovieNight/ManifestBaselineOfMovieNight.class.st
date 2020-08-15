"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestBaselineOfMovieNight,
	#superclass : #PackageManifest,
	#category : #'BaselineOfMovieNight-Manifest'
}

{ #category : #'code-critics' }
ManifestBaselineOfMovieNight class >> ruleRBUtilityMethodsRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#BaselineOfMovieNight #baseline: #false)) #'2020-08-15T10:44:32.540846+01:00') )
]
