:- module(conf_rdf_qa, []).

/** <module> Heuristics for spotting problems in RDF data
*/


:- use_module(cliopatria(hooks)).
:- use_module(applications(rdf_qa)).

cliopatria:menu_item(600=repository/rdf_qa_index, 'RDF quality heuristics').
