# Concepts

!!! Todo
    Complete this section.  Topics should include:

    -   Overview
    -   Cloud environments
    -   Infrastructure as code
    -   Modular and layered composition
    -   Hybrid platform (OpenShift and Kubernetes)
    -   Operators
    -   Solution lifecycle
    -   CI/CD
    -   GitOps (including app of apps pattern)
    -   Helm (including chart dependencies)

    -   Toolkit concepts
        -   Modules
        -   Bill of Materials (BOM)
            -   dependencies
            -   configuration / variables

In the simplest terms, the Toolkit delivers a set of packaged blocks of automation, called modules, that can be composed into a template, called a Bill of Materials, that describes a desired computing environment. The Bill of Materials can then be built and deployed to generate and run the automation code to create the desired computing environment.

This section will explore some of the concepts behind how the toolkit works and the environments generated by some of the modules in the public [modules catalog](https://modules.cloudnativetoolkit.dev){target=_blank}.