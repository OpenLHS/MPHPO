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

#	$(ROBOT) rename -i $(RELEASEDIR)/$(ONT)-full.owl --prefix-mappings appli-rename.tsv \
	relax --exclude-named-classes false \
	remove --axioms equivalent \
	annotate --ontology-iri "http://purl.obolibrary.org/obo/MPHPO/MPHPO-appli.owl" -o $(RELEASEDIR)/ontorel/$(ONT)-appli.owl

create_ontorel_from_subset:
	$(ROBOT) query -i $(SUBSETDIR)/$(SUBSETS).owl --query $(SPARQLDIR)/subsetclassfilter.sparql $(RELEASEDIR)/ontorel/tempfolder/subset_class_seed.txt
	$(ROBOT) filter -i $(SUBSETDIR)/$(SUBSETS).owl -T $(RELEASEDIR)/ontorel/tempfolder/subset_class_seed.txt --select "self annotations" --trim false -o $(RELEASEDIR)/ontorel/tempfolder/$(ONT)_ontorel1p.owl
	$(ROBOT) query -i $(RELEASEDIR)/ontorel/tempfolder/$(ONT)_ontorel1p.owl --query $(SPARQLDIR)/subsetallfilter.sparql $(RELEASEDIR)/ontorel/tempfolder/subset_all_seed.txt
	$(ROBOT) filter -i $(SUBSETDIR)/$(SUBSETS).owl -T $(RELEASEDIR)/ontorel/tempfolder/subset_all_seed.txt --select "self annotations" --trim true -o $(RELEASEDIR)/ontorel/tempfolder/$(ONT)_ontorel2p.owl
	$(ROBOT) merge -i $(RELEASEDIR)/ontorel/tempfolder/$(ONT)_ontorel1p.owl -i $(RELEASEDIR)/ontorel/tempfolder/$(ONT)_ontorel2p.owl -i $(IMPORTDIR)/Ontorel-Core_import.owl -o $(RELEASEDIR)/ontorel/$(ONT)_ontorel.owl


create_ontorel_list:
	$(ROBOT) query -i $(RELEASEDIR)/$(ONT).owl --query $(SPARQLDIR)/subsetfilter.sparql $(RELEASEDIR)/ontorel/subset_seed.txt

create_class_seed:
	$(ROBOT) query -i $(RELEASEDIR)/$(ONT).owl --query $(SPARQLDIR)/subsetclassfilter.sparql $(RELEASEDIR)/ontorel/subset_class_seed.txt


create_ontorel_classes_list:
	$(ROBOT) query -i $(RELEASEDIR)/$(ONT).owl --query $(SPARQLDIR)/ontorel-classes-list.sparql $(RELEASEDIR)/ontorel/ontorel-classes-list.csv

create_ontorel_subset:
	$(ROBOT) extract -i $(RELEASEDIR)/$(ONT).owl -T $(RELEASEDIR)/ontorel/subset_seed.txt --method subset --force true --intermediates none --copy-ontology-annotations true -o $(RELEASEDIR)/ontorel/$(ONT)_subset-ontorel.owl


create_ontorel_subsetv2:
	$(ROBOT) extract -i $(SUBSETDIR)/$(SUBSETS).owl -T $(RELEASEDIR)/ontorel/subset_class_seed.txt --method BOT --force true --copy-ontology-annotations true -o $(RELEASEDIR)/ontorel/$(ONT)_subset-ontorelv2.owl


create_ontorel_subsetv3:
	#$(ROBOT) remove -i $(SUBSETDIR)/$(SUBSETS).owl -T $(RELEASEDIR)/ontorel/subset_class_seed.txt --select complement --trim false -o $(RELEASEDIR)/ontorel/$(ONT)_subset-ontorelv3.owl
	#$(ROBOT) filter -i $(SUBSETDIR)/$(SUBSETS).owl -T $(RELEASEDIR)/ontorel/subset_class_seed.txt --select "self annotations" --trim false -o $(RELEASEDIR)/ontorel/$(ONT)_subset-ontorelv3.owl
	$(ROBOT) filter -i $(SUBSETDIR)/$(SUBSETS).owl -T $(RELEASEDIR)/ontorel/subset_class_seed.txt --select "self annotations" --trim false -o $(RELEASEDIR)/ontorel/$(ONT)_subset-ontorelv3.owl
	#$(ROBOT) merge -i $(RELEASEDIR)/ontorel/$(ONT)_subset-ontorelv3.owl -i $(RELEASEDIR)/ontorel/$(ONT)_subset-ontorelv4.owl -o $(RELEASEDIR)/ontorel/$(ONT)_subset-ontorelv5.owl

create_ontorel_listv3:
	$(ROBOT) query -i $(RELEASEDIR)/ontorel/$(ONT)_subset-ontorelv3.owl --query $(SPARQLDIR)/subsetfilter2.sparql $(RELEASEDIR)/ontorel/subset_seed2.txt
	$(ROBOT) filter -i $(SUBSETDIR)/$(SUBSETS).owl -T $(RELEASEDIR)/ontorel/subset_seed2.txt --select "self annotations" --trim true -o $(RELEASEDIR)/ontorel/$(ONT)_subset-ontorelv4.owl
	$(ROBOT) merge -i $(RELEASEDIR)/ontorel/$(ONT)_subset-ontorelv3.owl -i $(RELEASEDIR)/ontorel/$(ONT)_subset-ontorelv4.owl -i $(IMPORTDIR)/Ontorel-Core_import.owl -o $(RELEASEDIR)/ontorel/$(ONT)_subset-ontorelv5.owl

ontorel: create_ontorel_classes_list create_ontorel_list create_ontorel_subset