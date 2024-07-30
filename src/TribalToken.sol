// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { OFT } from "@layerzerolabs/lz-evm-oapp-v2/contracts/oft/OFT.sol";


contract TribalToken is OFT {
  /**
   * @dev A zero address was passed.
   */
  error ZeroAddress();

  /**
   * @dev The caller account is not authorized to mint.
   */
  error UnauthorizedMinter(address account);

  /**
   * @dev The minter can mint new tokens.
   */
  address public minter;

  /**
   * @dev Throws if called by any account other than the minter.
   */
  modifier onlyMinter() {
      if(_msgSender() != minter) {
        revert UnauthorizedMinter(_msgSender());
      }
      _;
  }

  /**
   * @dev Constructor
   * @param _owner The address of the initial owner of the contract.
   * @param _minter The address of the initial minter of the contract. Can be the zero address to disable minting.
   * @param _endpoint The address of the LayerZero endpoint.
   */
  constructor(address _owner, address _minter, address _endpoint) OFT("Tribal", "TRIBAL", _endpoint, _owner) Ownable(_owner) {
    minter = _minter;
  }

  /**
   * @dev The owner can set the minter.
   * @param _minter The address of the new minter. Can be the zero address to disable minting.
   */
  function setMinter(address _minter) public onlyOwner {
    minter = _minter;
  }

  /**
   * @dev The minter can mint new tokens.
   * @param _to The address to which the minted tokens will be sent.
   * @param _amount The amount of tokens to mint.
   */
  function mint(address _to, uint256 _amount) public onlyMinter {
    _mint(_to, _amount);
  }

  /**
   * @dev Burn one's own tokens.
   * @param _amount The amount of tokens to burn.
   */
  function burn(uint256 _amount) public {
    _burn(_msgSender(), _amount);
  }
}
