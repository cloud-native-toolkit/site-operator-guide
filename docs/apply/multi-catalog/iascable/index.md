# Multiple catalogs with IasCable

A core set of automation modules has been provided in the [module catalog](https://modules.cloudnativetoolkit.dev) that list public modules from a number of different sources. However, there are situations where additional catalogs are needed (e.g. private modules). With IasCable it is possible to define a Bill of Material with modules from multiple catalogs and generate the automation appropriately. There are two ways to specify the catalog(s) that should be used by IasCable:

- Annotation in the Bill of Material
- Argument passed on the command line

!!! note

    This information applies to IasCable v2.17.0 or higher

## Bill of Material annotation

The Bill of Material provides an annotation area within the "metadata" section. The annotations are used to provide additional information for processing Bill of Material. (The full list of annotations and labels can be found in the [Bill of Material reference](../../bill-of-material-reference/).) 

In this case, an optional `catalogUrls` annotation has been provided to define the list of catalogs in which BOM modules can be found. The value is a comma-separated list of urls (either file:// or http(s)://).

```yaml
apiVersion: cloud.ibm.com/v1alpha1
kind: BillOfMaterial
metadata:
  name: my-custom-modules
  annotations:
    path: test
    catalogUrls: https://mymodules.someproject.com/index.yaml,https://othermodules.someproject.com/index.yaml
spec:
  modules:
    - name: custom-module-1
    - name: custom-module-2
```

## Catalog URL argument

The `iascable build` command provides a `-c` argument to pass in the catalog url(s). This argument can be provided multiple times to apply multiple catalogs, with subsequent catalogs taking precedence over previous ones. If not provided, the build uses the main catalog by default - https://modules.cloudnativetoolkit.dev/index.yaml . 

!!! note

    Only the catalog urls provided will be used. If you would like to use a custom catalog in addition to the main catalog then the main catalog will need to be included via the `-c` argument.  

```shell
iascable build -c https://modules.cloudnativetoolkit.dev/index.yaml -c https://mymodules.someproject.com/index.yaml -i my-custom-modules.yaml
```
