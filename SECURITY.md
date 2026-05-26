# Security Policy

## Supported Versions
We provide security patch support for the following project versions.
All outdated versions are **unsupported and will not receive security updates**.

| Version Status | Supported |
|----------------|-----------|
| Latest | ✅ Yes |
| Alpha / Beta / RC | ⚠️ Partial (unstable, self-use only) |
| Old | ❌ No |

Only the **latest stable version** is guaranteed for security maintenance.

## Reporting a Vulnerability
**Do not open public issues for security vulnerabilities.**

If you find any security flaws, exploits, or potential risks in this project, please report privately via email:
`support@xfpanel.com`

### What to include in your report
- Affected version and component
- Clear reproduction steps
- Vulnerability type and impact severity
- Proof-of-concept (if available, optional)

### Response Process
- **48 hours initial reply** to confirm receipt
- Vulnerability assessment and severity classification
- Patch development, testing and release
- Public disclosure after fix is deployed

## Security Update Guidelines
- Critical vulnerabilities (RCE, privilege escalation, authentication bypass, data leak) will be fixed urgently.
- Medium/Low issues will be fixed in routine updates.
- No backports for deprecated versions.

## Out-of-Scope Issues
The following are **not considered valid security vulnerabilities**:
1. User-incorrect server/software configuration
2. Vulnerabilities from outdated third-party systems or dependencies (fixed upstream)
3. Local physical access risks under user’s own control
4. Issues caused by manually modified source code

## Responsible Disclosure
We strictly follow responsible disclosure principles:
- Allow maintainers reasonable time to fix vulnerabilities before public disclosure.
- Malicious exploitation, unauthorized access or data abuse is strictly prohibited.

## Dependency Maintenance
This project continuously upgrades dependencies to resolve known CVE risks.
Users are strongly recommended to always use the latest stable version.

## License Disclaimer
Project licensed under **GPLv3**.
All code is provided **AS-IS** without warranty.
Maintainer holds no liability for improper deployment or unauthorized modification risks.
