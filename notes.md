## ACH Tech requirements

- [ ] Nightly business process (via clock) to grab day's payment_schedule_items
and create an AchBatch.
- [ ] Within created AchBatch, send to AchWorks
- [ ] Each Merchant/Advance has a difference ACH provider. Depending on provider
perform whichever codepath needed.
- [ ] Poll for responses from various ACH Providers
- [ ] On payment/rejection import coalesce the response.

### Providers
iCheck gateway
ACHWorks
SVB
BoA (this is only for funding of advance)

### Actual Tech Reqs for wrapper
- [ ] Use the adapater pattern to create one API footprint for all providers.
- [ ] Build ach creation/batch per provider (i.e. ACHWorks API request, icheck gateway csv file).
- [ ] Integrate with response file endpoint (i.e. ACHWorks)
- [ ] Add ach provider at the advance level.
- [ ] Email CSV to correct party if CSV.

Ach works call notes
Cutoff 5pm Pacific

Do connection check before sending the batch
get ach returns is just status

8am Pacific
1pm Pacific
6pm Pacific - NSFs and stuff in addition
internally rejects transactions that are bad (sending same transaction to same closed account - return code starts with X, means it never actually went to the bank)

Will still get transactions from web console (start with W)

Sometimes get a correction to update routing number

Trace number shouldn't be random should be the same everytime
Trace numbers are unique and stay forever
Batch number must also be unique

Must be less than $3500 per transactions
No more than $382000 per day
