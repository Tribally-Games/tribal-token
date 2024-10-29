[![Build status](https://github.com/Tribally-Games/tribal-token/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/Tribally-Games/tribal-token/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/Tribally-Games/tribal-token/badge.svg)](https://coveralls.io/github/Tribally-Games/tribal-token)

# tribal-token

The `TRIBAL` ERC-20 token.

Features:

* Is a LayerZero [Omnichain Fungible Token (OFT)](https://docs.layerzero.network/v2/developers/evm/oft/quickstart).
* Has an owner that can be changed (`0x0000...` not allowed).
  * _Note: Uses the `Ownable` contract from OpenZeppelin, inherited from `OFT`._
* Has changeable minter that is set by owner. Only the minter can mint new tokens.
* Anyone can burn their own tokens.

## On-chain addresses

* Base: [0xe13E40e8FdB815FBc4a1E2133AB5588C33BaC45d](https://basescan.org/address/0xe13E40e8FdB815FBc4a1E2133AB5588C33BaC45d)
* Base Sepolia: [0xe13E40e8FdB815FBc4a1E2133AB5588C33BaC45d](https://sepolia.basescan.org/address/0xe13E40e8FdB815FBc4a1E2133AB5588C33BaC45d)

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

_NOTE: [CREATE3](https://ethereum-magicians.org/t/keyless-contract-deployment-with-create3/16025) is used for deployments. This ensure that the token address will also be the same on every chain._

Set the environment variables:

```shell
$ export VERIFIER_API_KEY=... # your block explorer (e.g Basescan.org) API key
$ export PRIVATE_KEY="0x..." # your deployer wallet private key
```

Now run (depending on the environment):

* Testnet (Base Sepolia): `pnpm deploy-base-sepolia`
* Mainnet (Base): `pnpm deploy-base`

This will deploy the CREATE3 factory, then the token contract, and then verify its source code on the block explorer.

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
