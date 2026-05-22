# Job Hunting Tracker 🎯

A secure, interactive bash-based job application tracker with automated Excel report generation. Built with DevSecOps best practices.

## 🚀 Quick Start

```bash
# Clone/navigate to project
cd JobHunting-Tracker

# Make executable
chmod +x scripts/job-tracker.sh

# Run tracker
bash scripts/job-tracker.sh
```

**First run?** See [QUICKSTART.md](docs/QUICKSTART.md) for 5-minute tutorial.

## ✨ Features

| Feature | Details |
|---------|---------|
| **📝 Add Jobs** | Track job applications with name, title, company, status, notes |
| **📊 View Jobs** | Formatted table view of all tracked applications |
| **🔄 Update Status** | Change job status (Pending → Rejected/Approved) |
| **🗑️ Delete** | Remove jobs with confirmation |
| **📈 Excel Reports** | Auto-generate professional Excel reports with formatting |
| **📋 Audit Log** | Timestamped record of all actions |
| **🔒 Secure** | Hardened bash script with validated inputs |

## 🏗️ System Architecture

```
JobHunting-Tracker/
├── scripts/
│   ├── job-tracker.sh          # Main interactive tracker (hardened bash)
│   ├── generate-excel.vbs       # Excel report generator (VBS)
│   ├── pre-commit-hook.sh       # Pre-commit validation
│   └── ...
├── data/
│   ├── jobs.csv                # Job database (auto-created)
│   ├── tracker.log             # Audit trail (auto-created)
│   └── Job_Tracker_*.xlsx      # Generated reports
├── docs/
│   ├── QUICKSTART.md           # 30-second setup
│   ├── JOB-TRACKER-GUIDE.md    # Comprehensive guide
│   └── README.md               # This file
└── .github/
    └── skills/
        └── bash-hardening/     # Security audit tools
```

## 📖 Documentation

| Document | Purpose |
|----------|---------|
| **[QUICKSTART.md](docs/QUICKSTART.md)** | 30-second setup & menu reference |
| **[JOB-TRACKER-GUIDE.md](docs/JOB-TRACKER-GUIDE.md)** | Complete implementation guide |
| **[SECURITY.md](docs/SECURITY.md)** | Security architecture & hardening details |

## 🛠️ Usage

### Interactive Mode
```bash
bash scripts/job-tracker.sh
```

Menu options:
```
1. Add new job              (Create new application record)
2. View all jobs            (Display all tracked jobs)
3. Update job status        (Change job status)
4. Delete job               (Remove job record)
5. Generate Excel report    (Create formatted Excel file)
6. Exit                     (Close application)
```

### Excel Report Generation
```bash
# Generate and open in Excel
# Select option 5 from main menu
# Report auto-saved to: data/Job_Tracker_YYYYMMDD_HHMMSS.xlsx
```

### Data Files
- **CSV**: `data/jobs.csv` (comma-separated values, quoted fields)
- **Log**: `data/tracker.log` (timestamped audit trail)
- **Reports**: `data/Job_Tracker_*.xlsx` (Excel workbooks)

## 🔒 Security Features

### Hardened Bash Implementation
```bash
✓ set -euo pipefail       # Exit on errors, undefined variables
✓ umask 0077              # Restrictive file permissions (user only)
✓ trap error handling     # Catch runtime errors
✓ Quoted variables        # Prevent word splitting, globbing
✓ Input validation        # Check empty, allowed values
✓ Sanitization            # Remove dangerous characters
✓ Secure temp files       # mktemp with cleanup
✓ No hardcoded secrets    # Environment-based configuration
✓ Command injection protection  # No eval, safe $() usage
```

### Audit Trail
All actions logged with timestamps:
```
[2026-05-22 10:30:45] Script started
[2026-05-22 10:31:12] Added job: ID=1, Name=Senior Dev, Status=Pending
[2026-05-22 10:35:00] Updated Job ID=1 to Status=Approved
[2026-05-22 10:40:30] Generated Excel report: Job_Tracker_20260522_104030.xlsx
```

### Pre-commit Security Check
Enforce bash hardening before commits:
```bash
# Install hook
cp scripts/pre-commit-hook.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Hook runs automatically on: git commit
```

## 📊 Data Format

### CSV Structure
```csv
ID,Job Name,Title,Company,Status,Date Added,Last Updated,Notes
1,"Senior Dev","Senior Developer","TechCorp",Pending,2026-05-22 10:30:45,2026-05-22 10:30:45,"Applied online"
2,"Marketing","Marketing Manager","BrandCo",Approved,2026-05-21 14:22:10,2026-05-22 09:15:30,"Offer received"
```

### Excel Report Features
- ✓ Formatted header (bold, blue background, white text)
- ✓ Alternating row colors (light gray for even rows)
- ✓ Auto-fitted columns
- ✓ Data validation dropdown for Status column
- ✓ Sortable table format
- ✓ Professional styling (TableStyleMedium2)

## 🔧 Installation

