# 如何在本地端使用gcloud cli建立與GKE cluster的連線設定?
   - 安裝gcloud cli及auth plugin；若以ldap帳密登入使用server02(192.168.23.168)環境，可不用安裝。

      ```shell
      # ubuntu環境可參考 https://cloud.google.com/sdk/docs/install#deb
      apt-get install google-cloud-cli google-cloud-cli-gke-gcloud-auth-plugin

      # windows環境請參考 https://cloud.google.com/sdk/docs/install#windows
      ```

   - 請向GKE Cluster的管理者確認您的GCP帳號有足夠的權限存取GKE Cluster(如果沒有的話，需請管理者授權給您的GCP帳號)
   - 初始化gcloud cli預設環境
     1. 使用Google使用者帳號進行身份驗證時:
        ```shell
        # 會跳出訊息要求登入，請記得在登入後跳過設定預設project及zone(改用手動設定)
        gcloud init --console-only
        
        # 手動設定預設project及region(zone不需要設定)
        # ${PROJECT_ID}, ${CLUSTER_REGION} 請依實際狀況代入
        gcloud config set project ${PROJECT_ID}
        gcloud config set compute/region ${CLUSTER_REGION}
        ```
     2. 使用GCP Service Account進行身份驗證時:
        ```shell
        # key-file 需先至GCP console的Service Accounts頁面建立
        # ${GCP_SA}, ${PROJECT_ID} 請依實際狀況代入
        gcloud auth activate-service-account ${GCP_SA} --key-file=/path/key.json --project=${PROJECT_ID}
        ```
   - 取得kube config(GKE cluster的連線設定)
      ```shell
      # GKE cluster連線設定會被儲存更新至 ~/.kube/config
      # ${CLUSTER_NAME} 請依實際狀況代入
      gcloud container clusters get-credentials ${CLUSTER_NAME}
      ```
   - 設定docker讓docker指令可以存取gcp artifact registry(docker pull/push)
      ```shell
      # 設定會被儲存更新至 ~/.docker/config.json
      # 視需要將 'asia-east1-docker.pkg.dev' 調整成實際的gcp artifact registry repo位置
      gcloud auth configure-docker asia-east1-docker.pkg.dev
      ```
   - 至此可以開始安裝k9s, kubectl, helm等工具存取gke cluster；若以ldap帳密登入使用server02(192.168.23.168)環境，可不用安裝。
