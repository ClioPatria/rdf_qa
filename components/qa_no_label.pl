:- module(qa_no_label, []).

:- use_module(qa_heuristics).
:- use_module(library(semweb/rdf_db)).
:- use_module(library(semweb/rdf_label)).
:- use_module(library(http/html_write)).


qa:rdf_warning(no_label, URI) :-
	rdf_subject(URI),
	\+ rdf_is_bnode(URI),
	\+ rdf_label(URI, _),
	\+ qa:rdf_qa_ok(no_label, URI).

qa:class_label(no_label) -->
        html(['URIs without label']).

qa:rdf_qa_ok(no_label, URI) :-
	sub_atom(URI, 0, _, _, 'http://www.w3.org/2001/XMLSchema#').
