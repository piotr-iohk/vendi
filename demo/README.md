# Vendi Demo

Vendi demo is available [HERE](http://185.201.114.10:4321).

## How it was done

We have used [cardano-up](https://github.com/piotr-iohk/cardano-up) to spin up `cardano-node` and `cardano-wallet` on `preview` and `preprod` networks. That was easy!

	$ cardano-up preview up --port 8090
	$ cardano-up preprod up --port 8091

Preview wallet works on port `8090`, preprod one on `8091`. Ok.

We have filled Vendi with exemplary set of NFTs for both networks:

    $ vendi fill --collection TestBudzPreview --price 10000000 --nft-count 100 --wallet-port 8090
    $ vendi fill --collection TestBudzPreprod --price 10000000 --nft-count 100 --wallet-port 8091

Vendi told us which address we need to fund for each vending machine and that's what we did. Thank you [Faucet](https://docs.cardano.org/cardano-testnet/tools/faucet)!

We waited few minutes until our wallets synced and started our vending machines:

    $ vendi serve --collection TestBudzPreview --wallet-port 8090 --logfile preview.log
    $ vendi serve --collection TestBudzPreprod --wallet-port 8091 --logfile preprod.log

We wanted our logs to be available on our demo frontend. For that we used [frontail](https://github.com/mthenw/frontail). Very cool!

    $ frontail -p 9001 preview.log
    $ frontail -p 9002 preprod.log

Finally we have started our demo frontend from this folder! :tada:

    $ HOST=<our_ip> ruby demo.rb
