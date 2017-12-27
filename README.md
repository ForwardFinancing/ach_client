[![Code Climate](https://codeclimate.com/github/ForwardFinancing/ach_client/badges/gpa.svg)](https://codeclimate.com/github/ForwardFinancing/ach_client)

[![Test Coverage](https://codeclimate.com/github/ForwardFinancing/ach_client/badges/coverage.svg)](https://codeclimate.com/github/ForwardFinancing/ach_client/coverage)

[![Issue Count](https://codeclimate.com/github/ForwardFinancing/ach_client/badges/issue_count.svg)](https://codeclimate.com/github/ForwardFinancing/ach_client)

[![Build Status](https://travis-ci.org/ForwardFinancing/ach_client.svg?branch=master)](https://travis-ci.org/ForwardFinancing/ach_client)

# AchClient

## Overview

The AchClient gem provides a common interface for working with a variety of
ACH providers.

Supported features include:

- **Individual Transactions:** Sending a single ACH transaction for the provider to process
- **Batch Transactions:** Sending a batch of ACH transactions together to the provider to process
- **Response Polling:** Retrieving the results of sent ACH transactions from the provider, and processing that response into a standardized format

Some providers may not support all features


| Provider           | Individual ACH      | Batch ACH           | Response Polling    |
| ------------------ | ------------------- | ------------------- | ------------------- |
| AchWorks           | :white_check_mark:  | :white_check_mark:  | :white_check_mark:  |
| ICheckGateway      | :white_check_mark:  | :x:                 | :white_check_mark:  |
| NACHA+SFTP Providers  | :x:                 | :white_check_mark:  | :white_check_mark:  |

### About NACHA+SFTP Providers

Many banks/financial institutions use a similar system for receiving ACH
transactions. For these providers, batches of ACH transactions can be
represented in the NACHA file format. The bank provides you with an SFTP server
where you can deposit these files. After the transactions are processed, the
provider will leave another NACHA file containing the results on the server in
an "Inbox" or "Outgoing" directory.

The two API providers tend to be more reliable and easier to work with, but it
is usually cheaper to interact directly with a financial institution.

## Structure

Each provider has its own namespace. For all of the example code, you must replace `Provider` with a provider you want to use.

For example, `AchClient::Provider::AchBatch` might become `AchClient::AchWorks::AchBatch`

For NACHA+SFTP providers, referencing them by name will create the namespace.
For example, Silicon Valley Bank is a provider which adheres to the NACHA/SFTP
standard. There is no AchClient::SiliconValleyBank namespace in the codebase,
but if you reference that provider, it will be dynamically defined for you.

## Individual ACH transactions

Create an instance of an AchTransaction following the code sample below:

- *The Merchant* is the person/company to whom you will be sending an ACH credit or debit.

- All account type classes are listed [here](https://forwardfinancing.github.io/ach_client/doc/AchClient/AccountTypes.html)

- All transaction type classes are listed [here](https://forwardfinancing.github.io/ach_client/doc/AchClient/TransactionTypes.html)

- Checkout the abstract `AchTransaction` class and the `AchTransaction` class for each provider for more info.

```ruby
AchClient::Provider::AchTransaction.new(
  # The merchant's account number
  account_number: '115654668777',
  # The merchant's account type (see account types note above)
  account_type: AchClient::AccountTypes::BusinessChecking,
  # The amount of the ACH transaction, should be positive
  amount: BigDecimal.new('575.45'),
  # The date on which you would like the transaction to take effect.
  # Beware that some providers may use this field to charge you extra for
  # same-day ACH ( a recent feature for ACH providers )
  effective_entry_date: Date.today,
  # Will show up on the merchant's bank statement
  memo: '????',
  # The name of the merchant
  merchant_name: 'test merchant',
  # Your name (or the name of your company)
  originator_name: 'ff',
  # The merchants routing number
  routing_number: '083000108',
  # The ACH "Standard Entry Class" code to use for the ACH (google it for more)
  sec_code: 'CCD',
  # Is the transaction a credit or debit against the merchant?
  transaction_type: AchClient::TransactionTypes::Debit,
  # See section below
  external_ach_id: 'blah'
)
```

You can send the transaction to the provider by invoking the `#send` instance method on your instance of an `AchTransaction`. If the ACH transaction was successfully sent to the provider, the `external_ach_id` for the transaction will be returned. If sending the transaction was unsuccessful, an exception will be thrown.

Successfully sending the transaction does not equate to the transaction actually being executed against the merchant's bank account. ACH transactions are inherently asynchronous because financial institutions can take days and in rare cases even months to process them.

### External ACH ID

The `external_ach_id` value can be used to track what happens to your transaction after you send it. You can use it to match transactions that you sent against results later received by the response polling methods.

The `external_ach_id` should be unique per transaction.

Some providers do not allow you to supply your own tracking id. Other providers require you to provide your own unique tracking id.

The tracking id that the provider actually uses with your transaction will be
returned by the `#send` method. So you should:

1) Create an instance of `AchTransaction` with a unique `external_ach_id` that you would *like* to use

2) Call `#send` on your transaction

3) Store the return value of `#send` somewhere - this is the `external_ach_id` that was actually used

4) When you eventually poll the provider for the status of your transactions, you can use the `external_ach_id` you stored to reconcile the returned data against your records

## Batched ACH transactions

A group of ACH transactions can also be sent in a single batched transaction to
providers who support this functionality.

Checkout the abstract `AchBatch` class and the `AchBatch` class for each provider for more info.

Create an instance of `AchBatch` for your provider. The constructor takes an array of `AchTransactions` (which are described above).

```ruby
  AchClient::Provider::AchBatch.new(
    ach_transactions: []
  )
```

To send the batch to the provider, invoke the `#send_batch` method on your instance of `AchBatch`.

If sending the batch was successful, a list of `external_ach_id` will be returned. If it was unsuccessful, either because the whole batch or a single transaction was invalid, an exception will be raised, and none of the transactions will have been sent to the provider.

Successfully sending the transaction batch does not equate to the transactions actually being executed against the merchants' bank accounts. ACH transactions are inherently asynchronous because financial institutions can take days and in rare cases even months to process them.

SFTP+NACHA providers take an optional `batch_number` parameter which may be used in the filename for uploaded NACHA files.

```ruby
  AchClient::SomeBank::AchBatch.new(
    ach_transactions: [],
    batch_number: 5
  )
```

## Response Polling - Checking Transaction Status

None of the providers support querying for transaction status by external_ach_id. Instead, we must query by date and

To check statuses:

```ruby
  # Check the most recent transactions
  AchClient::Provider::AchStatusChecker.most_recent

  # Check the transactions with a date range
  AchClient::Provider::AchStatusChecker.in_range(
    start_date: 1.week.ago,
    end_date: Date.today
  )
```

Both of these methods return a `Hash` with the `external_ach_id` for ach_transaction as the keys and
a list of instances of AchClient::AchResponse as values. A polling response may contain
more than one response record for each `external_ach_id` if that ACH has changed
statuses more than once within the polling range.

### Responses

There are a number of response states that can result from checking on the
status of your ACH transactions. Each inherit from `AchClient::AchResponse`

- `SettledAchResponse`: The transaction went through. :tada:
- `ProcessingAchResponse`: The transaction hasn't gone through yet. Patience.
- `ReturnedAchResponse`: The transaction was returned cause something went
wrong. Check the return code on the response object for details
- `CorrectedAchResponse`: The transaction received a correction because some
information has changed. Check the return code on the response object for
details on what happened. Check the corrections hash on the response object for
the new attributes

## Logging

For record keeping purposes, there is a log provider that allows you to hook
into all requests sent to a SOAP provider and send them to your logging service.

The default log provider is the NullLogProvider, which does not log requests.

```ruby
# No logging
AchClient::Logging.log_provider = AchClient::Logging::NullLogProvider

# Log to stdout
AchClient::Logging.log_provider = AchClient::Logging::StdoutLogProvider

# Log to wherever you want by creating your own LogProvider class
# and overriding #send_logs
class MyCustomLogger < AchClient::Logging::LogProvider
  # This method takes a log body and a log name
  def self.send_logs(body:, name:)
    # Do whatever you want, like send the log data to S3, or whatever
    #   logging service you choose
  end
end
AchClient::Logging.log_provider = MyCustomLogger
```

### Log Filtering

Log filtering is available for logs with key/value pairs. To enable log filtering, provide a list of keys who's values you would like to be scrubbed. Those values will be replaced with *

```ruby
AchClient::Logging.log_filters = [
  'AccountNumber',
  'RoutingNumber',
  ...
]
```

### Log Encryption

To enable encryption of logs, provide both a `password` and a `salt`

```ruby
AchClient::Logging.encryption_password = 'password'
AchClient::Logging.encryption_salt = 'pepper'
```

Logs will be encrypted after they are filtered, but before they are passed to the `LogProvider` implementation you chose.

AchClient doesn't support reading from your log store, you will need to decrypt logs yourself as needed. For convenience, a decryption function has been provided that decrypts a message using the above provided `password` and `salt`.

```ruby
AchClient::Logging.decrypt_log('encrypted log gibberish.....')
```

## Provider Configuration Setup

Each provider has a set of configuration attributes that must be set.
Most of these values can be retrieved by contacting the provider directly.
You can set the configuration variables by assigning them directly to the class attributes on the provider module. For example, if the provider is AchWorks, and the configuration attribute is password:

```ruby
AchClient::AchWorks.password = 'your password'
```

You probably want to set these variables from environment variables instead of hardcoding them into your app.

Some test configuration values are provided for testing/development of this gem. You can find them in the `bin/console` file and in the test helper. Be aware that these credentials may be used to send data to some providers' test environments under a shared test account. Avoid using real customer data in test.

### AchWorks

| Attribute      | Description                              |
| -------------- | ---------------------------------------- |
| `company_key`  | Company credential provided by AchWorks  |
| `company`      | Company credential provided by AchWorks  |
| `loc_i_d`      | Company credential provided by AchWorks  |
| `s_s_s`        | Company credential provided by AchWorks  |
| `wsdl`         | URL for the WSDL for AchWorks SOAP API   |
| `client_timeout_seconds` | Seconds to wait for a web response (optional) |

### ICheckGateway

| Attribute      | Description                              |
| -------------- | ---------------------------------------- |
| `site_i_d`     | Company credential provided by ICheckGateway  |
| `site_key`     | Company credential provided by ICheckGateway  |
| `api_key`      | Company credential provided by ICheckGateway  |
| `live`         | `true` if you want transactions to be actually processed, `false` otherwise. Note: `true` only works with your production credentials, and `false`  only works with the shared test credentials |
| `wsdl`         | URL for the WSDL for ICheckGateway SOAP API   |
| `client_timeout_seconds` | Seconds to wait for a web response (optional) |

### NACHA + SFTP Providers

Most US banks use the same system for sending and receiving ACH transactions.

For these providers, batches of ACH transactions are
represented in the NACHA file format. The bank provides you with an SFTP server
where you can deposit these files. After the transactions are processed, the
provider will leave another NACHA file containing the results on the server in
an "Inbox" or "Outgoing" directory.

So far this setup has been confirmed to work with the following providers:
- Bank Of America
- Silicon Valley Bank

You'll notice there aren't any provider namespaces in the codebase for these.
You can define your own namespace simply by referencing it.

For example, the first time you reference `AchClient::FakeBank`, all the following class attributes will be automatically defined for
`AchClient::FakeBank`, along with the following classes:
- `AchClient::FakeBank::AchTransaction`
- `AchClient::FakeBank::AchBatch`
- `AchClient::FakeBank::AchStatusChecker`

After setting the variables described in the below table, you can interact with
these new classes using the same interface described above for the API providers.

| Attribute      | Description                              |
| -------------- | ---------------------------------------- |
| `immediate_destination`  | ID for company that is receiving the NACHA file (the bank)  |
| `immediate_destination_name`  | Name of company that is receiving the NACHA file (the bank)  |
| `immediate_origin`  | ID for company that is sending the NACHA file (you)  |
| `immediate_origin_name`  | Name of company that is sending the NACHA file (you) |
| `company_identification`  | ID of your company   |
| `company_entry_description` | ID of company (provided by bank) |
| `originating_dfi_identification` | ID of bank (provided by bank) |
| `host` | URL of bank's SFTP server |
| `username` | Username to connect via SFTP to bank's server |
| `password` | Password to connect via SFTP to bank's server |
| `private_ssh_key` | Private SSH key that matches the public key you gave the bank to put on their SFTP server (if applicable) |
| `passphrase` | Passphrase for your private SSH key. If your passphrase was blank, leave this `nil` |
| `outgoing_path` | Path on the remote server where bank has asked you to dump your NACHAs |
| `incoming_path` | Path on the remote server where the bank leaves confirmation/return files |
| `file_naming_strategy` | Function to define filenames for the NACHA files |

#### File Naming Strategy

This attribute is a function to define filenames for the NACHA files. It is
called from the `send_batch` method of the `AchBatch` class in your SFTP+NACHA provider's namespace. It will be passed a `batch_number` parameter, which may be
`nil`.

As an example, SiliconValleyBank's naming convention is as follows:
- The first four characters are ACHP
- The next 6 characters are the date formatted MMDDYY
- The last 2 characters are a "sequence number" which shows the number of
batches that have sent in the current day.
The `file_naming_strategy` for this can be defined as follows:

```ruby
AchClient::SiliconValleyBank.file_naming_strategy = lambda do |batch_number|
  batch_number ||= 1
  "ACHP#{Date.today.strftime('%m%d%y')}#{batch_number.to_s.rjust(2, '0')}"
end
```

#### Assumptions about response files from NACHA/SFTP providers

NACHA response files containing transaction confirmations, returns, and
corrections are deposited by your bank in an 'Inbox' or 'Outgoing' folder on the
SFTP server they provide. The status check functionality for these providers
makes a few assumptions about this folder:

- All the files in it are inbound response files, which should be processed. If
this is not true for some bank, we will need to add a file naming strategy configuration attribute for inbound files.
- The SFTP user has write access to the inbound file directory. The
`most_recent` functionality leaves a file that records the last access
timestamp. If the SFTP user does not have write access, and your bank won't give
it to you, we'll have to find another way to implement that.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ach_client'
```

And then execute:

    $ bundle install

Or install it yourself:

    $ gem install ach_client

## Development

After checking out the repo, run `bin/setup` to install dependencies.

Then, run `bundle exec rake test` to run the tests.

Execute `bin/console` to run this gem in terminal.

### Documentation

View them at https://forwardfinancing.github.io/ach_client/doc/index.html

Uses yardocs. Run `yard doc && open docs/index.html` to generate and view docs.

To update the docs, checkout the `gh-pages` branch and rebase it against
master.
Then run `yard doc` and push your changes up.
The `gh-pages` has the doc directory included in source control. It should
never be merged.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/ForwardFinancing/ach_client.
