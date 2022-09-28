# Bill of Material Reference

!!! Todo
    Complete this reference section

    -   check the content as moved from previous documentation structure.

# Bill of Material reference

The Bill Of Materials (BOM) yaml has been modeled after a Kubernetes Custom Resource Definition. It is used to define the modules from the module catalog that should be included in the generated terraform template. As appropriate the Bill of Materials can also be used to define the relationships between the modules and the default variables that should be supplied to the modules for the architecture.

The terraform template is generated from the BOM using the `iascable build` command. The build process relies on metadata for each of the modules stored in the module catalog to understand each module's dependencies and the relationships between the different modules. By default, the module entries for the Bill of Material are pulled from the Cloud Native Toolkit module catalog - https://modules.cloudnativetoolkit.dev/

## BOM metadata

The first part of the BOM defines the name and other descriptive information about the terraform that will be generated.

```yaml
apiVersion: cloudnativetoolkit.dev/v1alpha1
kind: BillOfMaterial
metadata:
  name: 100-shared-services
  labels:
    platform: ibm
    code: '100'
  annotations:
    displayName: Shared Services
    description: Provisions a set of shared services in the IBM Cloud account
```

**Note:** The `labels` and `annotations` sections can contain any number of values. The common values are shown in the example.

| Field                                 | Description                                                                            |
|---------------------------------------|----------------------------------------------------------------------------------------|
| **apiVersion**                        | the schema version of the BOM (always `cloudnativetoolkit.dev/v1alpha1` at the moment) |
| **kind**                              | the kind of resource (always `BillOfMaterial` for a BOM)                               |
| **name**                              | the name of the architecture that will be built                                        |
| **platform** label                    | the cloud platform targeted by the architecture                                        |
| **code** label                        | the code used to index the BOM                                                         |
| **displayName** annotation            | the user-friendly display name for the BOM                                             |
| **description** annotation            | the description of the provisioned architecture                                        |
| **path** annotation                   | the sub-path that should be appended to the output (e.g. {output}/{path}/{name}        |
| **catalogUrls** annotation            | comma-separated list of urls for the catalogs containing the BOM modules               |
| **deployment-type/gitops** annotation | flag indicating the BOM describes gitops modules                                       |
| **vpn/required** annotation           | flag indicating a VPN connection is required before applying the terraform             |

## BOM spec

The meat of the BOM is defined in the **spec** block. The **spec** can contain the following top level elements:

- **modules** - an array of Bill of Material module definitions
- **variables** - (optional) an array of Bill of Material variables used to define the global variables in the terraform template
- **providers** - (optional) an array of terraform provider configurations

### BOM module definition

A BOM module is used to define a module that should be added to the generated terraform template. At a minimum, the BOM Module must define `name` of the module from the module catalog. Optionally, the module can also define an `alias` that will be used for the module identifier in the generated terraform and will also be used as the identifier when defining dependencies between modules.

#### BOM Module dependencies

If the module depends on other modules, the relationships can be defined in the `dependencies` block. However, in most cases it is not necessary to explicitly define the dependencies. Through the module metadata, the `iascable` tool knows the required dependencies for each module and can "auto-wire" the modules together. If necessary, `iascable` will automatically add modules to the BOM if they are required to satisfy a required module dependency.

If there are multiple instances of a dependent module defined in the BOM then `iascable` will "auto-wire" the dependency to the "default" dependent module. The "default" dependent module is the one that uses the default alias name OR has the `default: true` attribute added to it. If a default cannot be identified then ANOTHER instance of the module will be automatically added to the BOM. If this behavior is not desired then the desired dependent module can be referenced in the `dependencies` block.

For example:

```yaml
spec:
  modules:
  - name: ibm-vpc
  - name: ibm-vpc-subnets
    alias: edge_subnets
  - name: ibm-vpc-subnets
    alias: cluster_subnets
  - name: ibm-vpc-subnets
    alias: vpe_subnets
  - name: ibm-vpc-ocp
```

The `ibm-vpc-subnets` module depends on `ibm-vpc`. An explicit declaration of the dependency is not required here though because the `ibm-vpc` module is the default instance and all of the `ibm-vpc-subnets` are auto-wired to that instance. (In fact the `ibm-vpc` module doesn't even need to be explicitly listed in the BOM in this case, but it is added for completeness.) The `ibm-vpc-ocp` module depends on `ibm-vpc-subnets` to identify where the cluster should be deployed. In this configuration, a default `ibm-vpc-subnets` instance has not been defined. As a result, `iascable` will automatically pull in 4th `ibm-vpc-subnets` instance to satisfy the dependency. This is probably not the desired result and we will want to explicitly define the dependency in the BOM. The updated BOM would look like the following:

```yaml
spec:
  modules:
  - name: ibm-vpc
  - name: ibm-vpc-subnets
    alias: edge_subnets
  - name: ibm-vpc-subnets
    alias: cluster_subnets
  - name: ibm-vpc-subnets
    alias: vpe_subnets
  - name: ibm-vpc-ocp
    dependencies:
      - id: subnets
        ref: cluster_subnets
```

The `subnets` identifier in the dependencies array refers to the dependency identifier in the module metadata for the `ibm-vpc-ocp` module. The `cluster_subnets` value refers to the alias of the target `ibm-vpc-subnets` module instance.

**Note:** The only exception to `iascable` automatically pulling dependent modules into the BOM is if there are multiple module options that satisfy the dependency. In this case one of the modules that satisfies dependency must be explicitly added to the BOM. Otherwise the `iascable build` command will give an error that the dependency cannot be resolved.

!!! Todo
    Should there be an example to show the use of the default flag?

#### BOM Module variables

The Bill of Materials also allows the module variables to be configured in a `variables` block. The `variables` block is an array of variable definitions. At a minimum the variable `name` must be provided. The available variable names are defined in the module metadata. For each variable, the following values can be provided:

| Field     | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
|-----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **value** | The default value of the variable. This value will override the default in the module.                                                                                                                                                                                                                                                                                                                                                                                           |
| **scope** | The scope of the variable that defines how the variable will be handled in the global variable namespace. Allowed values are `global` or `module`. If the value is `global` the variable will be added as-is to the global namespace. If the value is `module` then the variable name will be prefixed with the module alias (e.g. the `flavor` variable in the `cluster` module would be named `cluster_flavor` with `module` scope and `flavor` with `global` scope).          |
| **alias** | The alias name that should be given to the variable in the global variable namespace. This alias works in conjunction with the `scope` value. For example, if the `name` variable is set to `global` scope and `alias` of `my_name` then a variable named `my_name` will be added to the global variable namespace and the generated module terraform will map the `my_name` global variable to the `name` module variable (`name = var.my_name`)                                |
| **important** | Flag that indicates the variable should be presented to the user in the generated `*.auto.tfvars` file even though it has a default value. By default, only required fields (i.e. fields that don't have a default value) are presented to the user. Selectively, other variables can be exposed using this flag for significant configuration values. The objective is to balance flexibility of configuration options with the simplicity of a small number of required inputs |

**Note:** The module metadata defines how the outputs from the dependent modules should be wired into a module's input variables. It is not necessary to define any of the "wired" variables in the BOM.

### Example Bill of Material

```yaml
apiVersion: cloudnativetoolkit.dev/v1alpha1
kind: BillOfMaterial
metadata:
  name: 130-management-vpc-openshift
  labels:
    type: infrastructure
    platform: ibm
    code: '130'
  annotations:
    displayName: Management VPC OpenShift
    description: Management VPC and Red Hat OpenShift servers
spec:
  modules:
    - name: ibm-resource-group
      alias: kms_resource_group
      variables:
        - name: provision
          value: false
    - name: ibm-resource-group
      alias: at_resource_group
      variables:
        - name: provision
          value: false
    - name: ibm-kms
      alias: kms
      variables:
        - name: provision
          value: false
        - name: region
          alias: kms_region
        - name: name_prefix
          alias: kms_name_prefix
          scope: global
          value: ""
      dependencies:
        - name: resource_group
          ref: kms_resource_group
    - name: ibm-resource-group
      variables:
        - name: resource_group_name
          alias: mgmt_resource_group_name
          scope: global
        - name: provision
          alias: mgmt_resource_group_provision
          scope: global
    - name: ibm-access-group
    - name: ibm-vpc
      variables:
        - name: address_prefix_count
          value: 3
        - name: address_prefixes
          value:
            - 10.10.0.0/18
            - 10.20.0.0/18
            - 10.30.0.0/18
    - name: ibm-flow-logs
      dependencies:
        - name: target
          ref: ibm-vpc
        - name: cos_bucket
          ref: flow_log_bucket
    - name: ibm-vpc-gateways
    - name: ibm-vpc-subnets
      alias: worker-subnets
      variables:
        - name: _count
          alias: mgmt_worker_subnet_count
          scope: global
          value: 3
        - name: label
          value: worker
        - name: ipv4_cidr_blocks
          value:
            - 10.10.10.0/24
            - 10.20.10.0/24
            - 10.30.10.0/24
      dependencies:
        - name: gateways
          ref: ibm-vpc-gateways
    - name: ibm-ocp-vpc
      alias: cluster
      variables:
        - name: disable_public_endpoint
          value: true
        - name: kms_enabled
          value: true
        - name: worker_count
          alias: mgmt_worker_count
        - name: ocp_version
          value: 4.8
      dependencies:
        - name: subnets
          ref: worker-subnets
        - name: kms_key
          ref: kms_key
    - name: ibm-vpc-subnets
      alias: vpe-subnets
      variables:
        - name: _count
          value: 3
        - name: label
          value: vpe
        - name: ipv4_cidr_blocks
          value:
            - 10.10.20.0/24
            - 10.20.20.0/24
            - 10.30.20.0/24
    - name: ibm-vpc-subnets
      alias: ingress-subnets
      variables:
        - name: _count
          value: 3
        - name: label
          value: ingress
        - name: ipv4_cidr_blocks
          value:
            - 10.10.30.0/24
            - 10.20.30.0/24
            - 10.30.30.0/24
    - name: ibm-vpc-vpn-gateway
      dependencies:
        - name: subnets
          ref: vpn-subnets
    - name: ibm-resource-group
      alias: cs_resource_group
      variables:
        - name: provision
          value: false
    - name: ibm-object-storage
      alias: cos
      variables:
        - name: provision
          value: false
        - name: name_prefix
          alias: cs_name_prefix
          scope: global
      dependencies:
        - name: resource_group
          ref: cs_resource_group
    - name: ibm-kms-key
      variables:
        - name: provision
          value: true
      dependencies:
        - name: kms
          ref: kms
    - name: ibm-activity-tracker
      variables:
        - name: provision
          value: false
      dependencies:
        - name: resource_group
          ref: at_resource_group
    - name: ibm-object-storage-bucket
      alias: flow_log_bucket
      variables:
        - name: label
          value: flow-logs
        - name: allowed_ip
          value:
            - 0.0.0.0/0
    - name: ibm-vpe-gateway
      alias: vpe-cos
      dependencies:
        - name: resource
          ref: cos
        - name: subnets
          ref: vpe-subnets
        - name: sync
          ref: cluster
    - name: ibm-transit-gateway
      variables:
        - name: provision
          value: false
        - name: name_prefix
          alias: cs_name_prefix
          scope: global
      dependencies:
        - name: resource-group
          ref: cs_resource_group
    - name: logdna
      variables:
        - name: provision
          value: false
        - name: name_prefix
          alias: cs_name_prefix
          scope: global
      dependencies:
        - name: resource_group
          ref: cs_resource_group
    - name: sysdig
      variables:
        - name: provision
          value: false
        - name: name_prefix
          alias: cs_name_prefix
          scope: global
      dependencies:
        - name: resource_group
          ref: cs_resource_group
    - name: ibm-logdna-bind
    - name: sysdig-bind
  variables:
    - name: mgmt_resource_group_name
    - name: mgmt_resource_group_provision
    - name: region
    - name: ibmcloud_api_key
    - name: name_prefix
      alias: mgmt_name_prefix
      required: true
    - name: cs_resource_group_name
    - name: cs_name_prefix
    - name: worker_count
    - name: kms_service
```
