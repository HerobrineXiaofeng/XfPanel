# Security Policy

## Supported Versions
We provide security updates only for the latest stable version.

| Version Status | Supported |
|----------------|-----------|
| Latest | ✅ Yes |
| Alpha / Beta / RC | ⚠️ Partial (unstable, self-use only) |
| Old | ❌ No |

## Reporting a Vulnerability
All security bugs and vulnerabilities are accepted via **GitHub Issues** in this repository.

### How to Report
1. Open a new Issue: https://github.com/HerobrineXiaofeng/XfPanel/issues/new
2. Use the **Bug Report** template
3. Add label: `security`
4. Include:
   - Affected version
   - Steps to reproduce
   - Expected vs actual behavior
   - Logs / screenshots (if available)

### Response Process
- Acknowledge within **48 hours**
- Triage and assess severity
- Develop and test fixes
- Release patched version
- Close the issue after fix

## Security Fix Priority
- **Critical**: RCE, privilege escalation, auth bypass, data leak → urgent fix
- **Medium/Low**: Minor flaws → routine update
- No backports for legacy versions

## Out-of-Scope
- User misconfiguration
- Modified source code issues
- Local physical access risks
- Third-party dependency issues (report upstream)

## Responsible Disclosure
- Allow maintainers reasonable time to fix before public disclosure
- No malicious exploitation or unauthorized access
- Follow community rules

## License
This project is licensed under **GPLv3**.
Code provided **AS-IS**, no warranty.
