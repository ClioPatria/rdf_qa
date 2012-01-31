:- module(cycle_prop, []).

:- use_module(qa_heuristics).
:- use_module(library(semweb/rdf_db)).
:- use_module(library(http/html_write)).


qa:rdf_warning(cycle_property, rdf(S,P,S)) :-
        rdf(S, P, S),
        \+ (  rdf_equal(P, rdf:type),
              rdf_equal(S, rdfs:'Class')
	   ).
qa:class_label(cycle_property) -->
        html(['Triples with ', i('Subject == Object')]).
