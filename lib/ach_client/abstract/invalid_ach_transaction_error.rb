# To be raised when an ACH transaction can not be sent because it is invalid
class InvalidAchTransactionError < RuntimeError
end