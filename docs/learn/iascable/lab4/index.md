# Develop an own GitOps module

## 1. Objective

The objective is to understand how to build and use a custom module for the [`Technology Zone Accelerator Toolkit`](https://modules.cloudnativetoolkit.dev/).

Therefor a `custom module` will be created in GitOps scenario to deploy a helm-chart for an example application.

The `custom module`  will be deployed on a Red Hat OpenShift cluster on IBM Cloud with Argo CD configured for GitOps.

## 2. What does the repository do?

* This repository does `inspect` the [template-terraform-gitops](https://github.com/cloud-native-toolkit/template-terraform-gitops).

* The repository shows how to `create a custom module` for [`Technology Zone Accelerator Toolkit`](https://modules.cloudnativetoolkit.dev/) `step-by-step` using the [ubi-helm example](https://github.com/thomassuedbroecker/ubi-helm) from the Argo CD GitHub repository.

* The repository shows how to use a `custom module` in a [`BOM`(Bill of material)](https://github.com/cloud-native-toolkit/iascable#bom-spec)

* The repository shows how to create and use a `custom catalog` for a `custom module`

* The repository shows and inspects usage of a `custom module`  

### 2.1 Understand the [template-terraform-gitops](https://github.com/cloud-native-toolkit/template-terraform-gitops)

The [`template-terraform-gitops`](https://github.com/cloud-native-toolkit/template-terraform-gitops) is a part of the `How to` instructions of the [`Technology Zone Accelerator Toolkit`](https://modules.cloudnativetoolkit.dev/). 
The module covers the [GitOps topic](https://modules.cloudnativetoolkit.dev/#/how-to/gitops).

## 3. Use the [template-terraform-gitops](https://github.com/cloud-native-toolkit/template-terraform-gitops) to create a module to deploy the terraform-gitops-ubi example

These are the main tasks:

1. Create a GitHub repository based on the `gitops template` from `Software Everywhere`
2. Configure the `terraform-gitops-ubi` `module`
3. Create an own `catalog` for the `terraform-gitops-ubi` `module`
4. Create a [`BOM`(Bill of material)](https://github.com/cloud-native-toolkit/iascable#bom-spec) where the `terraform-gitops-ubi` `module` is used and create the needed terraform output with `iascable`

We will use later two catalogs and one `BOM` (Bill of material). here is a simplified view of the depencencies we will have later.

![](../../../imagesdevelop-own-module-11.png)

## 3.1 Perpare the environment

### 3.1.1 Create a new GitHub repository based on the `gitops template`

We clone the [`gitops template` repository](https://github.com/cloud-native-toolkit/template-terraform-gitops) to our local computer and we going to create our [`terraform-gitops-ubi`](https://github.com/Vishal-Ramani/terraform-gitops-ubi) repository.

#### Step 1: Clone the GitHub [`gitops template` repository](https://github.com/cloud-native-toolkit/template-terraform-gitops) to your local computer and create a new GitHub repository based on that template

You can follow the steps in the [blog post](https://wp.me/paelj4-1yf) to do this.

Then you should have following folderstructure on on computer:

```sh
├── LICENSE
├── README.md
├── main.tf
├── module.yaml
├── outputs.tf
├── scripts
│   └── create-yaml.sh
├── test
│   └── stages
│       ├── stage0.tf
│       ├── stage1-cert.tf
│       ├── stage1-cluster.tf
│       ├── stage1-cp-catalogs.tf
│       ├── stage1-gitops-bootstrap.tf
│       ├── stage1-gitops.tf
│       ├── stage1-namespace.tf
│       ├── stage2-mymodule.tf
│       ├── stage3-outputs.tf
│       └── variables.tf
├── variables.tf
└── version.tf
```

### 3.1.2 Install [`iascable`](https://github.com/cloud-native-toolkit/iascable)

We install  [`iascable`](https://github.com/cloud-native-toolkit/iascable) to ensure you use the lates version.

#### Step 1: Install [`iascable`](https://github.com/cloud-native-toolkit/iascable) on your local computer

```sh
curl -sL https://iascable.cloudnativetoolkit.dev/install.sh | sh
iascable --version
```

* Example output:

```sh
2.17.4
```

### 3.1.2 Install a [Multipass](https://multipass.run/) 

We will follow the instructions for [Multipass](https://github.com/cloud-native-toolkit/automation-solutions/blob/main/common-files/RUNTIMES.md#multipass). The following steps are an extractions of the [cloud-native-toolkit documentation](https://github.com/cloud-native-toolkit/automation-solutions/blob/main/common-files/RUNTIMES.md#multipas) with small changes when needed.

#### Step 1: Install [Multipass](https://multipass.run/) with brew 
```
brew install --cask multipass
```

### Step 2: Download [cloud-init](https://github.com/cloud-native-toolkit/sre-utilities/blob/main/cloud-init/cli-tools.yaml) configuration

```
curl https://raw.githubusercontent.com/cloud-native-toolkit/sre-utilities/main/cloud-init/cli-tools.yaml --output cli-tools.yaml
```

### Step 3: Start the virtual `cli-tools` machine

```
multipass launch --name cli-tools --cloud-init ./cli-tools.yaml
```

## 4. Implement the new `terraform-gitops-ubi` module 

In that section we will modify files in our newly created repository. These are the relevant files for our new module.

* The [`main.tf`](https://github.com/Vishal-Ramani/terraform-gitops-ubi/blob/main/main.tf) file
* The [`variable.tf`](https://github.com/Vishal-Ramani/terraform-gitops-ubi/blob/main/variables.tf) file
* The [`helm chart`](https://github.com/Vishal-Ramani/terraform-gitops-ubi/tree/main/chart/helm-ubi) content
* The [`module.yaml`](https://github.com/Vishal-Ramani/terraform-gitops-ubi/blob/main/module.yaml) file
* Configure the `helm chart` copy automation in the `scripts/create-yaml.sh` file
* Create for [`terraform-gitops-ubi` GitHub repository `tags` and `releases`](https://github.com/Vishal-Ramani/terraform-gitops-ubi/tags)

### 4.1 The [`main.tf`](https://github.com/Vishal-Ramani/terraform-gitops-ubi/blob/main/main.tf) file

#### Step 1:  Do some modifications in the `main.tf` file

* Change `name = "my-helm-chart-folder"` to `ubi-helm`

* First add `ubi-helm = {// create entry}` to the `values_content = {}`. That entry will be used to create the values for the variables in the `values.yaml` file for the helm chart.
  
  Below you see the relevant code in the `main.tf` which does the copy later. As you can is it uses the `{local.name}` value, so you need to ensure the name reflects the folder structure for your `helm-chart` later.

  ```sh
  resource null_resource create_yaml {
    provisioner "local-exec" {
      command = "${path.module}/scripts/create-yaml.sh '${local.name}' '${local.yaml_dir}'"
  
      environment = {
        VALUES_CONTENT = yamlencode(local.values_content)
      }
    }
  }
  ```

  These are the values we need to insert for our terraform-gitops-ubi application as variables for the helm-chart. You find the variables in the Argo CD github project for the ubi-helm [values.yaml](https://github.com/thomassuedbroecker/ubi-helm/blob/main/charts/ubi-helm/values.yaml)

  Now replace the `// create entry` with the needed values.

```sh
    ubi-helm = {
      "replicaCount": 1
      "image.repository" = "registry.access.redhat.com/ubi8/ubi"
    }
```
  
* Change `layer = "services"` to `layer = "applications"`

* Add `cluster_type = var.cluster_type == "kubernetes" ? "kubernetes" : "openshift"` to the `locals`

* Resulting `locals section` in the `main.tf` file

```json
locals {
  name          = "ubi-helm"
  bin_dir       = module.setup_clis.bin_dir
  yaml_dir      = "${path.cwd}/.tmp/${local.name}/chart/${local.name}"
  service_url   = "http://${local.name}.${var.namespace}"
  cluster_type = var.cluster_type == "kubernetes" ? "kubernetes" : "openshift"
  values_content = {
    ubi-helm= {
      "replicaCount": 1
      "image.repository" = "registry.access.redhat.com/ubi8/ubi"
      "image.tag" = "latest"
    }
  }
  layer = "applications"
  type  = "base"
  application_branch = "main"
  namespace = var.namespace
  layer_config = var.gitops_config[local.layer]
}
```

### 4.2 The [`variable.tf`](https://github.com/Vishal-Ramani/terraform-gitops-ubi/blob/main/variables.tf) file

#### Step 1: Add some variables in the [`variable.tf`](https://github.com/Vishal-Ramani/terraform-gitops-ubi/blob/main/variables.tf) file

```hcl
variable "cluster_type" {
  description = "The cluster type (openshift or kubernetes)"
  default     = "openshift"
}
```

### 4.3 The [`helm chart`](https://github.com/Vishal-Ramani/terraform-gitops-ubi/tree/main/chart/ubi-helm) content

#### Step 1: Create a new folder structure for the `terraform-gitops-ubi helm chart`

* Create following folder structure `chart/ubi-helm`.
  The name after chart must be the module name.

```sh
    ├── chart
    │   └── ubi-helm
    │       ├── Chart.yaml
    │       ├── charts
    │       │   └── ubi-helm
    │       │       ├── Chart.yaml
    │       │       ├── templates
    │       │       │   ├── _helpers.tpl
    │       │       │   └── deployment.yaml
    │       │       ├── ubi-helm-v0.0.01.tgz
    │       │       └── values.yaml
    │       └── values.yaml
```

That will be the resulting folder structure for the `terraform-gitops-ubi module` on your local pc:

```sh
├── LICENSE
├── README.md
├── chart
│   └── ubi-helm
│       ├── Chart.yaml
│       ├── charts
│       │   └── ubi-helm
│       │       ├── Chart.yaml
│       │       ├── templates
│       │       │   ├── _helpers.tpl
│       │       │   └── deployment.yaml
│       │       ├── ubi-helm-v0.0.1.tgz
│       │       └── values.yaml
│       └── values.yaml
├── main.tf
├── module.yaml
├── outputs.tf
├── scripts
│   └── create-yaml.sh
├── test
│   └── stages
│       ├── stage0.tf
│       ├── stage1-cert.tf
│       ├── stage1-cluster.tf
│       ├── stage1-cp-catalogs.tf
│       ├── stage1-gitops-bootstrap.tf
│       ├── stage1-gitops.tf
│       ├── stage1-namespace.tf
│       ├── stage2-mymodule.tf
│       ├── stage3-outputs.tf
│       └── variables.tf
├── variables.tf
└── version.tf
```


#### Step 2: Copy in newly create folderstructure the content from the repository for the `ubi-helm` chart [https://github.com/thomassuedbroecker/ubi-helm/tree/main/charts/ubi-helm](https://github.com/thomassuedbroecker/ubi-helm/tree/main/charts/ubi-helm)

#### Step 3: Validate the `helm chart` with following commands:

* Navigate the charts directory

```sh
CHARTDIR=./chart/ubi-helm/charts/ubi-helm
cd $CHARTDIR
```

* Verify the dependencies

```sh
helm dep update .
```

* Verify the helm chart structure

```sh
helm lint .
```

Example output:

```sh
==> Linting .
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
```

```sh
helm template test . -n test
```

Example output:

```sh
# Source: terraform-gitops-ubi/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-terraform-gitops-ubi
  labels:
    app: terraform-gitops-ubi
    chart: test-terraform-gitops-ubi
    release: test
    heritage: Helm
spec:
  replicas: 2
  revisionHistoryLimit: 3
  selector:
    matchLabels:
      app: terraform-gitops-ubi
      release: test
  template:
    metadata:
      labels:
        app: terraform-gitops-ubi
        release: test
    spec:
      containers:
        - name: terraform-gitops-ubi
          image: "registry.access.redhat.com/ubi8/ubi:latest"
          imagePullPolicy: Always
          args:
            - /bin/sh
            - -c
            - touch /tmp/healthy; sleep 30; rm -f /tmp/healthy; sleep 600
          livenessProbe:
            exec:
              command:
              - cat
              - /tmp/healthy
            initialDelaySeconds: 5
            periodSeconds: 5
```

```sh
helm package .
```

### 4.4 The [`module.yaml`](https://github.com/Vishal-Ramani/terraform-gitops-ubi/blob/main/module.yaml) file

#### Step 1: Edited the `module.yaml` 

* Use for `name`: `terraform-gitops-ubi`
* Use for `description`: `That module will add a new Argo CD config to deploy the terraform-gitops-ubi application`

```yaml
name: "terraform-gitops-ubi"
type: gitops
description: "That module will add a new Argo CD config to deploy the terraform-gitops-ubi application"
tags:
  - tools
  - gitops
versions:
  - platforms:
      - kubernetes
      - ocp3
      - ocp4
    dependencies:
      - id: gitops
        refs:
          - source: github.com/cloud-native-toolkit/terraform-tools-gitops.git
            version: ">= 1.1.0"
      - id: namespace
        refs:
          - source: github.com/cloud-native-toolkit/terraform-gitops-namespace.git
            version: ">= 1.0.0"
    variables:
      - name: gitops_config
        moduleRef:
          id: gitops
          output: gitops_config
      - name: git_credentials
        moduleRef:
          id: gitops
          output: git_credentials
      - name: server_name
        moduleRef:
          id: gitops
          output: server_name
      - name: namespace
        moduleRef:
          id: namespace
          output: name
      - name: kubeseal_cert
        moduleRef:
          id: gitops
          output: sealed_secrets_cert
```

### 4.5 Configure the `helm chart` copy automation in the `scripts/create-yaml.sh` file

#### Step 1: Configure the `scripts/create-yaml.sh` in `terraform-gitops-ubi` repository 

Replace the existing code in `scripts/create-yaml.sh` with following content. This is important for later when the `helm-chart` will be copied.

```sh
#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)
CHART_DIR=$(cd "${SCRIPT_DIR}/../chart/ubi-helm"; pwd -P)

NAME="$1"
DEST_DIR="$2"

## Add logic here to put the yaml resource content in DEST_DIR
mkdir -p "${DEST_DIR}"
cp -R "${CHART_DIR}/"* "${DEST_DIR}"

if [[ -n "${VALUES_CONTENT}" ]]; then
  echo "${VALUES_CONTENT}" > "${DEST_DIR}/values.yaml"
fi
find "${DEST_DIR}" -name "*"
echo "Files in output path"
ls -l "${DEST_DIR}"
```

### 4.6 [`terraform-gitops-ubi`](https://github.com/Vishal-Ramani/terraform-gitops-ubi/tags) GitHub repository `tags` and `releases` 

The release tag represents the version number of our module. [`terraform-gitops-ubi`](https://github.com/Vishal-Ramani/terraform-gitops-ubi)

#### Step 1: Create GitHub tag and release for the `terraform-gitops-ubi` GitHub repository

The module github repository `release tags` should be updated when you are going to change the [`terraform-gitops-ubi`](https://github.com/Vishal-Ramani/terraform-gitops-ubi) GitHub repository module. 

The image below shows some releases and as you can see for each release an archive is available. Later [`iascable`](https://github.com/cloud-native-toolkit/iascable) uses the `release tag` to download the right archive to the local computer to create the Terraform output.

![](../../../imagesdevelop-own-module-10.png)

In case when you use specific version numbers in the `BOM` which consums the module, you need to ensure that version number is also in range of the custom chart which points to the module. That is also relevant for the `catalog.yaml` we will define later.

Example relevant extract from a `BOM` -> `version: v0.0.5`

```yaml
    # Install terraform-gitops-ubi
    # New custom module linked be the custom catalog
    - name: terraform-gitops-ubi
      alias: terraform-gitops-ubi
      version: v0.0.5
```

You can follow the step to create a GitHub tag is that [example blog post](https://suedbroecker.net/2022/05/09/how-to-create-a-github-tag-for-your-last-commit/) and then create a release.

## 5. Create an own catalog

In that example we will not publish the our `terraform-gitops-ubi` module to the public catalog on [`Technology Zone Accelerator Toolkit`](https://modules.cloudnativetoolkit.dev/). 

We will create our own `catalog.yaml` file and save the configuration in the GitHub project of the module.

* How to create `catalog.yaml` file?
* How to combine various catalogs?
* Inspect the structure of a `catalog.yaml`
* Create a custom catalog steps

The following diagram shows the simplfied dependencies of `module`, `catalog` and `iascable`:

![](../../../imagesdevelop-own-module-11.png)


### 5.1 How to create `catalog.yaml` file?

  It is useful to take a look into [iascable documentation](https://github.com/cloud-native-toolkit/iascable) and the [build-catalog.sh automation](https://github.com/cloud-native-toolkit/software-everywhere/blob/main/.github/scripts/build-catalog.sh).

### 5.2 How to combine various catalogs?

  You can combine more than one `catalog resources` and `BOM inputs` with the `iascable build` command.

  Here is the build command:

  ```sh
  iascable build [-c {CATALOG_URL}] [-c {CATALOG_URL}] -i {BOM_INPUT} [-i {BOM_INPUT}] [-o {OUTPUT_DIR}]
  ```

  * `CATALOG_URL` is the url of the module catalog. The default module catalog is https://modules.cloudnativetoolkit.dev/index.yaml. Multiple module catalogs can be provided. The catalogs are combined, with the last one taking precedence in the case of duplicate modules.
  * `BOM_INPUT` is the input file containing the Bill of Material definition. Multiple BOM files can be provided at the same time.
  * `OUTPUT_DIR` is the directory where the output terraform template will be generated.

### 5.3 Inspect the structure of a `catalog.yaml`

  The structure of a catalog can be verified here
  [https://modules.cloudnativetoolkit.dev/index.yaml](https://modules.cloudnativetoolkit.dev/index.yaml)
  That is a minimize extraction of the `index.yaml` above. It contains: `categories`,`modules`,`aliases` and `providers`.

  ```yaml
  apiVersion: cloudnativetoolkit.dev/vlalphal
  kind: Catalog
  categories:
    - category: ai-ml
    - category: cluster
    - category: databases
    - category: dev-tool
    - category: gitops
      categoryName: GitOps
      selection: multiple
      modules:
        - cloudProvider: ""
          softwareProvider: ""
          type: gitops
          name: gitops-ocs-operator
          description: Module to populate a gitops repo with the resources to provision ocs-operator
          tags:
            - tools
            - gitops
          versions: []