# What's New in v2

## New Features

- GUI for creating the configuration!
  - Requires new param (LaunchUI) in the config file
- Added Deployment Option
  - Requires new params (deploy) in the config file (or selection in the UI)
  - Added new example file .\Examples\Deploy.ps1

## Testing Changes

- Added SMB Tests for:
  - SMB Multichannel
  - Disabling SMB Signing
  - Disabling SMB Encryption
  - Verifying SMB Server and Client Network Interfaces are RDMA capable

- Added test to verify IEEE Priority tags are maintain for vNIC traffic
- Added test deployment verification for Azure Automation requirements

- Incremented Recommended driver for Mellanox WinOF-2 adapters
- Modified example configurations to set cluster heartbeat policy to priority 7

## Structural Changes

- Separated driver requirements into their own file
- Separate Global and Modal test files for easier review of test code
