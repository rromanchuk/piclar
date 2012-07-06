class RegistrationException(Exception):
    pass

class RegistrationFail(RegistrationException):
    pass

class AlreadyRegistered(RegistrationException):
    def __init__(self, user, *args, **kwargs):
        self.user = user
        super(AlreadyRegistered, self, *args, **kwargs)

    def get_user(self):
        return self.user