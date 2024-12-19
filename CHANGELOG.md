# Change log

All notable changes to this project will be documented in this file.

## 1.0.4 - 2023-12-15

### Added
   * First public version.
### Changed
### Fixed

## 1.0.5 - 2024-02-28
### Added
   * Added the ability to create a cluster as well as reference an existing one. The cluster it creates is a simple single zone cluster.
### Changed
   * Removed the validation of the GPU operator and RHODS operator pods and moved a summary of the pod status to the end. This is due to the fact that these pods sometimes take awhile to finish and there is no good way to wait for them as well as they may change.
### Fixed

## 1.1.0 - 2024-02-28
### Added
### Changed
   * Changed name to OpenShift AI
### Fixed

## 1.1.1 - 2024-03-01
### Added
### Changed
   * Reduced the number of input variables
### Fixed

## 1.1.2 - 2024-03-01
### Added
### Changed
### Fixed
   * Fixed some typos

## 1.1.3 - 2024-03-06
### Added
### Changed
### Fixed
   * Created choices lists for some input variables

## 1.1.4 - 2024-03-06
### Added
### Changed
### Fixed
   * Fix errors in variables

## 1.1.6 - 2024-03-13
### Added
### Changed
   * Change how ocp-version is done
### Fixed

## 1.1.7 - 2024-03-29
### Added
### Changed
   * Changed to create a new COS service instance if the user wants
### Fixed

## 2.0.1 - 2024-05-08
### Added
### Changed
   * Update to use ROKS base vpc ocp cluster module
### Fixed

## 3.0.0 - 2024-05-15
### Added
### Changed
   * Narrowed the DA to only create a new cluster. Only optional inputs are now the ability to re-use an existing COS instance or an existing resource group
### Fixed

## 3.0.1 - 2024-05-16
### Added
### Changed
### Fixed
  * Small bug fixes

## 3.0.2 - 2024-05-23
### Added
  * Added flavor features
### Changed
### Fixed
  * Fixed variable descriptions

## 3.0.3 - 2024-06-11
### Added
  * Added ability to specify new resource group and/or COS instance names
### Changed
### Fixed

## 3.0.4 - 2024-06-19
### Added
  * Added zone as a variable
### Changed
### Fixed

## 3.0.5 - 2024-06-28
### Added
### Changed
### Fixed
  * Removed API key variable to ocp_base module

## 3.0.6 - 2024-07-03
### Added
### Changed
  * Changed to fetch the cluster policy yaml
### Fixed

## 3.0.7 - 2024-07-24
### Added
### Changed
  * Created second worker pool to separate GPUs into their own
### Fixed

## 3.0.8 - 2024-07-26
### Added
### Changed
  * Utilize resource group and VPC modules
### Fixed

## 3.0.9 - 2024-07-26
### Added
### Changed
  * Added OCP 4.16, moved to RHCOS, and updated available GPU worker types
### Fixed

## 4.0.0 - 2024-12-19
### Added
  * Call the paid OpenShift AI add-on instead of installing the operators
### Changed
### Fixed