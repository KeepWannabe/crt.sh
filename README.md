# crt.sh

## Description
The crt.sh is a Bash-based Scraper tool developed for penetration testers and bug bounty hunters to efficiently scrape crt.sh—a certificate transparency search engine. It automates the retrieval and analysis of SSL/TLS certificates and associated domains, aiding in reconnaissance activities during security assessments.

## Usage
### Requirements
 - Bash environment
 - Internet connectivity for querying crt.sh

### Installation and Setup
```bash
git clone https://github.com/KeepWannabe/crt.sh
cd crt.sh
bash crt.sh
```

### Options
```bash
-h, --help: Display help information.
-d DOMAIN, --domain=DOMAIN: Search by Domain Name (*required).
-org ORG-NAME, --organization=ORG-NAME: Search by Organization Name (*required).
-s, --silent: Enable silent mode, suppressing banners and additional output.
```

### Examples
```bash
# Search by domain example.com
bash crt.sh -d example.com

# Search by organization 'YourOrgName'
bash crt.sh --organization YourOrgName

# Search by domain example.com but silent mode active
bash crt.sh -d example.com -s
```

[![asciicast](https://asciinema.org/a/WzxlWuJSpF3YgwdOPQQ4pOioH.svg)](https://asciinema.org/a/WzxlWuJSpF3YgwdOPQQ4pOioH)

## Contributions
Contributions and feedback are welcome! Feel free to raise issues, suggest improvements, or submit pull requests to enhance the tool's functionality.

## Disclaimer
This tool is intended for educational and security assessment purposes only. Usage against systems without proper authorization may be illegal. Users are responsible for complying with applicable laws and regulations.
