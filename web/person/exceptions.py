class RegistrationException(Exception):
    pass

class RegistrationFail(RegistrationException):
    pass

class AlreadyRegistered(RegistrationException):
    pass