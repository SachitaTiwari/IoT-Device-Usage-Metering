// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IoTDeviceMeter {
    address public owner;

    struct DeviceUsage {
        uint256 totalUsage;
        uint256 lastUpdated;
    }

    mapping(address => DeviceUsage) public deviceUsage;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Called by IoT gateway or device to log usage
    function logUsage(address device, uint256 usageAmount) public onlyOwner {
        deviceUsage[device].totalUsage += usageAmount;
        deviceUsage[device].lastUpdated = block.timestamp;
    }

    // Returns usage details of a specific device
    function getUsage(address device) public view returns (uint256, uint256) {
        DeviceUsage memory usage = deviceUsage[device];
        return (usage.totalUsage, usage.lastUpdated);
    }
}

