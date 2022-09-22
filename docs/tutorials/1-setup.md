# Setup you environment

This tutorial will prepare your workstation or laptop to be able to deploy a Bill of Material or create a new module to extend the catalog of available modules.

## Installing the environment

!!! Note
    the ```curl``` utility is used in some of the instructions in this tutorial.  Most OS installations come with curl preinstalled, if not you should install curl before proceeding.

Select which environment you want to work with.  There is a discussion about these options in the [Getting Started](../getting-started/setup.md) section.

=== "Docker"

    Docker Desktop can be installed directly from the [Docker website](https://www.docker.com/products/docker-desktop/){target=_blank}

=== "Multipass"

    Multipass can be installed from the [Multipass website](https://multipass.run/install){target=_blank}

    !!! warning "MacOS users"
        After installation MacOS users need to give Multipass permission to access their local hard disk:

        Go to `System Preferences`, then go to `Security and Privacy`, and select the `Privacy` tab.  Scroll the list on the left and select "Full Disk Access" and allow access for `multipassd`.

    Once installed you need to prepare a virtual machine with the necessary tools installed.  To do this you need to:

    1. Open a command line window (on Windows you should work in a [Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/about){target=_blank} shell).  
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

=== "unsupported-Podman"

    !!!Todo
        Podman instructions here
    
    !!! Warning
        This is an unsupported environment.  You may encounter issues using this environment and the developers may choose not to fix any issues identified

=== "unsupported-Colima"

    !!! Warning
        This is an unsupported environment.  You may encounter issues using this environment and the developers may choose not to fix any issues identified

    Colima can be installed using one of the following package management tools.  [Homebrew](https://brew.sh/){target=_blank}, [Macports](https://www.macports.org){target=_blank} or [Nix](https://nixos.org/download.html#nix-install-macos){target=_blank}

    -   Homebrew

        ``` shell
        brew install colima docker
        ```

    -   MacPorts

        ``` shell
        sudo port install colima
        ```

    -   Nix
        ``` shell
        nix-env -iA nixpkgs.colima
        ```

    Additional installation can be found on the [colima github repository](https://github.com/abiosoft/colima#installation){target=_blank}
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
