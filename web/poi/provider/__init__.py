from django.conf import settings

def get_poi_client(name):
    client_map = settings.POI_PROVIDER_CLIENTS
    class_path = client_map[name].split('.')
    class_name = class_path.pop()

    module = __import__('.'.join(class_path), fromlist='poi')
    return getattr(module, class_name)()