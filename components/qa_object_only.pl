:- module(qa_object_only, []).

:- use_module(qa_heuristics).
:- use_module(library(semweb/rdf_db)).
:- use_module(library(http/html_write)).


qa:rdf_warning(object_only, rdf(S,P,O)) :-
        rdf(S, P, O),
	\+ rdf_equal(rdfs:isDefinedBy, P),
	\+ rdf_equal(rdfs:seeAlso, P),
	\+ O = literal(_),
        \+ rdf_subject(O),
	\+ qa:rdf_qa_ok(object_only, O).
qa:class_label(object_only) -->
        html(['Triples with ', i('Object that is never a Subject')]).
