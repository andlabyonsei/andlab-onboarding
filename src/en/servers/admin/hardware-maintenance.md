# Hardware Work Log

A record of hardware issues and maintenance for the lab lead and server admins. For vendor inspections or repairs, see [Vendor Contacts](./vendor-contacts). How-to steps are in the [Hardware Work Guide](./hardware-guide).

## 2026.10.02 — Grafana Power Monitoring Introduced

To deal with server power supply issues, we set up Grafana to monitor the shared servers' power usage in real time.

- **Shared Server 2** (`http://165.132.193.69:3000/`) — installed and tested first. Confirmed that power data is collected in real time and displayed correctly on the dashboard
- **Shared Server 1** (`http://165.132.192.52:3000/`) — the same setup was completed afterwards

Both servers now have it installed and ready to use.

User guide: [Resource Usage Guide — Grafana Power Monitoring](../resource-usage#grafana-power-monitoring)


## 2026.06.15 — Shared Server 1 RAM Failure {#ram-failure-2026-06-15}

### Situation

- All 16 ordered RAM modules were installed, but **one was not detected**
- An xdnode engineer inspected on site → confirmed **one faulty RAM module**, replaced free of charge
- Detected correctly after replacement

Check commands and how to tell a bad slot from a bad module: [Hardware Work Guide — RAM Check & Fault Diagnosis](./hardware-guide#ram-check)

The motherboard warranty for Shared Server 1 is usually 3 years, and **2 years had passed** at the time. Motherboard issues must be handled **as quickly as possible**.


## 2026.05.24 — RAM Relocation & Expansion

### Work done

| Server | Change |
|------|------|
| Shared Server 1 | Existing 16 RAM modules → moved to Server 2. Installed 12 of 15 new SK hynix modules (+ 4 more planned) |
| Shared Server 2 | 16 from Server 1 + 4 existing = **20 in total**. One more GPU planned, for **4 in total** |

### Budget & paperwork

- For parts bought within the allocated budget, **photos** are required right after purchase, after installation, and after confirming normal operation — **even if the manufacturer differs**
- Document all 3 stages: purchase → installation → operation check
