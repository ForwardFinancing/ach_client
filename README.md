[![Code Climate](https://codeclimate.com/repos/57a229c5c6e5cf08910039d4/badges/105ddb79b7f5c008bccd/gpa.svg)](https://codeclimate.com/repos/57a229c5c6e5cf08910039d4/feed)
[![Test Coverage](https://codeclimate.com/repos/57a229c5c6e5cf08910039d4/badges/105ddb79b7f5c008bccd/coverage.svg)](https://codeclimate.com/repos/57a229c5c6e5cf08910039d4/coverage)
[![Issue Count](https://codeclimate.com/repos/57a229c5c6e5cf08910039d4/badges/105ddb79b7f5c008bccd/issue_count.svg)](https://codeclimate.com/repos/57a229c5c6e5cf08910039d4/feed)

# AchClient

Execute `bin/console` to run this gem in terminal.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ach_client'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install ach_client

## Usage

### Sending batch ACH transactions


```ruby

# Create a batch with a list of transactions
batch = AchClient::AchBatch.new(
  ach_transactions: [
    AchClient::AchTransaction.new(
      account_number: '00002323044',
      account_type: AchClient::AccountTypes::Checking,
      amount: BigDecimal.new('575.45'),
      memo: '????',
      merchant_name: 'DOE, JOHN',
      originator_name: 'you',
      sec_code: 'CCD'
      routing_number: nil,
      transaction_type: AchClient::TransactionTypes::Credit,
      ach_id: 'foooo',
      customer_id: '123'
    ),
    ...
  ]
)

# Send the batch to the provider
batch.send_batch
```

`send_batch` returns a tracking string on success.
This string can be used to track the transaction later (not yet implemented)


### Checking Transaction status

AchWorks requires you to provide a "FrontEndTrace" when you send your
transaction, but does not let you query by front_end_trace when checking status.
You can only query for the most recent statuses, and those within a given date
range.

See the AchStatusChecker class for more details.

To check statuses:

```ruby
  # Build a status checker with your company details:
  status_checker = AchClient::AchWorks::AchStatusChecker.new(
    company_info: AchClient::AchWorks::InputCompanyInfo.build
  )

  # Check the most recent transactions
  status_checker.most_recent

  # Check the transactions with a date range
  status_checker.in_range(start_date: 1.week.ago, end_date: Date.today)
```

Both of these methods return a `Hash` with the "FrontEndTrace" as the keys and
instances of AchClient::AchResponse as values.

### Responses

There are a number of response states that can result from checking on the
status of your ACH transactions.

- `SettledAchResponse`: The transaction went through. :tada:
- `ProcessingAchResponse`: The transaction hasn't gone through yet. Patience.
- `ReturnedAchResponse`: The transaction was returned cause something went
wrong. Check the return code on the response object for details
- `CorrectedAchResponse`: The transaction received a correction because some
information has changed. Check the return code on the response object for
details on what happened. Check the corrections hash on the response object for
the new attributes

### AchWorks

Some settings need to be configured first for using AchWorks provider:

```ruby
AchClient::AchWorks.company_key = 'SASD%!%$DGLJGWYRRDGDDUDFDESDHDD'
AchClient::AchWorks.company = 'MYCOMPANY'
AchClient::AchWorks.loc_i_d = '9505'
AchClient::AchWorks.s_s_s = 'TST'
AchClient::AchWorks.wsdl = 'http://tstsvr.achworks.com/dnet/achws.asmx?wsdl'
```

AchWorks recommends that you call their "ConnectionCheck" and
"CheckCompanyStatus" before each request. We've included some wrappers for
those endpoints in case you want to go that route.

```ruby
# ConnectionCheck
AchClient::AchWorks::InputCompanyInfo.build.connection_valid?

#CheckCompanyStatus
AchClient::AchWorks::InputCompanyInfo.build.company_valid?

# Both
AchClient::AchWorks::InputCompanyInfo.build.valid?
```

#### Logging

For record keeping purposes, there is a log provider that allows you to hook
into all requests sent to AchWorks and send them to your logging service.

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

## Development

After checking out the repo, run `bin/setup` to install dependencies.

Then, run `rake test` to run the tests.

You can also run `bin/console` for an interactive prompt that
will allow you to experiment.


### Documentation

View them at https://forwardfinancing.github.io/ach_client/doc/AchClient/AchWorks.html

Uses yardocs. Run `yard doc && open docs/index.html` to generate and view docs.

To update the docs, checkout the `gh-pages` branch.
Then run `yard doc` and push your changes up.
The `gh-pages` has the doc directory included in source control. It should
never be merged.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/ForwardFinancing/ach_client.
