# 🛡️ Analysis of Stateful Inspection & IPS Mitigation 
### *A Technical Audit of Residential Gateway Security*

## 📖 1. Executive Summary
This repository documents a black-box security assessment performed on a residential network gateway (`10.10.0.1`). The project demonstrates the identification of a **Debian-based Apache stack**, the discovery of **HTTP 302 redirect vulnerabilities**, and the successful navigation of a **Stateful Intrusion Prevention System (IPS)**. 

The audit highlights the real-world application of **Operational Security (OPSEC)** and remediation techniques used to bypass automated hardware-level blacklisting on an Apple Silicon M4 environment.

---

## 🛠️ 2. Environment & Toolset
* **Host Machine:** MacBook Pro (Apple Silicon M4)
* **OS:** Kali Linux (Zsh Shell) / macOS Sequoia
* **Tools:** * `Curl` (Header analysis and protocol spoofing)
  * `Macchanger` (Hardware identity randomization)
  * `Systemd/Systemctl` (Network service management)
  * `Zsh/Bash` (Scripting and automation)

---

## 🔍 3. The Technical Walkthrough

### Phase 1: Service Discovery & Reconnaissance
Initial scanning of the gateway identified active management ports. While standard ports were hardened, Port **8090** provided a unique entry point.

* **Action:** `curl -I http://10.10.0.1:8090/`
* **Result:** The server returned an **HTTP 302 Found** status.
* **Finding:** The system uses a "Transparent Redirect" to push users to a management portal located at `/superclick/index.php`.

### Phase 2: Banner Grabbing & Fingerprinting
By analyzing HTTP headers, the following technology stack was confirmed:
* **Server:** `Apache/2.4.62 (Debian)`
* **Logic:** PHP-based administration portal.
* **Security Layer:** Signature-based filtering active (ignoring non-browser User-Agents).

### Phase 3: Defensive Trigger Analysis (The "Lockout")
The audit identified that the gateway employs **Stateful Packet Inspection (SPI)**. 
* **The Trigger:** Rapid-fire requests from CLI tools were flagged as "Non-Human" traffic signatures.
* **The Consequence:** The IPS triggered a **MAC-based Blacklist**, dropping all packets from the host for 300 seconds.
* **The Log:** The server returned: `"Operation not authorized. Request logged."`

---

## ⚡ 4. Remediation & OPSEC (The "Ghost" Protocol)
To restore connectivity and continue the audit anonymously, a multi-stage recovery protocol was executed to bypass the hardware-level "shun" and clear local footprints.

### Step 1: MAC Address Spoofing (Identity Rotation)
The MAC address was randomized to mimic a new device, bypassing the router's hardware-level blacklist.
```bash
sudo ifconfig eth0 down
sudo macchanger -r eth0
sudo ifconfig eth0 up
```

### Step 2: DNS Cache Remediation (Path Recovery)
The host machine (M4 Mac) cache was flushed to clear the "poisoned" blocked status
of the portal and force a fresh resolution.
Executed on macOS Host Terminal
```bash
sudo dscacheutil -flushcache; sudo killall -9 mDNSResponder
```

### Step 3: Session History Sanitization (Footprint Removal)
Truncate the Zsh history and clear session memory to remove command-line artifacts.
```bash
echo > ~/.zsh_history   # Overwrite history file with null value
fc -p                   # Clear current session buffer (Zsh)
```

### Step 4: User-Agent Obfuscation
 Send verification requests mimicking a mobile browser to bypass signature filters.
 ```bash
curl -A "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)" http://10.10.0.1:8090/
```

## 📊 5. Final Findings & Risk Assessment

| Component | Status | Finding |
|------------|---------|----------|
| **Gateway UI** | Exposed | Administrative path `/superclick/` revealed via 302 redirects. |
| **IPS Posture** | Robust | Effectively blacklists automated CLI tools within 10–15 requests. |
| **OS Version** | Current | Apache 2.4.62 on Debian (Modern/Patched). |
| **Protocol Warning** | Medium | Protocol mismatch on SSL ports triggers 400 Bad Request. |

## 🏁 6. Conclusion
Success in hardened environments requires a deep understanding of **protocol analysis** and **identity management**. This audit confirms that while the gateway is resilient against automated probes, it remains susceptible to **manual reconnaissance** conducted via protocol-compliant spoofing and hardware identity rotation.



