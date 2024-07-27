// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

//import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;
    mapping(address => uint256) public balances;

    uint256 public constant threshold = 1 ether;
    uint256 public deadline = block.timestamp + 72 hours;
    bool public openForWithdraw;

    event Stake(address funder, uint256 amount);

    modifier canWithdraw() {
        require(
            openForWithdraw,
            //            block.timestamp >= deadline &&
            //            address(this).balance < threshold
            "Not ready for withdraw"
        );
        _;
    }
    modifier notCompleted() {
        require(
            !exampleExternalContract.completed(),
            "External contract completed"
        );
        _;
    }

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
    function stake() public payable {
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
    function execute() external notCompleted {
        if (block.timestamp >= deadline) {
            if (address(this).balance >= threshold) {
                uint256 contractBalance = address(this).balance;
                exampleExternalContract.complete{value: contractBalance}();
            } else openForWithdraw = true;
        }
    }

    // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
    function withdraw() external notCompleted canWithdraw {
        if (balances[msg.sender] > 0) {
            (bool success,) = msg.sender.call{value: balances[msg.sender]}(
                ""
            );
            if (!success) {
                /* ??? */
            }
        }
    }

    function isEligibleForTransfer()
    internal
    view
    returns (bool balanceCheck, bool deadlineCheck)
    {
        balanceCheck = address(this).balance >= threshold;
        deadlineCheck = block.timestamp >= deadline;
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        return (
            deadline > block.timestamp
                ? (deadline - block.timestamp)
                : uint256(0)
        );
    }

    // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable {
        stake();
    }
}
