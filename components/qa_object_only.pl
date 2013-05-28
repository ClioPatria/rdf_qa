:- module(qa_object_only, []).

:- use_module(qa_heuristics).
:- use_module(library(semweb/rdf_db)).
:- use_module(library(http/html_write)).


qa:rdf_warning(object_only, rdf(S,P,O)) :-
        rdf(S, P, O),
	\+ O = literal(_),
        \+ rdf_subject(O).
qa:class_label(object_only) -->
        html(['Triples with ', i('Object that is never a Subject')]).
