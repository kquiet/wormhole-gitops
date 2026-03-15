# Repository簡介
1. 所有需要透過gitops觸發、部署到GKE環境的wormhole相關系統manifest都放在這裡，在這裡不會、也不能存放任何系統原始碼及secrets(密碼、金鑰、憑證等)。
2. 針對此repository的main分支所做修改皆會觸發gitlab-ci pipeline: 將此repository的內容傳輸至GCP環境(在GCP環境建立此repository的副本)。
3. GKE Cluster裏的Argo CD系統會監控位於GCP的repository副本，在偵測到repository副本有任何更新時，會將repository內定義的部署manifests以自動/手動的方式同步至GKE。
![GCP-ARGOCD](https://www.plantuml.com/plantuml/png/PP0zJm8n6CVt-nHFs3bpwEHW86WOV8bnS2zj1U9TdwPN9COmQLH2OXpGGNHoa1W5NtGmHlqoN0-_XUrfM9pQzFdzV_ydBSQQADsCGe-6s6ImKbe34WCDOCy385IZ0iPtU8YIApSXEh03HZIfafX3hjBGA6FOu19ZUrMxEKUnQk2r_vILydgcB6HAWSocDbSpJ30dauHkang7olAIUvI_tG0K8uc22msvageXb1Up49KkrBP-kmlaLQDMr_a5Lmdp4FZZhw7flKMa8PBZGzCRUMwGPzWI5XBCGGNVz5_C-OEQBfrqHkRopgFIeaqv1MVzj7zjJcx-WG8rXwmPS0jipC9p_lZpQZAuJuONawFRf7isOpfTUtpl3zAFfnQgg8uXJquFqkVtzFNHAtB1xCV_0000)

## apps目錄說明
此目錄內存放wormhole各系統部署至GKE Cluster所需的所有manifests。目前包含2個子目錄：
1. wormhole：存放wormhole各系統的部署manifests。目前在此目錄底下的各個子目錄都是採用[kustomize](https://github.com/kubernetes-sigs/kustomize#user-content-usage)的結構存放manifests。
    - kustomize目錄結構：在 `base`目錄內存放基礎yaml(例如deployment)及 `kustomization.yaml`(kustomize配置檔)、在 `overlays`目錄內存放各環境(e.g.: dev, stage, prod)特有的yaml及 `kustomization.yaml`

    | wormhole的子目錄 | 說明 |
    |-----|-----|
    |[root-app](/apps/wormhole/root-app)|存放欲透過Argo CD進行部署管理的wormhole各系統Application manifest。沒有在此目錄結構下建立Argo CD Application manifest的wormhole系統需透過手動方式在Argo CD介面建立，才能由Argo CD進行部署管理。每個Argo CD Application manifest定義了實際要部署的manifests來源、目的地cluster、同步選項。如何建立Argo CD Application manifest可參考 `base`目錄內的yaml檔或是官網的[詳細範例](https://argo-cd.readthedocs.io/en/stable/operator-manual/application.yaml)。|
    |[opensearch-cluster-resources](/apps/wormhole/opensearch-cluster-resources)|存放部署opensearch cluster至GKE所需的manifests。|
    |[ocr](/apps/wormhole/ocr)|存放部署ocr至GKE所需的manifests。|
    |[preprocessing](/apps/wormhole/preprocessing)|存放部署preprocessing至GKE所需的manifests。|
    |[frontend](/apps/wormhole/frontend)|存放部署frontend至GKE所需的manifests。|
    |[embedding](/apps/wormhole/embedding)|存放部署embedding至GKE所需的manifests。|
    |[llm](/apps/wormhole/llm)|存放部署llm至GKE所需的manifests。|
    |[reranker](/apps/wormhole/reranker)|存放部署reranker至GKE所需的manifests。|
    |[backend](/apps/wormhole/backend)|存放部署backend至GKE所需的manifests。|
2. devops：存放GKE Cluster基礎服務的部署manifests。目前包含external-secrets, cert-manager, opensearch-operator, external-dns及其它相關manifests。

# 各系統於GKE的部署狀態
## DEV環境(cluster: [wormhole](https://console.cloud.google.com/kubernetes/clusters/details/asia-east1/wormhole/details?inv=1&invt=AbztGg&project=wormhole-proj-id), namespace: wormhole-dev)
| 系統 | 部署狀態 | Internet網址 |
|-----|-----|-----|
|opensearch|[![opensearch](https://argocd.kquiet.org/api/badge?name=opensearch-cluster-resources&revision=true&showAppName=true&namespace=wormhole-dev)](https://argocd.kquiet.org/applications/wormhole-dev/opensearch-cluster-resources)||
|ocr|[![ocr](https://argocd.kquiet.org/api/badge?name=ocr&revision=true&showAppName=true&namespace=wormhole-dev)](https://argocd.kquiet.org/applications/wormhole-dev/ocr)||
|preprocessing|[![preprocessing](https://argocd.kquiet.org/api/badge?name=preprocessing&revision=true&showAppName=true&namespace=wormhole-dev)](https://argocd.kquiet.org/applications/wormhole-dev/preprocessing)||
|frontend|[![frontend](https://argocd.kquiet.org/api/badge?name=frontend&revision=true&showAppName=true&namespace=wormhole-dev)](https://argocd.kquiet.org/applications/wormhole-dev/frontend)|https://dev.kquiet.org|
|embedding|[![embedding](https://argocd.kquiet.org/api/badge?name=embedding&revision=true&showAppName=true&namespace=wormhole-dev)](https://argocd.kquiet.org/applications/wormhole-dev/embedding)||
|llm|[![llm](https://argocd.kquiet.org/api/badge?name=llm&revision=true&showAppName=true&namespace=wormhole-dev)](https://argocd.kquiet.org/applications/wormhole-dev/llm)||
|reranker|[![reranker](https://argocd.kquiet.org/api/badge?name=reranker&revision=true&showAppName=true&namespace=wormhole-dev)](https://argocd.kquiet.org/applications/wormhole-dev/reranker)||
|backend|[![backend](https://argocd.kquiet.org/api/badge?name=backend&revision=true&showAppName=true&namespace=wormhole-dev)](https://argocd.kquiet.org/applications/wormhole-dev/backend)||

### 架構圖
#### 1.Endpoint關係
![Endpoint關係](https://www.plantuml.com/plantuml/png/TP9DReCm48NtFWNAFZ_ghb4QvHvL5s26nCBOxZEqYwftxuoWhYteOfBeuqs-9-DR76kCqs1Lg7LVtwdguDr8hgs-bFP3y8xSMBqc6dmRtwewSauPHkXgJTNkqdcEQMyzNa3jzJ6E8PwFnvO-3ltxP6WyUDmlHubTT_E-KJpLVYz_zQrIWOQ_Ltw1XRxfSxtesBQa3cBzz1WUtj9kJXl5mp9PxC0_hW9pRm05U4qn6dSlxUMZr25WeqEHNJS9C8f7cWHm9saYC6z2GqDjksenuw81DHiDKcvjfyOe7h5JizW5vdPhXzBB81dbgTvmCbxR61eb7woP5nUZi5m9GkrwGkbDDCc13VLlREq7ZE8HEz9P0uNQ1tAHQkX7ASzuqllmtvLlx4Jfpl-jxhMT8Y-SdvzEf_po-s0KZpJpOMaci6YcKLPYa7NHs7eFZDVdm91r6kAR5mDceuOeR-JQQR0_)

#### 2.互動流程
![互動流程](https://www.plantuml.com/plantuml/png/ZL4zRnGn4EtzAwOaYf12Iu7oLxpUsLjhrnupdasubWfHG1CgAWeQ92ee-47ayZUOstE2lGeVfzFQVc_UlF7pPHRBieJP95szyyb6WO4f2iOURDPzGtNMJONffeP9Z8d9OSu-xevyQfNaM55TMXX3XtrV9DWr72FREE6gurOsp-68wjAQ98mPBRjnzKh6x9YM18SlDuTFRtx-U7lx-fiP69w-qF6Vm-1d1BTULamt7U746zZE0gaVrhFrCOCFTeS6z9VMHkHKeXMDREMLMLlMlE0hCPgWIPifnYLE6PuS-RCo2tODQR1h95VeX3YNOaej3DTUnjKk6qhtmcol41ZpCalH3JhTacQoVS7NwKfkTn-_7zvzlltm_kxhJPNRomMpU8gbXRv2XUdflix6V8rS6HL07TgN-PS3TXM4tRQgtBbAOiDK2OXkdrrSG4zk2HZb8VbJvU_OpamaGM2_6qM3yy7FbhtiuSfRS9Hzn6B8N1cUdp876hOMXX-kHzmZO__dqhzO2skA0t50hlFF-omO8365971U3-H6Ap3wBCHxFSxQJnuppu-vjzNzWY2a_mdZYVhVzxxKpnBcNm00)

### 查看Log
GCP提供Log Explorer查詢運行於GKE的Pod logs。可到[這裡](https://cloudlogging.app.goo.gl/GDxUWRwCEmrBiQr59)查看(時間範圍或其它條件可自行依需求調整)

### 查看Trace
GCP提供Trace Explorer查詢運行於GKE的Pod traces；目前GKE環境已採用自動探測(auto-instrumentation)的方式將wormhole各系統的traces資料保存至GCP，可到[這裡](https://console.cloud.google.com/traces/explorer;query=%7B%22plotType%22:%22HEATMAP%22,%22pointConnectionMethod%22:%22GAP_DETECTION%22,%22targetAxis%22:%22Y1%22,%22traceQuery%22:%7B%22resourceContainer%22:%22projects%2Fwormhole-proj-id%22,%22spanDataValue%22:%22SPAN_DURATION%22,%22spanFilters%22:%7B%22attributes%22:%5B%5D,%22displayNames%22:%5B%5D,%22isRootSpan%22:true,%22kinds%22:%5B%5D,%22maxDuration%22:%22%22,%22minDuration%22:%22%22,%22services%22:%5B%5D,%22status%22:%5B%5D%7D%7D%7D;duration=PT30M?inv=1&invt=Ab1v9Q&project=wormhole-proj-id)查看(時間範圍或其它條件可自行依需求調整)

## DEVOPS環境(cluster: [wormhole](https://console.cloud.google.com/kubernetes/clusters/details/asia-east1/wormhole/details?inv=1&invt=AbztGg&project=wormhole-proj-id))
| 系統 | 部署狀態 | Internet網址 |
|-----|-----|-----|
|argocd|[![argocd](https://argocd.kquiet.org/api/badge?name=argocd-resources&revision=true&showAppName=true&namespace=devops)](https://argocd.kquiet.org/applications/devops/argocd-resources)|https://argocd.kquiet.org|
|external-secrets|[![external-secrets](https://argocd.kquiet.org/api/badge?name=external-secrets&revision=true&showAppName=true&namespace=devops)](https://argocd.kquiet.org/applications/devops/external-secrets)||
|cert-manager|[![cert-manager](https://argocd.kquiet.org/api/badge?name=cert-manager&revision=true&showAppName=true&namespace=devops)](https://argocd.kquiet.org/applications/devops/cert-manager)||
|opensearch-operator|[![opensearch-operator](https://argocd.kquiet.org/api/badge?name=opensearch-operator&revision=true&showAppName=true&namespace=devops)](https://argocd.kquiet.org/applications/devops/opensearch-operator)||
|external-dns(public domain)|[![external-dns-public](https://argocd.kquiet.org/api/badge?name=external-dns-public&revision=true&showAppName=true&namespace=devops)](https://argocd.kquiet.org/applications/devops/external-dns-public)||
|external-dns(private domain)|[![external-dns-private](https://argocd.kquiet.org/api/badge?name=external-dns-private&revision=true&showAppName=true&namespace=devops)](https://argocd.kquiet.org/applications/devops/external-dns-private)||
|opentelemetry-operator|[![opentelemetry-operator](https://argocd.kquiet.org/api/badge?name=opentelemetry-operator&revision=true&showAppName=true&namespace=devops)](https://argocd.kquiet.org/applications/devops/opentelemetry-operator)||

# Reference
## Argo CD管理介面
 - 先前使用gcp load balancer以ip的方式連接可能會被內網防火牆阻擋。請改以[此處](https://argocd.kquiet.org/)連結瀏覽。帳號及密碼請詢問wormhole的Argo CD管理者。
## GitOps原則
 - Git 是唯一真相來源：除了secrets以外，所有部署定義(manifests)都放在Git
 - 宣告式系統狀態：用yaml(或其它格式)描述「系統該如何運行」，而不需寫程式或下指令
 - 自動同步：當 git 有變更，自動同步變更到 GKE
 - 可追蹤：每次變更都以git commit形式存在，方便審查與追蹤
