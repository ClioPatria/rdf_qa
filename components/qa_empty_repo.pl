:- module(qa_empty_repo, []).

:- use_module(qa_heuristics).
:- use_module(library(semweb/rdf_db)).
:- use_module(library(http/html_write)).


qa:rdf_warning(qa_empty_repo, R) :-
	\+ rdf_graph(_),
	rdf_equal(R, rdf:'Resource').

qa:class_label(qa_empty_repo) -->
        html(['No RDF data loaded, please load using the "Repository" menu entries.']).
