class BaseClient(object):

    def get_settings(self, *args, **kwargs):
        raise NotImplementedError()

    def wall_post(self, *args, **kwargs):
        raise NotImplementedError()

    def fetch_user(self, *args, **kwargs):
        raise NotImplementedError()

    def fetch_friends(self, *args, **kwargs):
        raise NotImplementedError()