// SPDX-License-Identifier: GPLv3
pragma solidity ^0.8.24;

import { Vm } from "forge-std/Vm.sol";
import { Script, console2 as c } from "forge-std/Script.sol";
import { TribalToken } from "src/TribalToken.sol";
import { LzDummyEndpoint } from "src/LzDummyEndpoint.sol";

contract Deploy is Script {
  bytes32 internal constant CREATE2_SALT = keccak256("Tribally.deployment.salt");

  function run() public {
    address wallet = msg.sender;
    c.log("Wallet:", wallet);

    address endpoint = vm.envAddress("LZ_ENDPOINT");
    c.log("LayerZero endpoint:", endpoint);
    if (endpoint == address(0)) {
      c.log("Empty LayerZero endpoint, deploying fresh one...");
      endpoint = address(new LzDummyEndpoint());
      c.log("LayerZero endpoint deployed at:", endpoint);
    }

    address expectedAddr = vm.computeCreate2Address(
      CREATE2_SALT, 
      hashInitCode(type(TribalToken).creationCode, abi.encode(wallet, wallet, endpoint))
    );

    if (expectedAddr.code.length > 0) {
      c.log("!!!! TribalToken already deployed at:", expectedAddr);
      revert();
    }

    c.log("TribalToken will be deployed at:", expectedAddr);

    vm.startBroadcast(wallet);

    TribalToken t = new TribalToken{salt: CREATE2_SALT}(wallet, wallet, endpoint);

    c.log("TribalToken deployed at:", address(t));
    
    vm.stopBroadcast();        
  }
}
