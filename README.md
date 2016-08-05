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
      account_type: AccountTypes::Checking,
      amount: BigDecimal.new('575.45'),
      memo: '????',
      merchant_name: 'DOE, JOHN',
      routing_number: nil,
      transaction_type: TransactionTypes::Credit,
      ach_id: 'foooo'
    ),
    ...
  ]
)

# Send the batch to the provider
batch.send_batch
```

`send_batch` returns a tracking string on success.
This string can be used to track the transaction later (not yet implemented)


### AchWorks

Some settings need to be configured first for using AchWorks provider:

```ruby
AchClient::AchWorks.company_key = 'SASD%!%$DGLJGWYRRDGDDUDFDESDHDD'
AchClient::AchWorks.company = 'MYCOMPANY'
AchClient::AchWorks.loc_i_d = '9505'
AchClient::AchWorks.s_s_s = 'TST'
AchClient::AchWorks.wsdl = 'http://tstsvr.achworks.com/dnet/achws.asmx?wsdl'
```

## Documentation

View them at https://forwardfinancing.github.io/ach_client/doc/AchClient/AchWorks.html

Uses yardocs. Run `yard doc && open docs/index.html` to generate and view docs.

To update the docs, checkout the `gh-pages` branch.
Then run `yard doc` and push your changes up.
The `gh-pages` has the doc directory included in source control. It should
never be merged.


## Development

After checking out the repo, run `bin/setup` to install dependencies.

Then, run `rake test` to run the tests.

You can also run `bin/console` for an interactive prompt that
will allow you to experiment.


## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/ForwardFinancing/ach_client.
