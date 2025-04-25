mapping(address => bool) private _registeredDevices;

event DeviceRegistered(address indexed device);
event DeviceDeregistered(address indexed device);

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

modifier onlyRegistered(address device) {
    if (!_registeredDevices[device]) revert InvalidInput();
    _;
}


