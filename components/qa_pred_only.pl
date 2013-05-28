:- module(qa_predicate, []).

:- use_module(qa_heuristics).
:- use_module(library(semweb/rdf_db)).
:- use_module(library(http/html_write)).


qa:rdf_warning(pred_only, rdf(S,P,O)) :-
	rdf_current_predicate(P),
        \+ rdf_subject(P),
	\+ qa:rdf_qa_ok(pred_only, P),
	rdf(S,P,O).
qa:class_label(pred_only) -->
        html(['Triples with ', i('Predicate that is never a Subject')]).
