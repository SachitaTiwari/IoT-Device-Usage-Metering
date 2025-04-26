// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DeviceRegistry {
    mapping(address => bool) private _registeredDevices;

    event DeviceRegistered(address indexed device);
    event DeviceDeregistered(address indexed device);

    address public owner;

    error InvalidInput();
    error NotOwner();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    modifier onlyRegistered(address device) {
        if (!_registeredDevices[device]) revert InvalidInput();
        _;
    }

    function registerDevice(address device) external onlyOwner {
        if (device == address(0)) revert InvalidInput();
        _registeredDevices[device] = true;
        emit DeviceRegistered(device);
    }

    function deregisterDevice(address device) external onlyOwner {
        if (!_registeredDevices[device]) revert InvalidInput();
        _registeredDevices[device] = false;
        emit DeviceDeregistered(device);
    }

    // 🆕



