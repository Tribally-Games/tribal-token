![Build status](https://github.com/Tribally-Games/tribal-token/actions/workflows/ci.yml/badge.svg?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/Tribally-Games/tribal-token/badge.svg?t=wvNXqi)](https://coveralls.io/github/Tribally-Games/tribal-token)

# tribal-token

The `TRIBAL` ERC-20 token.

Features:

* Has an owner that can be changed (`0x0000...` not allowed).
* Has changeable minter that is set by owner. Only the minter can mint new tokens.
* Anyone can burn their own tokens.

## On-chain addresses

_TODO: Live deployed addresses here_

## Developer guide

Install pre-requisites:

* [Foundry](https://book.getfoundry.sh/)
* [pnpm](https://pnpm.io/)

Install dependencies:

```shell
$ pnpm i
```

To compile the contracts:

```shell
$ pnpm build
```

To test:

```shell
$ pnpm test
```

To run a local devnet:

```shell
$ pnpm devnet
```

## Deployment

* _The `owner` and `minter` are both initially set to be the deployment wallet's address._
* _[CREATE2](https://book.getfoundry.sh/tutorials/create2-tutorial) is used for deployment, so the address will always be the same as long as the deployment wallet and bytecode are the same, irrespective of chain, nonce, etc._

### Local (anvil)

To deploy locally, first run a local devnet:

```shell
$ pnpm devnet
```

Then run:

```shell
$ pnpm deploy-local
```

### Public


Set the following environment variables:

```shell
$ export PRIVATE_KEY="0x..."
```

Then run:

* Testnet (Base Sepolia): `pnpm deploy-base-sepolia`
* Mainnet (Base): `pnpm deploy-base`

## License

GPLv3 - see [LICENSE.md](LICENSE.md)

tribal-token smart contracts
Copyright (C) 2024  [Tribally Games](https://tribally.games)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
