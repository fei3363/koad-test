# KOAD 靶場部署指南

> Kubernetes Offensive and Active Defense Lab — 部署、排錯與解決方案

## 一、環境需求

### 硬體需求

| 項目 | 最低需求 | 建議配置 |
|------|---------|---------|
| CPU | 4 核心 | 8 核心 |
| 記憶體 | 8 GB | 16 GB |
| 磁碟空間 | 50 GB 可用 | 100 GB 可用 |

### 軟體需求

| 工具 | 版本 | 用途 |
|------|------|------|
| Docker | 24+ | 容器運行環境 |
| Minikube | v1.38+ | 本地 K8s 叢集 |
| kubectl | v1.30+ | K8s CLI |
| Helm | v3.17+ / v4+ | 部署 Falco/Kyverno |

---

## 二、安裝步驟

### 1. 安裝 Docker

```bash
# Ubuntu
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER

# 或透過 snap
sudo snap install docker
```

### 2. 安裝 Minikube

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

# 驗證
minikube version
```

### 3. 安裝 kubectl

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install kubectl /usr/local/bin/kubectl
rm kubectl

# 驗證
kubectl version --client
```

### 4. 安裝 Helm

```bash
# 方法 1：snap（推薦，可繞過某些網路問題）
sudo snap install helm --classic

# 方法 2：官方腳本
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# 方法 3：手動下載
curl -fsSL -o helm.tar.gz https://get.helm.sh/helm-v3.17.3-linux-amd64.tar.gz
tar -xzf helm.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm

# 驗證
helm version --short
```

---

## 三、部署 KOAD 靶場

### 快速部署（一鍵）

```bash
cd KOAD/
bash setup.sh
```

### 手動部署

#### Step 1: 啟動 Minikube

```bash
minikube start \
  --driver=docker \
  --cpus=4 \
  --memory=8192 \
  --kubernetes-version=v1.30.0 \
  --cni=calico
```

#### Step 2: 建立 Namespace

```bash
for ns in koad koad-attack koad-defense koad-registry koad-production; do
  kubectl create namespace "$ns"
done
```

#### Step 3: 建構自訂映像

```bash
# 使用 minikube image build（直接在 minikube Docker daemon 裡建構）
minikube image build -t koad/vulnerable-webapp:latest apps/vulnerable-webapp/
minikube image build -t koad/mock-metadata:latest apps/mock-metadata/
minikube image build -t koad/brute-forcer:latest apps/brute-forcer/
```

#### Step 4: 部署場景

```bash
# 依戰術逐一部署
kubectl apply -f scenarios/initial-access/
kubectl apply -f scenarios/execution/
kubectl apply -f scenarios/persistence/
kubectl apply -f scenarios/privilege-escalation/
kubectl apply -f scenarios/stealth/
kubectl apply -f scenarios/defense-impairment/
kubectl apply -f scenarios/credential-access/
kubectl apply -f scenarios/discovery/
kubectl apply -f scenarios/lateral-movement/
kubectl apply -f scenarios/impact/
```

#### Step 5: 驗證部署

```bash
# 檢查所有 Pod 狀態
kubectl get pods -n koad

# 確認場景覆蓋
kubectl get pods -n koad -o jsonpath='{range .items[*]}{.metadata.labels.koad-scenario}{"\n"}{end}' | sort -u
```

---

## 四、遇到的問題與解決方案

### 問題 1：磁碟空間不足 — Docker is out of disk space

**症狀：**
```
X Exiting due to RSRC_DOCKER_STORAGE: Docker is out of disk space!
(/var is at 100% of capacity)
```

**原因：** Docker 長期使用累積大量 build cache（可達 100GB+）、未使用映像、停止的容器。

**解決方案：**
```bash
# 檢查磁碟使用情況
df -h /
docker system df

# 清理 Docker（釋放空間）
docker system prune -a -f --volumes

# 只清理 build cache
docker builder prune -a -f

# 只清理未使用映像
docker image prune -a -f
```

**預防：** 定期執行 `docker system prune`，或設定 Docker 的 `--storage-opt dm.basesize` 限制。

---

### 問題 2：映像拉取失敗 — bitnami/kubectl:1.30 not found

