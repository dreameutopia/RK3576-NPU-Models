# Security Policy

> 📖 **Other Languages**: [中文安全政策](./SECURITY_zh.md)

## Supported Versions

We provide security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| Latest  | ✅ |
| Older   | ❌ |

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly.

### How to Report

1. **Do NOT open a public GitHub Issue** for security vulnerabilities
2. Email the maintainers directly or use [GitHub's private vulnerability reporting](https://github.com/dreameutopia/RK3576-NPU-Models/security/advisories/new)
3. Include the following information:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment** within 48 hours
- **Status update** within 7 days
- **Fix timeline** depends on severity:
  - Critical: within 7 days
  - High: within 14 days
  - Medium/Low: next release cycle

## Security Best Practices

When using this project:

- **Model files**: Only download models from trusted sources
- **Shell scripts**: Review scripts before running with elevated privileges
- **Network**: Models run locally; no data is sent to external servers
- **Dependencies**: Keep rknn-toolkit2 and system packages up to date
