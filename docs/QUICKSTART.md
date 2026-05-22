# Quick Start - Job Hunting Tracker

## 30-Second Setup

```bash
# 1. Navigate to project
cd JobHunting-Tracker

# 2. Make scripts executable
chmod +x scripts/job-tracker.sh scripts/generate-excel.vbs

# 3. Run the tracker
bash scripts/job-tracker.sh
```

## First Steps

### Add Your First Job
1. Select option **1. Add new job**
2. Enter job details when prompted:
   - Job name: "Senior Developer" 
   - Title: "Senior Software Engineer"
   - Company: "TechCorp"
   - Status: Press **1** for Pending
   - Notes: "Applied via LinkedIn"

### View Your Jobs
1. Select option **2. View all jobs**
2. See formatted table of all tracked applications

### Generate Excel Report
1. Select option **5. Generate Excel report**
2. Excel file auto-opens showing professional formatted report
3. Files saved in `data/Job_Tracker_YYYYMMDD_HHMMSS.xlsx`

### Update Job Status
1. Select option **3. Update job status**
2. Enter Job ID (shown in view list)
3. Choose new status: 1=Pending, 2=Rejected, 3=Approved
4. Last Updated timestamp auto-refreshes

## Menu Shortcuts

| Option | Action |
|--------|--------|
| **1** | Add new job |
| **2** | View all jobs |
| **3** | Update status |
| **4** | Delete job |
| **5** | Generate Excel |
| **6** | Exit |

## Data Files

- **Main database**: `data/jobs.csv`
- **Audit trail**: `data/tracker.log`
- **Reports**: `data/Job_Tracker_*.xlsx`

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Script not found" | Run `chmod +x scripts/job-tracker.sh` |
| Excel won't generate | Ensure Excel is installed; check `data/tracker.log` |
| Can't delete job | Enter correct Job ID shown in "View all jobs" |

## See Full Documentation

For detailed guide: [JOB-TRACKER-GUIDE.md](JOB-TRACKER-GUIDE.md)

---
Ready to track your job hunt! 🚀
