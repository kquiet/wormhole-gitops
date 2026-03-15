1. [install](/scripts/argocd/) via helm first

2. configure to access argocd through argocd cli
    ```
    argocd login <argocd_server>:<argocd_port>
    ```

3. add cluster
    ```
    kubectl config get-contexts -o name
    argocd cluster add gke_wormhole-proj-id_asia-east1_wormhole
    ```

4. add proj & configure project role for local account
    ```
    # update account password if needed
    argocd account update-password --account wormhole

    argocd proj create devops-dev --allow-cluster-resource=*/* --src=* --dest=*,* --source-namespaces=*

    argocd proj create wormhole-dev --allow-cluster-resource=*/PersistentVolume --src=* --dest=*,wormhole-dev --dest=*,test* --source-namespaces=wormhole-dev,test*
    argocd proj role create wormhole-dev admin --description "admin role"
    argocd proj role add-policy wormhole-dev admin -o "*" -a "*" -p allow
    argocd proj role add-group wormhole-dev admin wormhole

    argocd proj create wormhole-stage --allow-cluster-resource=*/PersistentVolume --src=* --dest=*,wormhole-stage --source-namespaces=wormhole-stage
    argocd proj role create wormhole-stage admin --description "admin role"
    argocd proj role add-policy wormhole-stage admin -o "*" -a "*" -p allow
    argocd proj role add-group wormhole-stage admin wormhole
    ```

5. add repo
    ```
    argocd repo add ssh://devops@192.168.100.2:443/opt/wormhole-gitops-repo --ssh-private-key-path <path_to_ssh_private_key> --insecure-ignore-host-key
    ```