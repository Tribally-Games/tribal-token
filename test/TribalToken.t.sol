// SPDX-License-Identifier: GPLv3
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import { Vm } from "forge-std/Vm.sol";

import { TribalToken } from "../src/TribalToken.sol";
import { IERC20Errors } from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { LzDummyEndpoint } from "../src/LzDummyEndpoint.sol";

contract TribalTokenTest is Test {
    TribalToken public t;

    address owner1 = address(0x111);
    address owner2 = address(0x789);
    address minter1 = address(0x123);
    address minter2 = address(0x456);
    address user1 = address(0x1234);
    address user2 = address(0x12345);

    function setUp() public {
        t = new TribalToken(owner1, minter1, address(new LzDummyEndpoint()));
    }

    function test_Init() public view {
        assertEq(t.name(), "Tribal");
        assertEq(t.symbol(), "TRIBAL");
        assertEq(t.decimals(), 18);
        assertEq(t.totalSupply(), 0);
        assertEq(t.owner(), owner1);
        assertEq(t.minter(), minter1);
    }

    function test_ChangeOwner() public {
        // pass
        vm.prank(owner1);
        t.transferOwnership(owner2);
        assertEq(t.owner(), owner2);

        // not owner
        vm.prank(owner1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, owner1));
        t.transferOwnership(owner1);

        // invalid new owner
        vm.prank(owner2);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableInvalidOwner.selector, address(0)));
        t.transferOwnership(address(0));
    }

    function test_SetMinter() public {
        // unauthorized
        vm.prank(address(0x1234));
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, address(0x1234)));
        t.setMinter(minter2);

        // authorized
        vm.prank(owner1);
        t.setMinter(minter2);
        assertEq(t.minter(), minter2);

        // can set to null address
        vm.prank(owner1);
        t.setMinter(address(0));
        assertEq(t.minter(), address(0));

        // event emitted
        vm.recordLogs();

        vm.prank(owner1);
        t.setMinter(minter2);
        
        Vm.Log[] memory entries = vm.getRecordedLogs();

        assertEq(entries.length, 1, "Invalid entry count");
        assertEq(
            entries[0].topics[0],
            keccak256("MinterChanged(address)"),
            "Invalid event signature"
        );
        (address user) = abi.decode(entries[0].data, (address));  
        assertEq(user, minter2, "Invalid user");
    }

    function test_Transfer() public {
        vm.prank(minter1);
        t.mint(user1, 100);
        assertEq(t.totalSupply(), 100);
        assertEq(t.balanceOf(user1), 100);

        vm.prank(user1);
        t.transfer(user2, 50);
        assertEq(t.balanceOf(user1), 50);
        assertEq(t.balanceOf(user2), 50);   

        vm.prank(user2);
        t.approve(user1, 25);
        assertEq(t.allowance(user2, user1), 25);
        vm.prank(user1);
        t.transferFrom(user2, user1, 25);
        assertEq(t.allowance(user2, user1), 0);
        assertEq(t.balanceOf(user1), 75);
        assertEq(t.balanceOf(user2), 25);
    }

    function test_Mint() public {
        // unauthorized
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(TribalToken.UnauthorizedMinter.selector, user1));
        t.mint(user1, 100);

        // authorized
        vm.prank(minter1);
        t.mint(user1, 100);
        assertEq(t.totalSupply(), 100);
        assertEq(t.balanceOf(user1), 100);
    }

    function test_Burn() public {
        vm.prank(minter1);
        t.mint(user1, 100);

        // burn more than balance
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, user1, 100, 101));
        t.burn(101);

        // burn less than balance
        vm.prank(user1);
        t.burn(50);
        assertEq(t.totalSupply(), 50);
        assertEq(t.balanceOf(user1), 50);
    }
}
