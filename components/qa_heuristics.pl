:- module(qa,
	  [ rdf_warning/2,		% ?ErrorClass, ?URI
	    rdf_qa_ok/2,		% ?ErrorClass, ?URI
	    class_label//1		% +ErrorClass
	  ]).

/** <module> RDF QA hooks

This module declares the _hooks_ an application  may define to extend or
modify some of ClioPatria's RDF QA behaviour. Hooks are =multifile=
defined predicates that may have no default definition.
*/

:- multifile
	rdf_warning/2,
	rdf_qa_ok/2,
	class_label//1.


:- rdf_meta
	rdf_warning(o,r).

%%	rdf_warning(?ErrorClass, ?URI) is nondet.
%
%	True if URI contains an error in class ErrorClass.
%	Note: qa:rdf_warning is multifile so you can define your own
%	error classes. If you do, you also need to add class_label//1
%	for your new class.

%%	rdf_qa_ok(?ErrorClass, ?URI) is nondet.
%
%	True if URI should never be reported as being in class
%	ErrorClass. This multifile predicate allows you to suppress
%	warnings for certain URIs, for example for URIs that are known
%	to contain errors that you cannot fix.

%%	class_label(+ErrorClass)// is det.
%
%	Writes the error message associated with ErrorClass to HTML.

