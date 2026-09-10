# KOAD — Kubernetes Offensive and Active Defense Lab

> 自建 Kubernetes 攻防靶場，用攻擊者視角學防禦。

[![ATT&CK Coverage](https://img.shields.io/badge/ATT%26CK%20Containers-100%25-red)]()
[![Scenarios](https://img.shields.io/badge/Scenarios-35-blue)]()
[![Falco Rules](https://img.shields.io/badge/Falco%20Rules-26-orange)]()
[![Kyverno Policies](https://img.shields.io/badge/Kyverno%20Policies-7-green)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## What is KOAD?

KOAD 是一座可以在筆電上一鍵部署的 Kubernetes 攻防靶場。涵蓋 MITRE ATT&CK Containers Matrix 全部 **10 個戰術、28 個技術**，共 **35 個攻擊場景**——每個場景都配有 Falco 即時偵測規則和 Kyverno 預防策略。

**不只告訴你「該鎖什麼門」，而是讓你親眼看完小偷怎麼進來，再教你鎖門。**

## Quick Start

### 環境需求

| 工具 | 最低版本 | 安裝方式 |
|------|---------|---------|
| Docker | 24.0+ | [docs.docker.com](https://docs.docker.com/get-docker/) |
| Minikube | v1.34+ | [minikube.sigs.k8s.io](https://minikube.sigs.k8s.io/docs/start/) |
| kubectl | v1.30+ | [kubernetes.io](https://kubernetes.io/docs/tasks/tools/) |
| Helm | v3.16+ | [helm.sh](https://helm.sh/docs/intro/install/) |

**硬體建議：** 4 CPU cores / 8 GB RAM

### 一鍵部署

```bash
git clone https://github.com/fei3363/koad.git
cd koad
bash setup.sh
```

部署約 5 分鐘，完成後會看到：

```
[KOAD] KOAD Lab Deployed Successfully!

  Namespaces:
    koad       — Target scenarios
    koad-attack  — Attacker tools
    koad-defense — Defense stack
    koad-registry— Private registry

  Scenarios: 35 (S01-S35)
  ATT&CK Coverage: 10 Tactics x 28 Techniques = 100%
```

### 開始使用

```bash
# 查看所有場景 Pod
kubectl get pods -n koad

# 查看攻擊者工具箱
kubectl get pods -n koad-attack

# 觀察 Falco 即時告警
kubectl logs -l app.kubernetes.io/name=falco -n falco -f

# 執行自動化攻擊鏈
kubectl exec -it attacker -n koad-attack -- bash /opt/attack-chain.sh

# 執行 CIS Benchmark 掃描
bash defense/benchmark/run-benchmark.sh
```

### 清理環境

```bash
bash teardown.sh

# 如果要連 Minikube 一起刪除
minikube delete
```

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Minikube Cluster                   │
│                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │ koad     │  │ koad-    │  │ koad-defense     │  │
│  │          │  │ attack   │  │                  │  │
│  │ S01-S35  │  │ Attacker │  │ Falco + Kyverno  │  │
│  │ Targets  │  │ Toolbox  │  │ NetworkPolicies  │  │
│  └──────────┘  └──────────┘  └──────────────────┘  │
│                                                     │
│  ┌──────────────┐  ┌────────────────────────────┐   │
│  │ koad-registry│  │ Calico CNI                 │   │
│  │ Private Reg  │  │ (Network Policy Engine)    │   │
│  └──────────────┘  └────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

## ATT&CK Coverage

| Tactic | Techniques | Scenarios | 說明 |
|--------|-----------|-----------|------|
| Initial Access | T1190, T1133, T1078 | S01-S03 | SSRF、暴露 kubelet、洩漏 kubeconfig |
| Execution | T1059, T1609, T1610, T1053, T1204 | S04-S08 | Web Shell、kubectl、特權 Pod、CronJob |
| Persistence | T1098, T1136, T1543, T1525 | S09-S12 | RBAC 竄改、後門 SA、Sidecar 注入 |
| Privilege Escalation | T1611, T1068 | S13-S19 | 容器逃逸六式 + 核心 CVE |
| Stealth | T1612, T1070, T1036 | S20-S22 | 宿主機建映像、痕跡清除、偽裝 |
| Defense Impairment | T1685 | S23 | 停用 Falco/Kyverno |
| Credential Access | T1110, T1528, T1552 | S24-S26 | 暴力破解、竊取 Token |
| Discovery | T1613, T1046, T1069 | S27-S29 | 資源探索、網路掃描、RBAC 列舉 |
| Lateral Movement | T1550 | S30 | Token 橫向移動 |
| Impact | T1485, T1499, T1490, T1498, T1496 | S31-S35 | 資料破壞、資源炸彈、挖礦 |

## Project Structure

```
koad/
├── setup.sh               # 一鍵部署
├── teardown.sh             # 清理環境
├── Makefile                # make setup / make teardown / make status
├── scenarios/              # 35 個攻擊場景 YAML
│   ├── initial-access/     # S01-S03
│   ├── execution/          # S04-S08
│   ├── persistence/        # S09-S12
│   ├── privilege-escalation/ # S13-S19
│   ├── stealth/            # S20-S22
│   ├── defense-impairment/ # S23
│   ├── credential-access/  # S24-S26
│   ├── discovery/          # S27-S29
│   ├── lateral-movement/   # S30
│   └── impact/             # S31-S35
├── apps/                   # 靶機應用程式
│   ├── vulnerable-webapp/  # SSRF 漏洞 Web App
│   ├── jupyter-insecure/   # 無認證 Jupyter
│   ├── mock-metadata/      # 模擬雲端 Metadata API
│   ├── c2-server/          # 模擬 C2 伺服器
│   ├── private-registry/   # 不安全私有 Registry
│   └── brute-forcer/       # 暴力破解工具
├── attacker/               # 攻擊者工具箱 + 自動化攻擊鏈
├── defense/                # 防禦元件
│   ├── falco/              # 自訂偵測規則 (26 rules)
│   ├── kyverno/            # 準入控制策略 (7 policies)
│   ├── network-policies/   # 網路隔離
│   ├── seccomp/            # Syscall 過濾
│   ├── apparmor/           # 強制存取控制
│   ├── gvisor/             # 沙箱容器 Runtime
│   ├── benchmark/          # CIS Kubernetes Benchmark
│   ├── audit/              # API Server 稽核策略
│   └── falco-talon/        # Falco 自動回應
├── images/                 # 攻擊用 Container Images
│   ├── backdoor-image/
│   ├── cryptominer-image/
│   ├── masquerade-image/
│   └── hidden-layers/
└── docs/                   # 參考文件
    ├── deployment-guide.md
    └── MITRE-ATTCK-mapping.md
```

## Defense Stack

| Tool | Role | Version |
|------|------|---------|
| **Falco** | Runtime threat detection (eBPF) | v0.44.1+ |
| **Kyverno** | Admission control policies | v1.13+ |
| **Calico** | Network policy enforcement | v3.28+ |
| **kube-bench** | CIS Benchmark scanning | v0.8.0 |
| **AppArmor** | Mandatory access control | built-in |
| **Seccomp** | Syscall filtering | built-in |
| **gVisor** | Sandboxed container runtime | latest |

## Troubleshooting

### Minikube 啟動失敗

```bash
# 確認 Docker 正在運行
docker info

# 如果資源不足，降低配置
minikube start --cpus=2 --memory=4096
```

### Pod 一直 Pending

```bash
# 檢查 Node 資源
kubectl describe node minikube | grep -A5 "Allocated resources"

# 檢查特定 Pod 事件
kubectl describe pod <pod-name> -n koad
```

### Falco 沒有告警

```bash
# 確認 Falco Pod 正在運行
kubectl get pods -n falco

# 檢查 Falco 日誌
kubectl logs -l app.kubernetes.io/name=falco -n falco --tail=50
```

## Related

- [MITRE ATT&CK Containers Matrix](https://attack.mitre.org/matrices/enterprise/containers/)
- [Falco Documentation](https://falco.org/docs/)
- [Kyverno Documentation](https://kyverno.io/docs/)
- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)

## License

MIT License — See [LICENSE](LICENSE)

## Author

**飛飛** — [資安這條路](https://ithelp.ithome.com.tw/users/20149562)