### Requirements
- **Bash**: 4.0+ (Linux, macOS, Windows with Git Bash/WSL)
- **Excel**: 2010+ or compatible spreadsheet app
- **Windows**: cscript.exe (built-in)

### Setup Steps
```bash
# 1. Clone repository
git clone <repo-url> JobHunting-Tracker
cd JobHunting-Tracker

# 2. Make scripts executable
chmod +x scripts/*.sh

# 3. Run first time
bash scripts/job-tracker.sh

# Data directory created automatically:
# - data/jobs.csv (database)
# - data/tracker.log (audit log)
```

### Optional: Git Hook Integration
```bash
# Copy pre-commit hook
cp scripts/pre-commit-hook.sh .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Now bash scripts are validated before commit
git add scripts/my-script.sh
git commit -m "Add script"  # Runs security checks automatically
```

## 🚀 Workflow Example

### Day 1: Find a Job
```bash
$ bash scripts/job-tracker.sh

1. Add new job
Enter job name: Senior Software Engineer
Enter job title: Senior Dev
Enter company name: TechCorp Inc
Select Status: 1=Pending
Enter notes: Great opportunity
✓ Job added successfully (ID: 1)
```

### Day 3: Get Rejected
```bash
3. Update job status
Enter Job ID to update: 1
Select new status: 2=Rejected
✓ Job status updated successfully
```

### Day 5: Check All Applications
```bash
2. View all jobs
ID   Job Name                Title                    Company          Status
1    Senior Software Eng     Senior Dev              TechCorp         Rejected
2    Marketing Lead          Head of Marketing       BrandCo          Pending
3    Product Manager         Senior PM               StartupXYZ       Pending
```

### Week 2: Generate Report
```bash
5. Generate Excel report
✓ Excel report generated successfully
Report saved to: data/Job_Tracker_20260522_143000.xlsx
Open report in Excel? (y/n): y
```

## 🔍 Security Audit

### Run Security Checks
```bash
# Full audit
bash .github/skills/bash-hardening/scripts/audit-bash.sh ./scripts/job-tracker.sh

# Validation
bash .github/skills/bash-hardening/scripts/validator.sh ./scripts/job-tracker.sh

# Linting (if shellcheck installed)
shellcheck -x ./scripts/job-tracker.sh
```

### Security Checklist
- [x] `set -euo pipefail` enabled
- [x] All variables quoted
- [x] Input validation gates
- [x] Secure file permissions
- [x] Error handling
- [x] No hardcoded secrets
- [x] Audit logging
- [x] Safe temp files

## 🛠️ Troubleshooting

### Script won't run
```bash
# Check permissions
ls -la scripts/job-tracker.sh

# Make executable
chmod +x scripts/job-tracker.sh

# Run with explicit bash
bash scripts/job-tracker.sh
```

### Excel generation fails
```bash
# Check if Excel is installed (Windows)
where excel.exe

# Check log for errors
cat data/tracker.log

# Test VBS manually (Windows)
cscript.exe scripts/generate-excel.vbs data/jobs.csv test.xlsx
```

### Data corruption
```bash
# View raw CSV
cat data/jobs.csv

# Check integrity
bash -n scripts/job-tracker.sh

# Restore from backup
cp backups/jobs_backup.csv data/jobs.csv
```

## 🔄 Backup & Recovery

### Manual Backup
```bash
# Backup single file
cp data/jobs.csv "backups/jobs_$(date +%Y%m%d_%H%M%S).csv"

# Backup all data
tar -czf "backup_$(date +%Y%m%d).tar.gz" data/
```

### Scheduled Backups (Unix/Linux)
```bash
# Add to crontab
0 2 * * * tar -czf ~/backups/jobs_$(date +\%Y\%m\%d).tar.gz ~/JobHunting-Tracker/data/
```

## 📈 Enhancement Ideas

- [ ] Search/filter functionality
- [ ] Salary tracking
- [ ] Interview scheduling
- [ ] Email integration
- [ ] Cloud backup (AWS S3, Azure)
- [ ] Web dashboard
- [ ] Mobile app
- [ ] Slack notifications

## 📝 Contributing

To improve the tracker:

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/enhancement`
3. **Test** with hardening tools
4. **Submit** pull request

See [.github/CONTRIBUTING.md](.github/CONTRIBUTING.md) for details.

## 🔐 Security Policy

For security vulnerabilities:
1. **Do NOT** open public issues
2. **Email** security team privately
3. Provide detailed reproduction steps
4. Allow 48 hours for response

See [SECURITY.md](docs/SECURITY.md) for full policy.

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

---

## 🆘 Getting Help

| Resource | Purpose |
|----------|---------|
| [QUICKSTART.md](docs/QUICKSTART.md) | First-time setup |
| [JOB-TRACKER-GUIDE.md](docs/JOB-TRACKER-GUIDE.md) | Complete documentation |
| [Issues](../../issues) | Report bugs |
| [Discussions](../../discussions) | Ask questions |

---

**Built with ❤️ for job hunters everywhere**

Happy tracking! 🚀
