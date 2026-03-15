1. 讓Horizontal pod autoscaling(HPA)可以取得Google Cloud Managed Service for Prometheus的metrics:
   - [reference](https://cloud.google.com/stackdriver/docs/managed-prometheus/hpa#stackdriver-adapter)
   - 以下採用Google Cloud提供的[Custom Metrics Stackdriver Adapter](https://github.com/GoogleCloudPlatform/k8s-stackdriver/tree/master/custom-metrics-stackdriver-adapter)
   - 安裝Custom Metrics Stackdriver Adapter
   ```shell
   kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/k8s-stackdriver/master/custom-metrics-stackdriver-adapter/deploy/production/adapter_new_resource_model.yaml
   ```
   - 當Workload Identity Federation for GKE啟用時，需將Monitor Viewer權限授予給adapter所使用的service account
   ```shell
   # acquire PROJECT_NUMBER
   gcloud projects describe ${PROJECT_ID} --format 'get(projectNumber)'

   gcloud projects add-iam-policy-binding projects/${PROJECT_ID} \
    --role roles/monitoring.viewer \
    --member=principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${PROJECT_ID}.svc.id.goog/subject/ns/custom-metrics/sa/custom-metrics-stackdriver-adapter
   ```
2. 當Workload Identity Federation for GKE啟用時，如果gke裏的workload需要存取gcp上的服務(例如cloud storage, secret manager)，需建立該服務所使用的k8s service account與gcp service account的連結：
   - 視需要建立新的gcp service account (或沿用既有的)
    ```shell
    gcloud iam service-accounts create ${GCP_SA} \
      --project=${PROJECT_ID}
    ```
   - 將之後需要提供給gke workload使用的gcp服務權限先授權給gcp service account
    ```shell
    gcloud project add-iam-policy-binding ${PROJECT_ID} \
      --role="roles/${GCP_ROLE}"
      --member "serviceAccount:${GCP_SA}@${PROJECT_ID}.iam.gserviceaccount.com"
    
    # see existing roles
    gcloud projects get-iam-policy ${PROJECT_ID} \
    --flatten="bindings[].members" \
    --format="table(bindings.role)" \
    --filter="bindings.members:serviceAccount:${GCP_SA}@${PROJECT_ID}.iam.gserviceaccount.com"
    ```
   - 設定gcp service account與k8s service account的連結，讓k8s service account能夠以gcp service account的身份存取gcp的服務(impersonation)
    ```shell
    gcloud iam service-accounts add-iam-policy-binding \
      ${GCP_SA}@${PROJECT_ID}.iam.gserviceaccount.com \
      --role="roles/iam.workloadIdentityUser" \
      --member "serviceAccount:${PROJECT_ID}.svc.id.goog[${K8S_NAMESPACE}/${K8S_SA}]"

    # check all policy
    gcloud iam service-accounts get-iam-policy ${GCP_SA}@${PROJECT_ID}.iam.gserviceaccount.com 
    ```
   - 將k8s service account加上annotation，讓gke使用impersonation
    ```shell
    kubectl annotate serviceaccount ${K8S_SA} \
    --namespace ${K8S_NAMESPACE} \
    iam.gke.io/gcp-service-account=${GCP_SA}@${PROJECT_ID}.iam.gserviceaccount.com
    ```
   - 以下服務需依前述方式建立k8s service account與gcp service account連結
     - external-secrets (secret manager permission: roles/secretmanager.secretAccessor)
     - cert-manager (Cloud DNS permissions: roles/dns.admin)
     - opentelemetry-operator (monitoring, logging, trace permissions for collector: roles/monitoring.metricWriter, roles/logging.logWriter, roles/cloudtrace.agent)
     - wormhole workloads (google cloud storage permission: roles/storage.objectUser)