# Vendi

Vendi is simple CNFT vending machine based on `cardano-wallet`.
You need to have `cardano-wallet` started and synced.

> :information_source: Check out [cardano-up](https://github.com/piotr-iohk/cardano-up) for spinning up `cardano-wallet` quickly.

Note! It is a toy project... but... seems to work:)

## Installation

**Rubygem:**

    $ gem install vendi

## Usage

Fill vending machine with exemplary NFT collection:

    $ vendi fill --collection TestBudz

Now checkout `$HOME/.vendi-nft-machine/TestBudz`, refine configs as you prefer.
When ready start vending machine:

    $ vendi serve --collection TestBudz


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/piotr-iohk/vendi. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/piotr-iohk/vendi/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Vendi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/piotr-iohk/vendi/blob/master/CODE_OF_CONDUCT.md).
