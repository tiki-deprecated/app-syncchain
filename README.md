# Sync Chain
Dart native implementation of TIKI's backup strategy for [localchains](https://github.com/tiki/localchain)
- Uses s3 for immutable hosted storage.

## How to Use
- Construct and init the `syncchain` using
```
await TikiSyncChain(
    {Httpp? httpp,
    required Database database,
    TikiKv? kv,
    String s3Bucket = 'tiki-sync-chain',
    Future<void> Function(void Function(String?)? onSuccess)? refresh,
    required Future<Uint8List> Function(Uint8List message) sign})
.init(
    {String? address,
    String? accessToken,
    String? publicKey,
    void Function(Object)? onError});`
```

*Note: If any of your project's dependencies uses sqflite (e.g: cached_network_image, flutter_cache_manager...), then for iOS to link correctly the SQLCipher libraries you need to override it in your pubspec.yaml file:*

```
dependency_overrides:
  sqflite:
    git:
      url: https://www.github.com/davidmartos96/sqflite_sqlcipher.git
      path: sqflite
      ref: fmdb_override
```

- To sync a block use
```
void syncBlock(
    {String? accessToken,
    required Uint8List hash,
    required SyncChainBlock block,
    void Function(SyncChainBlock)? onSuccess,
    void Function(Object)? onError})
```

- Get a block by its hash
```
void getBlock(
    {required Uint8List hash,
    String? version,
    void Function(SyncChainBlock)? onSuccess,
    void Function(Object)? onError})
```

- Read the chain using 
```
void getBlocks(
    {void Function(SyncChainBlock)? onSuccess,
    void Function(Object)? onError})
```

## How to contribute
Thank you for contributing with the data revolution!    
All the information about contribution can be found in [CONTRIBUTE](https://github.com/tiki/.github/blob/main/profile/CONTRIBUTE.md)

## License
[MIT license](https://github.com/tiki/syncchain/blob/main/LICENSE)
