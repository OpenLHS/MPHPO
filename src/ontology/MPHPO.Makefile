## Customize Makefile settings for MPHPO
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

# Use of --method subset for imports

#$(IMPORTDIR)/%_import.owl: $(MIRRORDIR)/%.owl $(IMPORTDIR)/%_terms_combined.txt
#	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --update ../sparql/preprocess-module.ru \
		extract -T $(IMPORTDIR)/$*_terms_combined.txt --force true --copy-ontology-annotations true --method subset \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/inject-synonymtype-declaration.ru --update ../sparql/postprocess-module.ru \
		$(ANNOTATE_CONVERT_FILE); fi

# Custom reports exported in csv rather than tsv

SPARQL_CSTM_EXPORTS_ARGS = $(foreach V,$(SPARQL_EXPORTS),-s $(SPARQLDIR)/$(V).sparql $(REPORTDIR)/$(V).csv)


.PHONY: custom_reports
custom_reports: $(EDIT_PREPROCESSED) | $(REPORTDIR)
ifneq ($(SPARQL_EXPORTS_ARGS),)
	$(ROBOT) query --use-graphs true -i $< $(SPARQL_CSTM_EXPORTS_ARGS)
endif

# Command for building doc without GitHub publish

build_docs:
	mkdocs build --config-file ../../mkdocs.yaml

# Command for removing definition for CN/CNS

del_defs:
	$(ROBOT) query --use-graphs true -i $(ONT)-edit.$(EDIT_FORMAT) --update ../sparql/del_def_class.ru --update ../sparql/del_def_prop.ru --update ../sparql/del_def_annot.ru -o $(ONT)-edit.$(EDIT_FORMAT)

add_defs:
	$(ROBOT) query --use-graphs true -i $(ONT)-edit.$(EDIT_FORMAT) --update ../sparql/add_def_class.ru --update ../sparql/add_def_prop.ru --update ../sparql/add_def_annot.ru -o $(ONT)-edit.$(EDIT_FORMAT)

update_defs: del_defs add_defs

create_appli:
	$(ROBOT) rename -i $(RELEASEDIR)/$(ONT)-full.owl --prefix-mappings appli-rename.tsv \
	relax --exclude-named-classes false \
	remove --axioms equivalent \
	annotate --ontology-iri "http://purl.obolibrary.org/obo/MPHPO/MPHPO-appli.owl" -o $(RELEASEDIR)/ontorel/$(ONT)-appli.owl

create_ontorel_list:
	$(ROBOT) query -i $(RELEASEDIR)/ontorel/$(ONT)-appli.owl --query $(SPARQLDIR)/subsetfilter.sparql $(RELEASEDIR)/ontorel/subset_seed.txt


create_ontorel_classes_list:
	$(ROBOT) query -i $(RELEASEDIR)/ontorel/$(ONT)-appli.owl --query $(SPARQLDIR)/ontorel-classes-list.sparql $(RELEASEDIR)/ontorel/ontorel-classes-list.csv

create_ontorel_subset:
	$(ROBOT) extract -i $(RELEASEDIR)/ontorel/$(ONT)-appli.owl -T $(RELEASEDIR)/ontorel/subset_seed.txt --method subset --force true --copy-ontology-annotations true -o $(RELEASEDIR)/ontorel/$(ONT)-ontorel.owl

ontorel: create_ontorel_classes_list create_ontorel_list create_ontorel_subset