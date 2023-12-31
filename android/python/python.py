#the interface to Wikidata
#pip install sparqlwrapper
# https://rdflib.github.io/sparqlwrapper/

import 'dart:ffi' as ffi;
import sys
from SPARQLWrapper import SPARQLWrapper, JSON


endpoint_url = "https://query.wikidata.org/sparql"

query = """SELECT ?lexemeId ?lemma WHERE {
  ?lexemeId dct:language wd:Q3915462;
    wikibase:lemma ?lemma.
}"""


def get_results(endpoint_url, query):
    user_agent = "WDQS-example Python/%s.%s" % (sys.version_info[0], sys.version_info[1])
    # TODO adjust user agent; see https://w.wiki/CX6
    sparql = SPARQLWrapper(endpoint_url, agent=user_agent)
    sparql.setQuery(query)
    sparql.setReturnFormat(JSON)
    return sparql.query().convert()


results = get_results(endpoint_url, query)

for result in results["results"]["bindings"]:
    print(result)
