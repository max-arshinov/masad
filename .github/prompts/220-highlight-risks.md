---
mode: 'agent'
description: 'Impact Assessment Rules for Emoji-Based Risk Marking'
---

### Scaling Tiers (Reference)
| Tier            | CPU (RPS) | RAM    | Disk   | Network (aggregate) |
|-----------------|-----------|--------|--------|---------------------|
| 🟩Minuscule     | 10        | 128 GB | 1 TB   | 1 Gbps              |
| 🟩A few         | 100       | 512 GB | 10 TB  | 10 Gbps             |
| 🟨Something     | 1,000     | 1 TB   | 100 TB | 40 Gbps             |
| 🟥 A lot        | 10,000    | 10 TB  | 1 PB   | 100 Gbps            |
| 🟥 OMG          | 100,000   | 100 TB | 10 PB  | 400 Gbps            |
| 🟥 Mind-blowing | 1,000,000 | 1 PB   | 1 EB   | ≥1 Tbps             |

<impact_rules>
Scaling Reference Table (use for emoji Impact classification):

| Scale        | CPU (RPS) | RAM    | Disk   | Network  | Architecture Style | Team Seniority | Comments                                     |
|--------------|----------:|--------|--------|----------|--------------------|----------------|----------------------------------------------|
| Minuscule    |        10 | 128 GB | 1 TB   | 1 Gbps   | Monolith           | Junior–Middle  | Works on a single machine                    |
| A few        |       100 | 512 GB | 10 TB  | 10 Gbps  | Modular monolith   | Middle–Senior  | Works on a single machine                    |
| Something    |     1,000 | 1 TB   | 100 TB | 40 Gbps  | Micro-services     | Senior         | Scale horizontally                           |
| A lot        |    10,000 | 10 TB  | 1 PB   | 100 Gbps | Micro-services     | Senior–Expert  | Operational issues: migrations, backups, SRE |
| OMG          |   100,000 | 100 TB | 10 PB  | 400 Gbps | Micro-services     | Expert+        | High infra complexity                        |
| Mind-blowing | 1,000,000 | 1 PB   | 1 EB   | 1 Tbps+  | Micro-services     | God Emperor    | Hyperscale only (HPC/cloud providers)        |

Impact Rules:
- CPU: ≤100 🟩, 1k–10k 🟨, ≥100k 🟥
- RAM: ≤1 TB 🟩, 10–100 TB 🟨, >100 TB 🟥
- Disk: ≤100 TB 🟩, 1–10 PB 🟨, >10 PB 🟥
- Network: ≤10 Gbps 🟩, 40–100 Gbps 🟨, ≥400 Gbps 🟥
- Architecture: Monolith 🟩, Micro-services <10k RPS 🟨, Micro-services ≥100k RPS 🟥
- Team: Junior–Senior 🟩, Senior–Expert 🟨, Expert+/God Emperor 🟥
- Ops Comments: simple 🟩, migrations/backups/SRE 🟨, hyperscale ops 🟥
  </impact_rules>


<instructions>
- Reuse the assumptions and parameters listed in the previous ADR.
- In the **Impact Assessment table**, mark risk severity with emojis:
  * 🟩 Low
  * 🟨 Medium
  * 🟥 High
- Place emojis directly inside table cells, not in a separate legend or list.
</instructions>