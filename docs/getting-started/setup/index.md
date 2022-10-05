# Setup you learning and development environment

The automation used within the toolkit uses a number of open source tools and utilities.  To avoid issues with different operating systems, command line interpreters (shells) and versions of the various tools, it is recommended that a container or virtual machine is used, so you will have a verified working environment for the automation to run in.

Some of the tools used are:

-   [`terraform`](https://www.terraform.io){target=_blank}
-   [`terragrunt`](https://terragrunt.gruntwork.io){target=_blank}
-   [`git`](https://git-scm.com){target=_blank}
-   [`jq`](https://stedolan.github.io/jq/){target=_blank}
-   [`yq`](https://mikefarah.gitbook.io/yq/){target=_blank}
-   [`oc`](https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/getting-started-cli.html){target=_blank}
-   [`kubectl`](https://kubernetes.io/docs/tasks/tools/#kubectl){target=_blank}
-   [`helm`](https://helm.sh){target=_blank}
-   [`ibmcloud cli`](https://www.ibm.com/cloud/cli){target=_blank}

!!! Todo
    what about other cloud CLIs?

## Supported runtime environments

The developers do not have the bandwidth to run and test will all possible combinations of runtimes across different operating systems, so these are the recommended, tested OS/runtime environments:

=== "Linux"

    -   [Docker Engine](https://docs.docker.com/engine/){target=_blank}

=== "Mac OS"

    -   [Docker Desktop](https://www.docker.com/products/docker-desktop/){target=_blank}
    -   [Multipass](https://multipass.run){target=_blank}

=== "Windows"

    -   [Windows Subsystem for Linux](){target=_blank} running Ubuntu 22.04.1 LTS image with [Docker Engine](https://docs.docker.com/engine/){target=_blank} installed

### Docker

Docker Desktop provides a container environment for MacOS.  It is free to use for non-commercial uses, but requires a license for commercial use.

If the license isn't an issue then this is the simplest, recommended option to use.

If running on Linux or Windows Subsystem for Linux, then [docker engine](https://docs.docker.com/engine/){target=_blank} is the recommended option to use.

### Multipass

Multipass is a free virtual machine environment for Windows, MacOS and Linux to run Ubuntu images.  Only Multipass on MacOS is supported within this documentation.

!!! Warning
    Some users have reported DNS resolution issues when using Multipass with some VPN clients, such as Cisco Anywhere.  There are workaround solutions covered in the setup tutorial.

### Additional unsupported options

There are some additional environments that are used within the community, but these are not supported and cannot be guaranteed to work.  There are also some known issues with the environments listed below:

-   [podman](https://podman.io){target=_blank}
-   [colima](https://github.com/abiosoft/colima){target=_blank}

#### Podman

Podman is an open source tool, free to use, that provides much the same functionality as Docker Desktop.  There are some known issues with Podman:

-   When resuming from suspend, if the podman machine is left running, it will not automatically synchronize to the host clock. This will cause the podman machine to lose time. Either stop/restart the podman machine or define an alias like this in your startup scripts:

    ```shell
    alias fpt="podman machine ssh \"sudo chronyc -m 'burst 4/4' makestep; date -u\""
    ```

    then fix podman time with the `fpt` command.

-   There is currently an QEMU bug which prevents binary files that should be executable by the podman machine vm from operating from inside a mounted volume path. This is most common when using the host automation directory, vs a container volume like `/workspaces` for running the automation. Generally the cli-tools image will have any binary needed and the `utils-cli` module will symbolically link, vs. download a new binary into this path. However there can be drift between binaries in `cli-tools` image used by `launch.sh` and those requested to the `utils-cli` module.

#### Colima

Colima is an open source container engine for Intel or Arm based Mac systems.  It is free to use, but there are some known issues with Colima:

-   Network/DNS failures under load
-   Read/write permissions to local storage volumes
-   Issues running binary executables from volumes mounted from the host

## Setup instructions

Instructions for setting up your chosen container or VM environment are covered in the first [tutorial](../../tutorials/1-setup/)
