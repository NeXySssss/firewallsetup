# UFW Firewall Setup with Cloudflare IP Sync

Secure your server with UFW firewall. Restrict access to ports 80/443 only from Cloudflare IPs and set a custom SSH port.

## Quick Start

Run script with default SSH port (interactive input):
```bash
curl -s https://raw.githubusercontent.com/NeXySssss/firewallsetup/refs/heads/main/setup.sh | bash
```

Run script with custom SSH port (e.g., 2223):
```bash
curl -s https://raw.githubusercontent.com/NeXySssss/firewallsetup/refs/heads/main/setup.sh | bash -s -- 2223
```