**症狀：**
```
Failed to pull image "bitnami/kubectl:1.30":
manifest for bitnami/kubectl:1.30 not found: manifest unknown
```

**原因：** Bitnami 的映像 tag 命名規則變更，`1.30` 不是有效 tag。

**解決方案：**
```bash
# 使用 latest tag
sed -i 's|bitnami/kubectl:1.30|bitnami/kubectl:latest|g' scenarios/**/*.yaml

# 或先拉取確認可用的 tag
minikube ssh -- docker pull bitnami/kubectl:latest

# 重新部署失敗的 Pod
kubectl delete pod <pod-name> -n koad
kubectl apply -f <scenario-file>.yaml
```

**教訓：** 第三方映像 tag 可能隨時失效，建議使用 `latest` 或固定 digest。

---

### 問題 3：kube-system PodSecurity 限制

**症狀：** 在 `kube-system` namespace 建立 Pod 後立即被刪除，`kubectl get pods` 看不到。

**原因：** Kubernetes 1.25+ 預設對 `kube-system` 啟用 PodSecurity Standards（Restricted level），不允許一般 Pod。

**解決方案：**
```bash
# 方案 1：將偽裝 Pod 部署到 koad namespace（推薦）
# 修改 YAML 的 namespace 為 koad

# 方案 2：修改 kube-system 的 PSS 標籤（不建議在生產環境）
kubectl label ns kube-system pod-security.kubernetes.io/enforce=privileged --overwrite
```

**KOAD 決策：** 將 S22 masquerading Pod 改為部署在 `koad` namespace，在文章中說明真實攻擊會嘗試放入 kube-system。

---

### 問題 4：Minikube Docker env 權限問題

**症狀：**
```
ERROR: open /home/ubuntu/.minikube/certs/ca.pem: permission denied
```

**原因：** 透過 snap 安裝的 Docker 受限於 AppArmor/seccomp 沙箱，無法讀取 `~/.minikube/certs/`。

**解決方案：**
```bash
# 使用 minikube image build 替代 docker build
# 這會直接在 minikube VM 裡建構映像，不需要本地 Docker 存取憑證
minikube image build -t <tag> <path>

# 或使用 minikube image load（先在本地 build，再載入）
docker build -t <tag> <path>
minikube image load <tag>
```

---

### 問題 5：Helm 安裝失敗 — get.helm.sh 連線被拒

**症狀：**
```
curl: (7) Failed to connect to get.helm.sh port 443:
Couldn't connect to server
```

**原因：** 網路限制或 DNS 解析問題，無法連到 `get.helm.sh`。

**解決方案：**
```bash
# 使用 snap 安裝（走不同的 CDN）
sudo snap install helm --classic

# 或從 GitHub releases 直接下載
curl -sL https://github.com/helm/helm/releases/download/v3.17.3/helm-v3.17.3-linux-amd64.tar.gz | tar xz
sudo mv linux-amd64/helm /usr/local/bin/
```

---

### 問題 6：Node NotReady — 等待 Calico CNI

**症狀：** `kubectl get nodes` 顯示 `NotReady`。

**原因：** Calico CNI 需要時間啟動和配置網路。

**解決方案：**
```bash
# 等待 Node 就緒（最多 120 秒）
kubectl wait --for=condition=Ready node/minikube --timeout=120s

# 檢查 Calico Pod 狀態
kubectl get pods -n kube-system -l k8s-app=calico-node
```

---

### 問題 7：Falco Chart v9 棄用 gRPC 設定

**症狀：**
```
Error: template: falco/templates/configmap.yaml: error calling include:
template: falco/templates/_helpers.tpl: "falco.grpc" not defined
```

**原因：** Falco Helm chart v9.x（Falco 0.44+）移除了 `falco.grpc` 與 `falco.grpc_output` 設定項。

**解決方案：**
```yaml
# values-custom.yaml 中移除以下區塊：
# falco:
#   grpc:
#     enabled: true
#   grpc_output:
#     enabled: true

# Falco 0.44+ 使用不同的輸出方式（gRPC 已整合進核心）
```

---

### 問題 8：Falco rules_file 與 rules_files 衝突

