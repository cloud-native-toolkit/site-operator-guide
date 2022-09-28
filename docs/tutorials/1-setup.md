# Setup you environment

This tutorial will prepare your workstation or laptop to be able to deploy a Bill of Material or create a new module to extend the catalog of available modules.

## Prerequisites

The instructions below are written for a modern, up to date version of Linux, MacOS or Windows operating systems.

The ```curl``` utility is used in some of the instructions in this tutorial.  Most OS installations come with curl preinstalled, if not you should install curl before proceeding.

## Installing the environment

Select which environment you want to work with.  There is a discussion about these options in the [Getting Started](../getting-started/setup.md) section.

=== "Linux"

    1. Follow the [instructions to install the docker engine](https://docs.docker.com/engine/install/){target=_blamk} for your Linux distribution
    2. For convenience you may want to enable your Linux user to be able to run docker without using sudo.  If so, follow [these instructions](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user){target=_blank} to add your user to the docker group
    3. You may also want to enable docker to start at boot by following [these instructions](https://docs.docker.com/engine/install/linux-postinstall/#configure-docker-to-start-on-boot){target=_blank}

=== "MacOS"

    === "Docker"

        Docker Desktop can be installed directly from the [Docker website](https://www.docker.com/products/docker-desktop/){target=_blank}

    === "Multipass"

        1. Install from the [Multipass website](https://multipass.run/install){target=_blank}

        !!! warning
            After installation you need to give Multipass permission to access the local hard disk:

            Go to `System Preferences`, then go to `Security and Privacy`, and select the `Privacy` tab.  Scroll the list on the left and select "Full Disk Access" and allow access for `multipassd`.

        Once installed you need to prepare a virtual machine with the necessary tools installed.  To do this you need to:

        1. Open a Terminal window
        2. Navigate to a local directory you want to work in, using the `cd` command
        3. Download the virtual machine initialization file using command:
        
            ``` shell
            curl https://raw.githubusercontent.com/cloud-native-toolkit/sre-utilities/main/cloud-init/cli-tools.yaml --output cli-tools.yaml
            ```

        4. Launch the Multipass virtual machine with command:
        
            ``` shell
            multipass launch --name cli-tools --cloud-init ./cli-tools.yaml
            ```

            This will take several minutes to start the virtual machine
        5. mount your local filesystem for use within the virtual machine with the following command:

            ``` shell
            multipass mount $PWD cli-tools:/automation
            ```

        !!! Warning
            If you use a VPN solution such as Cisco Anywhere or TunnelBlick then you may find your multipass VM cannot access the internet.  This is due to the packet filter configuration (/etc/pf.conf) on MacOS.  You can use Multipass without running the VPN or try one of the following options:

            -   Follow [this article](https://medium.com/@balass/routing-multipass-vms-traffic-over-vpn-established-on-host-macos-c49e315b1e42){target=_blank} to configure your packet filter to allow multipass internet traffic when using the VPN
                - *if you are using an employer provided workstation or laptop you may need to verify these changes are acceptable with your company security officer*
            -   Remove Multipass from your system, if already installed, then perform the multipass install and setup with the VPN client running

=== "Windows"

    1. Follow [these instructions](https://ubuntu.com/tutorials/install-ubuntu-on-wsl2-on-windows-11-with-gui-support#1-overview){target=_blank} to install Windows Subsystem for Linux (WSL) and select the Ubuntu 22.04.1 LTS image from the store
    2. Open a Ubuntu terminal and follow [these instructions](https://docs.docker.com/engine/install/ubuntu/){target=_blank} to install Docker Engine within the WSL Ubuntu environment
    3. For convenience you may want to enable your ubuntu user to be able to run docker without using sudo.  If so, follow [these instructions](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user){target=_blank} to add your user to the docker group
    4. Enable docker to start at system boot by running the following command `sudo systemctl enable docker.service`
    5. Start docker with command `sudo service docker start`

    !!! Note
        All command line instructions on this site assume you are working in the WSL environment setup by the above instructions

## Install local tools

Install the following command line tools on your workstation or laptop:

-   oc - The OpenShift command line utility
-   iascable - the Toolkit command line utility to work with Bill of Materials

### Install oc

Follow the instructions in the [OpenShift documentation](https://docs.openshift.com/container-platform/4.11/cli_reference/openshift_cli/getting-started-cli.html){target=_blank} to install the **oc** cli.

### Install iascable

Iascable is a command line tool to work with Bill of Material files.  It can be installed or updated by running the following command:

``` shell
curl -sL https://iascable.cloudnativetoolkit.dev/install.sh | sh
```
