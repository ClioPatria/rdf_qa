:- module(qa, [
	       rdf_warning/2,
	       rdf_qa_ok/2,
	       class_label//1
	      ]).


:- multifile
	rdf_warning/2,
	rdf_qa_ok/2,
	class_label//1.


:- rdf_meta
	rdf_warning(o,r).

