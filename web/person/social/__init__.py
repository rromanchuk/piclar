from django.conf import settings

def provider(name):
    client_map = settings.SOCIAL_PROVIDER_CLIENTS
    class_path = client_map[name].split('.')
    class_name = class_path.pop()

    module = __import__('.'.join(class_path), fromlist='person')
    return getattr(module, class_name)()
