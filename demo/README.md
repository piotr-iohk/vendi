# Vendi Demo

Vendi demo is available [HERE](http://185.201.114.10:4321).

## How it was prepared

I have used [cardano-up](https://github.com/piotr-iohk/cardano-up) to spin up `cardano-node` and `cardano-wallet` on `preview` and `preprod` networks. That was easy!

	$ cardano-up preview up --port 8090
	$ cardano-up preprod up --port 8091

Preview wallet works on port `8090`, preprod one on `8091`. Ok.

I have filled Vendi with exemplary set of NFTs for both networks:

    $ vendi fill --collection TestBudzPreview --price 10000000 --nft-count 100 --wallet-port 8090
    $ vendi fill --collection TestBudzPreprod --price 10000000 --nft-count 100 --wallet-port 8091

Vendi told me which address I need to fund for each vending machine and that's what I did. Thank you [Faucet](https://docs.cardano.org/cardano-testnet/tools/faucet)!

I waited few minutes until wallets synced and started vending machines:

    $ vendi serve --collection TestBudzPreview --vend-max 5 --wallet-port 8090 --logfile preview.log
    $ vendi serve --collection TestBudzPreprod --vend-max 5 --wallet-port 8091 --logfile preprod.log

I wanted the logs to be available on the demo frontend. For that I used [frontail](https://github.com/mthenw/frontail). Very cool!

    $ frontail -p 9001 preview.log
    $ frontail -p 9002 preprod.log

Finally I have started demo frontend from this folder! :tada:

    $ HOST=<my_ip> ruby demo.rb
