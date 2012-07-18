def model_to_dict(model, fields):
    return dict([ (fname, str(getattr(model, fname))) for fname in fields ])

def filter_fields(data, required_fields):
    filtered = dict([ (k,v) for k,v in data.items() if k in required_fields])
    if set(filtered.keys()).issuperset(set(required_fields)):
        return filtered
    else:
        return {}
