1. [enable workload identity for cluster, and enable GKE Metadata Server for node pools](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity#console)

2. create the GCP service account:
```
gcloud iam service-accounts create ${GCP_SA} \
  --project=${PROJECT_ID}
```

3. grant the GCP service account access to all secrets in a GCP project:
```
gcloud project add-iam-policy-binding ${PROJECT_ID} \
  --role="roles/secretmanager.secretAccessor"
  --member "serviceAccount:${GCP_SA}@${PROJECT_ID}.iam.gserviceaccount.com"
```

4. install external-secrets:
```
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets \
  --namespace external-secrets --create-namespace
```

This creates a Kubernetes service account external-secrets in the external-secrets namespace, which is used by the Core Controller Pod.

5. annotate external-secrets Kubernetes service account with an annotation that references the GCP service account:
```
kubectl annotate serviceaccount external-secrets \
    --namespace external-secrets \
    iam.gke.io/gcp-service-account=${GCP_SA}@${PROJECT_ID}.iam.gserviceaccount.com
```

6. Grant the Kubernetes service account the iam.workloadIdentityUser role on the GCP service account:
```
gcloud iam service-accounts add-iam-policy-binding \
  ${GCP_SA}@${PROJECT_ID}.iam.gserviceaccount.com \
  --role="roles/iam.workloadIdentityUser" \
  --member "serviceAccount:${PROJECT_ID}.svc.id.goog[${K8S_NAMESPACE}/${K8S_SA}]"
```

7. create cluster secret store or namespace-scoped secret store
```
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: some-secret-store-in-gcp
spec:
  provider:
    gcpsm:
      projectID: ${PROJECT_ID}
```

Reference:
 - [External Secrets Operator integrates with the Google Cloud Secret Manager](https://external-secrets.io/latest/provider/google-secrets-manager/)
 - [Authenticate to Google Cloud APIs from GKE workloads(link Kubernetes ServiceAccounts to IAM)](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity#kubernetes-sa-to-iam)