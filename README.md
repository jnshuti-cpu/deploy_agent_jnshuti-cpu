# Student Attendance Tracker 

# How to Run the Script

1. Clone the repository:
```bash
   git clone https://github.com/jnshuti-cpu/deploy_agent_jnshuti-cpu.git
   cd deploy_agent_jnshuti-cpu
```

2. Place these source files in the same directory as `setup_project.sh`:
   - `attendance_checker.py`
   - `assets.csv`
   - `config.json`
   - `reports.log`

3. Make the script executable:
```bash
   chmod +x setup_project.sh
```

4. Run the script:
```bash
   ./setup_project.sh
```

5. When prompted, enter a project identifier (e.g. `sem1_2026`).

6. Choose whether to update the attendance thresholds (Warning default: 75%, Failure default: 50%).

# How to Trigger the Archive Feature

The archive feature is triggered by pressing **Ctrl+C** at any point during script execution.

When interrupted, the script will:
- Bundle the current project state into `attendance_tracker_{input}_archive.tar.gz`
- Delete the incomplete project directory
- Exit cleanly

# Project Structure Created
