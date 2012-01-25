:- module(qa_heuristics, [
			  qa:rdf_warning/2,  % +Class, -URI
			  qa:class_label//1 % +Class
			 ]).

:- multifile
	qa:rdf_warning/2,
	qa:class_label//1.

:- rdf_meta
	qa:rdf_warning(o,r).

