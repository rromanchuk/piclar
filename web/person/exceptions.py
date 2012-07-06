class RegistrationException(Exception):
    pass

class RegistrationFail(RegistrationException):
    pass

class AlreadyRegistered(RegistrationException):
    def __init__(self, person, *args, **kwargs):
        self.person = person
        super(AlreadyRegistered, self, *args, **kwargs)

    def get_person(self):
        return self.person