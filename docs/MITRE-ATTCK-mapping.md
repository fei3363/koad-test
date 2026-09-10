# KOAD — MITRE ATT&CK Containers Matrix Complete Mapping

> 35 Scenarios × 10 Tactics × 28 Techniques = 100% Coverage

## Coverage Matrix

| Tactic | Technique ID | Technique Name | KOAD Scenario | Falco Rule | Kyverno Policy | Defense |
|--------|-------------|----------------|---------------|------------|----------------|---------|
| **TA0001 Initial Access** | T1190 | Exploit Public-Facing App | S01 | SSRF Outbound | — | NetworkPolicy |
| | T1133 | External Remote Services | S02 | Kubelet API Access | — | kubelet auth |
| | T1078 | Valid Accounts | S03 | — | — | Secret mgmt |
| **TA0002 Execution** | T1059 | Command/Scripting | S04 | Shell in Container | — | PSS |
| | T1609 | Container Admin Command | S05 | kubectl in Container | disable-automount | RBAC |
| | T1610 | Deploy Container | S06 | — | block-privileged | Admission |
| | T1053 | Scheduled Task/Job | S07 | CronJob Created | — | RBAC |
| | T1204 | User Execution | S08 | — | trusted-registry | Training |
| **TA0003 Persistence** | T1098 | Account Manipulation | S09 | CRB Created | — | Audit |
| | T1136 | Create Account | S10 | SA in kube-system | — | Audit |
| | T1543 | Create/Modify Process | S11 | Sidecar Detected | — | Webhook audit |
| | T1525 | Implant Internal Image | S12 | — | trusted-registry | Cosign |
| **TA0004 Priv Escalation** | T1611 | Escape to Host | S13–S18 | 6 escape rules | block-privileged | PSS/seccomp |
| | T1068 | Exploit for Priv Esc | S19 | Kernel Exploit | — | Patching |
| **TA0005 Stealth** | T1612 | Build Image on Host | S20 | Docker Build | — | Read-only FS |
| | T1070 | Indicator Removal | S21 | History Deletion | — | Immutable logs |
| | T1036 | Masquerading | S22 | Pod in kube-system | — | Namespace RBAC |
| **TA0112 Def. Impairment** | T1685 | Disable/Modify Tools | S23 | Security Tool Del | — | RBAC protection |
| **TA0006 Credential Access** | T1110 | Brute Force | S24 | Brute Force Tool | — | Rate limiting |
| | T1528 | Steal App Token | S25 | Env Var Dump | — | Secret mgmt |
| | T1552 | Unsecured Credentials | S26 | SA Token Read | — | etcd encryption |
| **TA0007 Discovery** | T1613 | Container Discovery | S27 | — | — | RBAC |
| | T1046 | Network Service Discovery | S28 | Network Scanning | — | NetworkPolicy |
| | T1069 | Permission Groups | S29 | — | — | RBAC |
| **TA0008 Lateral Movement** | T1550 | Alt Auth Material | S30 | Cross-NS Access | — | NetworkPolicy |
| **TA0040 Impact** | T1485 | Data Destruction | S31 | — | — | PDB/Backup |
| | T1499 | Endpoint DoS | S32 | Resource Intensive | — | ResourceQuota |
| | T1490 | Inhibit Recovery | S33 | — | — | Offsite backup |
| | T1498 | Network DoS | S34 | — | — | ResourceQuota |
| | T1496 | Resource Hijacking | S35 | Cryptominer | — | Monitoring |

## Quick Reference

- **Total Tactics**: 10/10 (100%)
- **Total Techniques**: 28/28 (100%)
- **Total Scenarios**: 35
- **Falco Rules**: 28+
- **Kyverno Policies**: 7
- **NetworkPolicies**: 4
