:- module(qa_domain_whitelist, []).

:- use_module(qa_heuristics).

%%	rdf_qa_ok(?ErrorClass, ?URI) is nondet.
%
%	True if URI should never be reported as being in class
%	ErrorClass. This multifile predicate allows you to suppress
%	warnings for certain URIs, for example for URIs that are known
%	to contain errors that you cannot fix.


qa:rdf_qa_ok(object_only, URI) :-
	rdf_global_id(NS:'', URI),
	member(NS, [rdf,rdfs]).
qa:rdf_qa_ok(object_only, URI) :-
	rdf_global_id(NS:_, URI),
	member(NS, [xsd]).