**症狀：**
```
Validation error: only one of 'rules_files' or 'rules_file' can be specified
```

**原因：** Falco 0.44 使用 `rules_files`（複數），Helm chart 自動設定此值。若自訂 values 中同時包含 `rules_file`（單數）會造成衝突。

**解決方案：**
```yaml
# 移除 values-custom.yaml 中的 rules_file 設定
# 讓 Helm chart 自動管理 rules_files
# 自訂規則改用 customRules 區塊：
customRules:
  koad-rules.yaml: |-
    # 規則內容寫在這裡
```

---

### 問題 9：Falco inotify handler 初始化失敗

**症狀：**
```
could not initialize inotify handler: inotify_init error.
Make sure /proc/sys/fs/inotify/max_user_instances is greater than 0
```

**原因：** Minikube Docker driver 環境中，inotify 的 `max_user_instances` 受限（預設 128），Falco 嘗試監視設定檔變更時耗盡 inotify 實例。

**解決方案：**
```bash
# 方法 1：在主機上增加 inotify 限制
sudo sysctl -w fs.inotify.max_user_instances=1024

# 方法 2：在 values-custom.yaml 中關閉設定檔監視（推薦）
falco:
  watch_config_files: false
```

**建議：** 在 Minikube 實驗環境中建議關閉 `watch_config_files`，避免不必要的 inotify 開銷。

---

## 五、防禦堆疊部署

### Falco — 執行時期威脅偵測

```bash
# 加入 Helm repo
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

# 部署 Falco（含 Falcosidekick UI）
helm install falco falcosecurity/falco \
  -n falco --create-namespace \
  -f defense/falco/values-custom.yaml

# 驗證部署
kubectl get pods -n falco
kubectl logs -n falco -l app.kubernetes.io/name=falco -c falco --tail=5
```

**已驗證的 KOAD 偵測規則：**

| 規則 | 場景 | 優先級 | 偵測內容 |
|------|------|--------|---------|
| KOAD S04 | Shell in Container | WARNING | 容器內啟動 shell |
| KOAD S05 | kubectl Execution | CRITICAL | 容器內執行 kubectl |
| KOAD S13 | Privileged Container | CRITICAL | 特權容器啟動 |
| KOAD S26 | SA Token Read | WARNING | 讀取 ServiceAccount token |

### Kyverno — Kubernetes 原生策略引擎

```bash
# 加入 Helm repo
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update

# 部署 Kyverno
helm install kyverno kyverno/kyverno \
  -n kyverno --create-namespace

# 部署 KOAD 策略（Audit 模式）
kubectl apply -f defense/kyverno/policies.yaml

# 驗證
kubectl get cpol
kubectl get policyreport -n koad
```

**KOAD 策略清單（Audit 模式）：**

| 策略 | 偵測內容 |
|------|---------|
| koad-block-privileged | 特權容器 |
| koad-block-hostpath | HostPath 掛載 |
| koad-block-host-namespaces | HostPID/HostNetwork/HostIPC |
| koad-require-trusted-registry | 非信任映像來源 |
| koad-require-run-as-nonroot | Root 容器 |
| koad-disable-automount-sa | SA Token 自動掛載 |
| koad-drop-capabilities | 未刪除的 Linux capabilities |

---

## 六、存取靶場服務

| 服務 | 存取方式 | 埠號 |
|------|---------|------|
| SSRF Webapp | `minikube service ssrf-webapp -n koad --url` | NodePort 30080 |
| Jupyter Notebook | `minikube service jupyter-insecure -n koad --url` | NodePort 30088 |
| K8s Dashboard (fake) | `minikube service kube-dashboard -n koad --url` | NodePort 30443 |
| Private Registry | `minikube service private-registry -n koad-registry --url` | NodePort 30500 |

或使用 `kubectl port-forward`：

```bash
kubectl port-forward svc/ssrf-webapp -n koad 5000:5000
kubectl port-forward svc/jupyter-insecure -n koad 8888:8888
```

---

## 七、清除靶場

```bash
# 清除所有 KOAD 資源
bash teardown.sh

# 完全刪除 Minikube 叢集
minikube delete
```
