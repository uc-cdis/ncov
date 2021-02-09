"""Small, shared functions used to generate inputs and parameters.
"""
import datetime


def numeric_date(dt=None):
    """
    Convert datetime object to the numeric date.
    The numeric date format is YYYY.F, where F is the fraction of the year passed
    Parameters
    ----------
     dt:  datetime.datetime, None
        date of to be converted. if None, assume today
    """
    from calendar import isleap

    if dt is None:
        dt = datetime.datetime.now()

    days_in_year = 366 if isleap(dt.year) else 365
    try:
        res = dt.year + (dt.timetuple().tm_yday-0.5) / days_in_year
    except:
        res = None

    return res

def _get_subsampling_scheme_by_build_name(build_name):
    return config["builds"][build_name].get("subsampling_scheme", build_name)


def _get_single_metadata(wildcards):
    """If multiple origins are specified, we fetch the metadata corresponding
    to that origin. If multiple inputs are employed, we simply return the
    corresponding (un-modified) metadata input
    """
    if isinstance(config['metadata'], str):
        return config['metadata']
    return config['metadata'][wildcards.origin[1:]]


def _get_unified_metadata(wildcards):
    """Returns a singular metadata file representing the input metadata file(s).
    If a single input was specified, this is returned.
    If multiple inputs are specified, a rule to combine them is used.
    """
    if isinstance(config['metadata'], str):
        return config['metadata']
    return "results/combined_metadata.tsv" # see rule combine_input_metadata

def _get_metadata_by_build_name(build_name):
    """Returns a path associated with the metadata for the given build name.

    The path can include wildcards that must be provided by the caller through
    the Snakemake `expand` function or through string formatting with `.format`.
    """
    if build_name == "global" or "region" not in config["builds"][build_name]:
        return _get_unified_metadata({})
    else:
        return rules.adjust_metadata_regions.output.metadata

def _get_metadata_by_wildcards(wildcards):
    """Returns a metadata path based on the given wildcards object.

    This function is designed to be used as an input function.
    """
    return _get_metadata_by_build_name(wildcards.build_name)

def _get_sampling_trait_for_wildcards(wildcards):
    if wildcards.build_name in config["exposure"]:
        return config["exposure"][wildcards.build_name]["trait"]
    else:
        return config["exposure"]["default"]["trait"]

def _get_exposure_trait_for_wildcards(wildcards):
    if wildcards.build_name in config["exposure"]:
        return config["exposure"][wildcards.build_name]["exposure"]
    else:
        return config["exposure"]["default"]["exposure"]

def _get_trait_columns_by_wildcards(wildcards):
    if wildcards.build_name in config["traits"]:
        return config["traits"][wildcards.build_name]["columns"]
    else:
        return config["traits"]["default"]["columns"]

def _get_sampling_bias_correction_for_wildcards(wildcards):
    if wildcards.build_name in config["traits"] and 'sampling_bias_correction' in config["traits"][wildcards.build_name]:
        return config["traits"][wildcards.build_name]["sampling_bias_correction"]
    else:
        return config["traits"]["default"]["sampling_bias_correction"]

def _get_max_date_for_frequencies(wildcards):
    if "frequencies" in config and "max_date" in config["frequencies"]:
        return config["frequencies"]["max_date"]
    else:
        return numeric_date(date.today())

def _get_first(config, *keys):
    """
    Get the value of the first key in *keys* that exists in *config* and has a
    non-empty value.

    Raises a :class:`KeyError` if none of the *keys* exist with a suitable
    value.
    """
    for key in keys:
        if config.get(key) not in {"", None}:
            return config[key]
    raise KeyError(str(keys))
