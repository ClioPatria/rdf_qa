:- module(rdf_qa,
	  [
	  ]).


:- use_module(library(semweb/rdf_db)).
:- use_module(library(semweb/rdfs)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/html_write)).
:- use_module(library('http/html_head')).
:- use_module(library(url)).
:- use_module(library(apply)).
:- use_module(library(option)).
:- use_module(library(settings)).

:- use_module(library(count)).
:- use_module(components(label)).
:- use_module(components(qa_default_heuristics)).

:- http_handler(cliopatria('qa_index'), rdf_qa_index, [content_type(text/html)]).
:- http_handler(cliopatria('qa'),	rdf_qa,	   [content_type(text/html)]).

rdf_qa_index(_Request) :-
	findall(Class, clause(qa:rdf_warning(Class, _), _), Classes),
	reply_html_page(cliopatria(main),
			title('Generate RDF quality reports'),
			body(\qa_index(Classes))
		       ).

%%	rdf_qa(Request)
%
%	Display quality issues with the loaded RDF.

rdf_qa(Request) :-
	http_parameters(Request,
			[ max_per_ns(Max0, [integer, default(20)]),
			  class(Class, [optional(true)]),
			  ns(NS, [optional(true)]),
			  show(Show, [oneof([local_view,uri]),
				      default(local_view)])
			]),
	(   nonvar(NS)
	->  Max = inf
	;   Max = Max0
	),
	include(ground, [ns(NS), max_per_ns(Max), show(Show)], Options),
	findall(Class, clause(qa:rdf_warning(Class, _), _), Classes),
	warnings_by_class(Classes, ByCLass, Options),
	reply_html_page(cliopatria(main),
			title('RDF Quality report'),
			body(\qa_report(ByCLass, Options))
		       ).

qa_index([]) --> [].
qa_index([Class|T]) -->
	{ answer_count(URI,qa:rdf_warning(Class, URI), 100, C),
	  C > 0, !,
	  http_location([ path(qa),
			  search([ class=Class ])
			], Location)
	},
	html_requires(qa),
	html(div(class(qa_class_title), a(href(Location), [\qa:class_label(Class), \count(100, C)]))),
	qa_index(T).
qa_index([_|T]) -->
	qa_index(T).

count(C, C) -->
	html(' (> ~D)'-[C]).
count(_, C) -->
	html(' (~D)'-[C]).

qa_report([], _) --> !,
        html(p('Could not find any problems in the RDF.')).
qa_report(Classes, Options) -->
        html_requires(qa),
        html([
               \report_by_class(Classes, Options)
             ]).

report_by_class([], _) -->
        [].
report_by_class([Class-Grouped|T], Options) -->
        html([ h3(class(qa_class_heading),a(name(Class), \qa:class_label(Class))),
               ul(\show_groups(Grouped, [class(Class)|Options]))
             ]),
        report_by_class(T, Options).

show_groups([], _) -->
        [].
show_groups([NS-URIs|T], Options) -->
        html(li(class(show_groups_li), [ \show_namespace(NS, Options),
                  ol(\show_uris(URIs, [ns(NS)|Options]))
                ])),
        show_groups(T, Options).


show_namespace(NS, Options) -->
        { atom_concat('__file://', Path, NS), !,
          option(class(Class), Options)
        },
        html([\qa:class_label(Class), ' for blank nodes from ', tt(Path)]).
show_namespace(NS, Options) -->
        { option(class(Class), Options)
        },
        html([\qa:class_label(Class), ' for namespace ', tt(NS)]).

show_uris(URIs, Options) -->
        { option(max_per_ns(Max), Options, 20),
          option(show(Show), Options, local_view),
          length(URIs, Len)
        },
        list_uris(URIs, Show),
        (   {Max == inf ; Len < Max}
        ->  []
        ;   more_link(Options)
        ).

show_uri(H, uri) --> !,
        html(li(class(show_uri), a(href(H), H))).
show_uri(H, _) -->
        html(li(class(show_uri_local), \rdf_link(H))).

show_triple(rdf(S,P,O), _) -->
        { rdf(S,P,O,DB) }, !,
        html(li([ '{',
                  \rdf_link(S),
                  ', ',
                  \rdf_link(P),
                  ', ',
                  \rdf_link(O),
                  '}',
                  \source(DB)
                ])).

more_link(Options) -->
        { option(class(Class), Options),
          option(ns(NS), Options),
          http_location([ path(qa),
                          search([ ns=NS, class=Class ])
                        ], Location)
        },
        html(['... ', a(href(Location), 'show all')]).

source(URI:Line) -->
        { Line < 1e9, !,
          file_base_name(URI, Base)
        },
        html([' from ', code(Base), ' at line ~D'-[Line]]).
source(URI:Time) --> !,
        { format_time(string(T), '%F:~R', Time) },
        html([' by ', code(URI), ' at ', T]).
source(X) -->                           % debugging
        { term_to_atom(X, A) },
        html(A).



list_uris([], _) -->
        [].
list_uris([H|T], Show) -->
        show_hit(H, Show),
        list_uris(T, Show).

show_hit(H, Show) -->
        { atom(H) }, !,
        show_uri(H, Show).
show_hit(H, Show) -->
        { H = rdf(_,_,_) }, !,
        show_triple(H, Show).



		 /*******************************
		 *	     COLLECT		*
		 *******************************/

warnings_by_class([], [], _).
warnings_by_class([H|T0], [H-Warnings|T], Options) :-
	warnings_for_class(H, Warnings, Options),
	Warnings \== [], !,
	warnings_by_class(T0, T, Options).
warnings_by_class([_|T0], T, Options) :-
	warnings_by_class(T0, T, Options).

warnings_for_class(Class, Grouped, Options) :-
	option(max_per_ns(Max), Options, 20),
	option(ns(NS), Options, _),
	answer_pair_set(NS-URI, warning_by_ns(Class, NS, URI),
			  inf, Max, Grouped).



warning_by_ns(Warning, NS, URI) :-
	qa:rdf_warning(Warning, URI),
	namespace(URI, NS).

namespace(rdf(URI, _, _), NS) :- !,
	rdf_split_url(NS, _Id, URI).
namespace(URI, NS) :- !,
	rdf_split_url(NS, _Id, URI).


