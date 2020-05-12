### 2.0.0

* Add new AchClient::ICheckGateway::InstantRejectionError to handle API errors raised by ICheckGateway in situations
where other providers would accept the transaction and issue a return when polling in the future. This is a breaking
change as previous versions would raise a RuntimeError with the message 'ICheckGateway ACH Transaction Failure' and
including the API response.

* Include "internal corrections" (return codes starting with 'XZ') in the AchClient::ReturnCode#correction? predicate

### 1.1.0

* Add AchClient::Fake provider to facilitate testing

### 1.0.3

* Add presumed description for X09 return code

### 1.0.2

* Add previously undocumented X01 internal return code

### 1.0.1

* Remove newline characters from fields before generating NACHA files

### 1.0.0

* Prior to 1.0.0, ach_client did not have a stable API.
