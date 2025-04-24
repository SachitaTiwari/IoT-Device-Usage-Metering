// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title IoTDeviceMeter
 * @notice Logs cumulative usage of IoT devices and allows the owner (gateway) to manage records.
 */
contract IoTDeviceMeter {
    /* -------------------------------------------------------------------------- */
    /*                                   State                                   */
    /* -------------------------------------------------------------------------- */

    address public owner;

    struct DeviceUsage {
        uint128 totalUsage;   // tightly pack to save gas
        uint64  lastUpdated;  // fits until ~2255
    }

    mapping(address => DeviceUsage) private _usage;

    /* -------------------------------------------------------------------------- */
    /*                                   Events                                  */
    /* -------------------------------------------------------------------------- */

    event UsageLogged(address indexed device, uint128 amount, uint128 newTotal, uint64 timestamp);
    event UsageReset(address indexed device, uint64 timestamp);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /* -------------------------------------------------------------------------- */
    /*                                   Errors                                  */
    /* -------------------------------------------------------------------------- */

    error NotOwner();
    error InvalidInput();
    error ArrayLengthMismatch();

    /* -------------------------------------------------------------------------- */
    /*                                 Modifiers                                 */
    /* -------------------------------------------------------------------------- */

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    /* -------------------------------------------------------------------------- */
    /*                               Constructor                                 */
    /* -------------------------------------------------------------------------- */

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /* -------------------------------------------------------------------------- */
    /*                          Ownership management                              */
    /* -------------------------------------------------------------------------- */

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert InvalidInput();
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /* -------------------------------------------------------------------------- */
    /*                              Core functions                                */
    /* -------------------------------------------------------------------------- */

    /**
     * @dev Log usage for a single device.
     */
    function logUsage(address device, uint128 amount) external onlyOwner {
        if (device == address(0) || amount == 0) revert InvalidInput();
        DeviceUsage storage d = _usage[device];
        d.totalUsage += amount;
        d.lastUpdated = uint64(block.timestamp);
        emit UsageLogged(device, amount, d.totalUsage, d.lastUpdated);
    }

    /**
     * @dev Batch log usage for many devices in one tx.
     */
    function logUsageBatch(address[] calldata devices, uint128[] calldata amounts) external onlyOwner {
        uint256 len = devices.length;
        if (len != amounts.length) revert ArrayLengthMismatch();
        for (uint256 i; i < len; ++i) {
            address device = devices[i];
            uint128 amount = amounts[i];
            if (device == address(0) || amount == 0) revert InvalidInput();
            DeviceUsage storage d = _usage[device];
            d.totalUsage += amount;
            d.lastUpdated = uint64(block.timestamp);
            emit UsageLogged(device, amount, d.totalUsage, d.lastUpdated);
        }
    }

    /**
     * @dev Reset a device's counter to zero (e.g., start of billing cycle).
     */
    function resetUsage(address device) external onlyOwner {
        if (device == address(0)) revert InvalidInput();
        _usage[device].totalUsage = 0;
        _usage[device].lastUpdated = uint64(block.timestamp);
        emit UsageReset(device, uint64(block.timestamp));
    }

    /* -------------------------------------------------------------------------- */
    /*                               View helpers                                */
    /* -------------------------------------------------------------------------- */

    function getUsage(address device) external view returns (uint128 total, uint64 lastUpdated) {
        DeviceUsage storage d = _usage[device];
        return (d.totalUsage, d.lastUpdated);
    }

    function getUsages(address[] calldata devices) external view returns (uint128[] memory totals, uint64[] memory updated) {
        uint256 len = devices.length;
        totals = new uint128[](len);
        updated = new uint64[](len);
        for (uint256 i; i < len; ++i) {
            DeviceUsage storage d = _usage[devices[i]];
            totals[i] = d.totalUsage;
            updated[i] = d.lastUpdated;
        }
    }
}

