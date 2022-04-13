rule make_auspice_config:
    """
    This rule is only intended to be run with `nextstrain-open` or `nextstrain-gisaid`
    profiles!
    """
    message: "Making a custom auspice config."
    output:
        "results/{build_name}/auspice_config.json"
    benchmark:
        "benchmarks/make_auspice_config_{build_name}.txt"
    run:
        import json
        is_gisaid = "gisaid" in config["inputs"]
        build_name = wildcards.build_name

        ## What are the parameters which vary across builds?
        default_geo_resolution = "country" if build_name in ["reference", "global", "africa", "south-america", "asia", "europe"] else "division"
        default_map_triplicate = True if build_name in ["reference", "global"] else False
        data_provenance = [{"name": "GISIAD"}] if is_gisaid else [{"name": "GenBank", "url": "https://www.ncbi.nlm.nih.gov/genbank/"}]
        gisaid_clade_coloring = {"key": "GISAID_clade", "title": "GISAID Clade", "type": "categorical"} if is_gisaid else None
        gisaid_epi_isl_coloring = {"key": "gisaid_epi_isl", "type": "categorical"} if is_gisaid else None
        location_coloring = {"key": "location", "title": "Location", "type": "categorical"} if is_gisaid else None
        location_filter = "location" if is_gisaid else None
        originating_lab_filter = "originating_lab" if is_gisaid else None
        submitting_lab_filter  = "submitting_lab" if is_gisaid else None
    
        data = {
            "build_url": "https://github.com/nextstrain/ncov",
            "maintainers": [
                {
                "name": "the Nextstrain team",
                "url": "https://nextstrain.org/"
                }
            ],
            "data_provenance": data_provenance,
            "colorings": [
                {
                    "key": "emerging_lineage",
                    "title": "Emerging Lineage",
                    "type": "categorical"
                },
                {
                    "key": "pango_lineage",
                    "title": "Pango Lineage",
                    "type": "categorical"
                },
                gisaid_clade_coloring,
                {
                    "key": "S1_mutations",
                    "title": "S1 Mutations",
                    "type": "continuous"
                },
                {
                    "key": "logistic_growth",
                    "title": "Logistic Growth",
                    "type": "continuous"
                },
                {
                    "key": "current_frequency",
                    "title": "Current Frequency",
                    "type": "continuous"
                },
                {
                    "key": "mutational_fitness",
                    "title": "Mutational Fitness",
                    "type": "continuous"
                },
                {
                    "key": "region",
                    "title": "Region",
                    "type": "categorical"
                },
                {
                    "key": "country",
                    "title": "Country",
                    "type": "categorical"
                },
                {
                    "key": "division",
                    "title": "Admin Division",
                    "type": "categorical"
                },
                location_coloring,
                {
                    "key": "host",
                    "title": "Host",
                    "type": "categorical"
                },
                {
                    "key": "author",
                    "title": "Authors",
                    "type": "categorical"
                },
                {
                    "key": "originating_lab",
                    "title": "Originating Lab",
                    "type": "categorical"
                },
                {
                    "key": "submitting_lab",
                    "title": "Submitting Lab",
                    "type": "categorical"
                },
                {
                    "key": "recency",
                    "title": "Submission Date",
                    "type": "categorical"
                },
                {
                    "key": "epiweek",
                    "title": "Epiweek (CDC)",
                    "type": "categorical"
                },
                gisaid_epi_isl_coloring,
                {
                    "key": "genbank_accession",
                    "type": "categorical"
                }
            ],
            "geo_resolutions": [
                "region",
                "country",
                "division"
            ],
            "display_defaults": {
                "color_by": "clade_membership",
                "distance_measure": "num_date",
                "geo_resolution": default_geo_resolution,
                "map_triplicate": default_map_triplicate,
                "branch_label": "clade",
                "transmission_lines": False
            },
            "filters": [
                "clade_membership",
                "emerging_lineage",
                "pango_lineage",
                "region",
                "country",
                "division",
                location_filter,
                "host",
                "author",
                originating_lab_filter,
                submitting_lab_filter,
                "recency"
            ],
            "panels": [
                "tree",
                "map",
                "entropy",
                "frequencies"
            ]
        }

        ## Prune out None values
        data['colorings'] = [c for c in data['colorings'] if c!=None]
        data['filters'] = [f for f in data['filters'] if f!=None]

        with open(output[0], 'w') as fh:
            json.dump(data, fh, indent=2)
