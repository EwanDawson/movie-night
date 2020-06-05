Class {
	#name : #Movies,
	#superclass : #Object,
	#instVars : [
		'items'
	],
	#category : #MovieNight
}

{ #category : #initializing }
Movies class >> forAllIMDB: aJSONArray [
	^self new movies: (aJSONArray collect: [ :item | Movie for: item ])
]

{ #category : #script }
Movies class >> top250ToHTML: aString [
  <script: 'self top250ToHTML: ''movies.html'''>
  | top250 movies file |
  top250 := IMDBAPI top250Movies.
	movies := self forAllIMDB: top250.
	file := FileLocator home resolveString: aString.
	file
		writeStreamEncoded: 'UTF-8'
		do: [ :stream | movies writeHTML: stream ]
]

{ #category : #converting }
Movies >> asHTMLString [
  | stream |
	stream := String new writeStream.
  self writeHTML: stream.
  ^ stream contents
]

{ #category : #accessing }
Movies >> movies: aCollection [ 
	items := aCollection
]

{ #category : #writing }
Movies >> writeHTML: aCharacterWriteStream [ 
  | html |
	html := ZnHtmlOutputStream on: aCharacterWriteStream.
	html html5; tag: #html do: [ html
		  tag: #head do: [ html
			  tag: #title with: 'Movies';
				tag: #link attributes: { 'rel' . 'stylesheet' . 'type' . 'text/css' . 'href' . 'https://cdn.datatables.net/1.10.21/css/jquery.dataTables.css' };
				tag: #script attributes: { 'type' . 'text/javascript' . 'charset' . 'utf8' . 'src' . 'https://code.jquery.com/jquery-3.5.1.min.js' } with: '';
				tag: #script attributes: { 'type' . 'text/javascript' . 'charset' . 'utf8' . 'src' . 'https://cdn.datatables.net/1.10.21/js/jquery.dataTables.js' } with: ''];
			 tag: #body do: [ html
				  tag: #h1 with: 'Movies';
				  tag: #table attributes: { 'id' . 'movies' . 'class' . 'display' } do: [ html
				    tag: #thead do: [ html
					    tag: #tr do: [ 
						    { 'Rank' . 'Title' . 'Year' . 'Image' . 'Rating' } do: [ :prop | html tag: #th with: prop ]
				      ]
				    ];
			      tag: #tbody do: [ 
				      items do: [ :item | html tag: #tr do: [ html
						    tag: #td with: item rank;
						    tag: #td with: item title;
						    tag: #td with: item year;
						    tag: #td do: [ html tag: #img attributes: { 'src' . item image . 'height' . 100 } ];
						    tag: #td with: item imdbRating
					    ]]
				    ]
			    ];
		      tag: #script with: '$(document).ready(function() { $(''#movies'').DataTable(); } );'
				]
		  ]
]
