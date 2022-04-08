Health To Go Infra
=========
This repository is capable of deploying a new AWS EKS cluster and deleting it right after using Terraform.  

Getting Started & Documentation
-------------------------------
When running Terraform locally, it is important to have [tfenv](https://github.com/tfutils/tfenv). This tool works for terraform like pyenv works for python. It allows you to have multiple different terraform environments using different terraform version. Follow the README from [tfenv](https://github.com/tfutils/tfenv) to install it for your respective OS.  

After installing [tfenv](https://github.com/tfutils/tfenv) and having the PATH properly configured, run `tfenv install`. It looks for the **.terraform-version** file.  

Now you should have terraform available, you can test this by running `terraform --version`.  

Projects and Modules
-------------------------------
This repository, for the time beeing, has the projects: **eks** and **kubeconfig**. You can identify it by the folders name. For the time beeing, it also has **eks** and **k8s** modules within the **modules** folder.  

Never run terraform within the **modules** folder. It is intended to be run inside each project individually, but not inside **modules**. The modules will be used by the projects when you run terraform within the projects. Also, run **eks** project always before **kubeconfig**, the **kubeconfig** needs the cluster to be existent.  

The Steps
-------------------------------
1. First run `terraform init`, and `terraform workspace list` inside eks folder. This command will display all the workspaces existent. You must create a new workspace if you wish to create a new cluster. `terraform workspace new <WORKSPACE_NAME>`. The workspace name will be used by terraform as prefix for the cluster name.  

2. After setting the workspace, run `terraform plan`. This will simulate what terraform would do in a real `terraform apply` as a safety measurement.  

3. Later, run `terraform apply` **(MAKE SURE YOU VALIDATED THE RESULTS OF THIS ACTION WITH `terraform plan`)**, it will generate all the resources necessary to run an EKS cluster. When you create an Amazon EKS cluster, the IAM entity user or role, such as a federated user that creates the cluster, is automatically granted system:masters permissions in the cluster's RBAC configuration in the control plane. This IAM entity doesn't appear in the ConfigMap, or any other visible configuration, so make sure to keep track of which IAM entity originally created the cluster.  

You will need the endpoint, certificate, and cluster name generated by EKS in order to use kubectl (This is not necessary now). You can extract this information in the AWS Console by accessing your recently created EKS or you can also access this data programatically using the EKS module output from this repository.  

The kubeconfig yaml follows. Please replace ENDPOINT, CERTIFICATE-AUTHORITY-DATA, and CLUSTER-NAME  
```yaml
apiVersion: v1
clusters:
- cluster:
    server: <ENDPOINT>
    certificate-authority-data: <CERTIFICATE-AUTHORITY-DATA>
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "<CLUSTER-NAME>"
```
4. On the **kubeconfig** folder run `terraform init` and `terraform workspace list`. You must also create a workspace for it and use the **SAME EXACT NAME** you have given the **eks** project.

5. You will need to run `terraform import module.k8s.kubernetes_config_map.aws-auth kube-system/aws-auth` to import the aws-auth into your terraform state.  

6. Finally run `terrafom plan` and `terraform apply` **(PLEASE SEE THE WARNINGS AND RECOMMENDATIONS ABOVE IF YOU HAVEN'T ALREADY)**.  