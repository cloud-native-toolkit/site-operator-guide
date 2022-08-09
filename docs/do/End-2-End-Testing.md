# End To End Testing for any software module

Turbonomic Repo - https://github.com/IBM/automation-turbonomic


Follow the steps to implement the end-to-end testing for Turbonomic / CP4I


(1)  Copy the .github to the IBM Github which will trigger the Action/Test in the IBM Github Repo where software module to be tested.
```
    - workflows
       - verify-pr.yaml
       - verify-schedule.yaml
       - verify-workflow.yaml
       - verify.yaml
   - release-drafter.yaml 
```

 (2) Add the end to end test logic in the verify-pr.yaml of the Software module to be tested
  
  ```
   Strategy: 
      matrix:
        flavor:
          - quickstart
        storage:
           - odf
           - portworx 
   ```

(3) Add environment variables needed for this module in the verify-pr.yaml
```
    env:
         Home: 
         IBMCloud_API_Key
```

(4) Steps represents a sequence of tasks that will be executed as part of job
  - Add the steps which needs to be executed in the sequence 
  
(5) Modify the 200-openshift-gitops BOM to support Gitea
  - Make sure generated main.tf is referrencing the Gitea variables inside Gitops Module in the main.tf

```
  module "gitops_repo" {
  source = "github.com/cloud-native-toolkit/terraform-tools-gitops?ref=v1.21.0"
  branch = var.gitops_repo_branch
  debug = var.debug
  gitea_host = module.gitea.host
  gitea_org = module.gitea.org
  gitea_token = module.gitea.token
  gitea_username = module.gitea.username
  ——
  }
```

(6) Trigger the module build which will kick off the end-to-end test for the software to be tested.
     - Watch the Github Actions TAB 
