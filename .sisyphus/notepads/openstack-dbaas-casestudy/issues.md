# OpenStack RHOSO DBaaS Case Study - Issues

## Known Blockers
- None yet

## Scope Update (2026-05-26)
- Task 1 does NOT need to check actual infrastructure
- Instead, base validation on existing outputs/docs in ~/git/openstack-101
- openstack-101 already contains extensive OpenStack/RHOSO/DBaaS documentation and evidence

## Potential Risks
- DBaaS deployment complexity may exceed PoC scope
- Need to ensure we don't duplicate work already done in openstack-101

## Gotchas
- openstack-101 has many deliverables - need to map them correctly to our case study
- Physical validation file is empty (physical-rhoso-validation.md) - documented as gap

## Task 1 Findings (2026-05-26)
- **Overall Verdict**: CONDITIONAL PASS
  - Architecture: 8/8 PASS (100%)
  - Deployment: 15/17 PASS (88%) - minor RHOSP/Kolla-ansible doc gaps
  - Services: 5/15 PASS (33%) - only 5 of 15 service dirs have content
  - Operations (Day-2): 7/7 PASS (100%) - comprehensive
  - FPT Cloud DBaaS Docs: 10/10 PASS (100%) - complete extraction with gap analysis
  - Validation & QA: 22/22 PASS (100%) - extremely comprehensive
  - Historical Evidence: 16/16 PASS (100%)
- **Key gap**: 10 OpenStack service directories are empty (barbican, designate, heat, horizon, ironic, magnum, manila, octavia, placement, swift)
- **Key gap**: physical-rhoso-validation.md is 0 bytes - validation docs exist in output/ dirs though
- **Evidence**: Created docs/environment-validation.md + .sisyphus/evidence/task-1-validation-file.txt

## Task 5 Findings (2026-05-26) — RHOSO Environment Setup Documentation
- **Scope**: Document RHOSO environment configuration from existing outputs/docs in ~/git/openstack-101 (NO infrastructure accessed)
- **Primary Source**: `deployment/rhosp/README.md` (214 lines, stable, 2026-03-19) — comprehensive RHOSP 18 (RHOSO) deployment guide
- **RHOSO Architecture**: Podified control plane on RHOCP 4.18+ (Keystone, Nova, Neutron, Cinder, Glance, MariaDB/Galera, RabbitMQ, OVN); bare-metal RHEL 9 data plane (Libvirt/OVS/OVN)
- **Operator Model**: Each service has its own Operator; OLM installs/updates; CRDs (OpenStackControlPlane, KeystoneAPI, OpenStackDataPlaneNodeSet) define desired state; GitOps native
- **Network**: OVN exclusive backend; 6 planes (ctlplane, internalapi, tenant, storage, storagemgmt, external); MetalLB for API endpoints; NNCP via nmstate operator
- **Storage**: Red Hat Ceph Storage 8 preferred; Cinder/Glance/Nova use RBD; Manila uses CephFS
- **Physical Environment Drafts**:
  - `physical-rhoso-install.md`: 5 Dell R640 servers, 3-node compact OCP, 2 EDPM compute nodes, 5 VLANs, Cisco Nexus 9300 switch
  - `worklog-ocp-install-20260523.md`: OCP 4.18 install IN PROGRESS via Assisted Installer (rhoso.fsoft.local, API VIP 10.192.66.100). Bond issues on Server02/03/04/05. Data VLAN SVIs missing.
  - `physical-rhoso-validation.md`: Draft validation plan. Prior AWS PoC: 34/36 passed (94.4%). Lists V-items for physical re-validation. Hardware quotation extracted. 3 blocking decisions unresolved (KP-02 local disk vs Ceph, KP-03 NIC mapping, KP-05 control plane placement).
- **AWS Reference Environment**: `aws-rhoso-validation-env-plan_old.md` (1534+ lines) — extremely detailed 11-phase guide using EC2 i3.metal, VirtualBMC, Ironic, RAID5, Patroni cluster. 33/37 validation items testable.
- **Validation Evidence**: 30+ PNG screenshots in `aws-rhoso-validation-env-evidence/` (V1, V11, V19, V27, V30, V31, V33, V9, rt-v1 series, etc.) + 2 GIFs in repo root (`bastion-oc-cluster-status.gif`, `bastion-oc-test.gif`)
- **DBaaS Context**: `deployment/comparison/dbaas/README.md` maps 64 DBaaS requirements to OpenStack services; 34 deliverables documented
- **Key Gaps**:
  - Physical RHOSO deployment is INCOMPLETE (OCP install in progress as of 2026-05-23, bond issues pending)
  - `physical-rhoso-validation.md` is draft-only with open questions
  - No evidence file showing completed physical RHOSO deployment
  - 3 blocking decisions (KP-02, KP-03, KP-05) remain unresolved
- **Evidence**: Created `.sisyphus/evidence/task-5-rhoso-access.txt`

## Task 6 Findings (2026-05-26) — DBaaS Core Deployment Documentation
- **Scope**: Document DBaaS deployment configuration and procedures from existing outputs/docs in ~/git/openstack-101 (NO deployment performed)
- **Primary Source**: `deployment/comparison/dbaas/README.md` — comprehensive DBaaS Configuration Comparison Study with 34 deliverables
- **Architecture Patterns Evaluated**:
  - **Pattern-1 (Reuse on RHOSO/OpenStack)**: Customer-managed VM images + Ansible, high operational burden
  - **Pattern-2A (Production-Ready on RHOSO/OpenStack)**: VM-based production-ready design, custom DBaaS controller TBD (Trove ruled out)
  - **Pattern-2B (FPT Cloud)**: Managed service, lowest operational burden, RECOMMENDED
- **Database Engines**: Phase 1 = PostgreSQL (primary); Phase 2 = MySQL, MongoDB, Redis; Phase 3 = Oracle, MS SQL Server, H2, Neo4j, Cassandra
- **Trove Evaluation**: Ruled out for production — 35/64 requirements supported (54.7%), declining community (2–5 active devs), HA features experimental
- **PostgreSQL Foundation (Task 7)**: Patroni recommended for cloud-native HA (RTO 30–60s), pgBackRest for backup (10–20x faster than pg_basebackup), 3-tier parameter templates (350–4,900 connections, 14k–105k IOPS)
- **AWS PoC Validation Results**: 34/36 passed (94.4%), 16/16 T1/MUST critical items passed (100%), 169 evidence files collected (screenshots + command outputs)
- **Patroni HA Stack**: PostgreSQL 16 + Patroni + etcd 3.5.17 (3-member cluster) + VIP callback script + pgBackRest on AWS EFS
- **FPT Cloud Documentation**: 45 pages mapped, 10+ questionnaire categories, 6 high-priority pages extracted, 10 documentation gaps identified (API, Terraform, cost, encryption, read replicas, multi-region, compliance, DR, performance tuning, migration tools)
- **Key Gaps**:
  - Physical bare-metal deployment INCOMPLETE (physical-rhoso-validation.md is 0 bytes)
  - Customer hardware specs not yet provided (blocks requirement R13)
  - SoftBank network team not yet introduced (blocks requirement R3)
  - Custom DBaaS controller for Pattern-2A deferred to post-assessment phase
- **Evidence**: Created `.sisyphus/evidence/task-6-dbaas-deployed.txt`
