# Description

This folder contains functions and other files used by the solution.  

# Execution Time
    
Helpers.psm1 is read in during the initiate

# Helper Functions

## Invoke-TestFailure

Supplied by Pester.  Used to break following the completion of a describe block if test failures have been detected.

## Get-DCBClusterNodes

Used by the configuration files to return node names.  The user can supply a one or more cluster names for simplicity in the configuration file and this function will return a comma separated list of node names included in those cluster(s).

## Drivers (Hashtable)

This is an updatable hashtable that includes the recommended driver for common IHVs.