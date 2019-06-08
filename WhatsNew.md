# What's New in v2.2

## New Features

- This feature branch is intended to
  - Move Validate-DCB into a PowerShell Gallery capable module
  - Integrate with the cluster health service
- Adding Build and Downloads badges
 
## Structural Changes

- Separated module prerequisites into its own Global unit test inside global.unit.tests.ps1
  - This will be run at the beginning of the initiate when the Launch or Deploy parameters are specified

