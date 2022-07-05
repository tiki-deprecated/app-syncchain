# 0.0.10

* Remove synced NFTs event

# 0.0.9

* Improve AuthorizeService error log

# 0.0.8

* add Amplitude
* update dependencies

# 0.0.7

* method to get sync state
* tests for db slice

# 0.0.6

* handle key previously registered

# 0.0.5

* fixed bugs with token refresh for key registration

# 0.0.4

* use synchronous sign function for performance
* use a function to get current access token

# 0.0.3

* fixed an issue with the tiki_syncchain_block naming

# 0.0.2

* change name to tiki_syncchain
* publish to pub

## 0.0.1

* Base functionality implemented. Write, Read, Verify
* Includes a durable caching layer to reduce read CPU 
  load. Table level security needed.
* Crypto methods are unit tested
* Package missing integration & unit tests
* No remote backup sync function implemented. 
  Careful with keys, invalid keys will erase chain.

