# Student Attendance Tracker 

# How to Run the Script

1. Clone the repository:
```bash
   git clone https://github.com/jnshuti-cpu/deploy_agent_jnshuti-cpu.git
   cd deploy_agent_jnshuti-cpu
```

2. Make the script executable:
```bash
   chmod +x setup_project.sh
```

3. Run the script:
```bash
   ./setup_project.sh
```

4. When prompted, enter a project identifier (e.g. `sem1_2026`).

5. Choose whether to update the attendance thresholds:
   - Warning default: 75%
   - Failure default: 50%
   - Input is validated — only numeric values between 1 and 100 are accepted

# Error Handling

- If the project directory already exists, the script exits with an error and asks you to choose a different identifier
- If folder permissions are denied, the script exits cleanly without leaving partial files
- Invalid threshold inputs are rejected with a warning and re-prompted

# How to Trigger the Archive Feature

Press **Ctrl+C** at any point during script execution.

The script will:
1. Bundle the current project state into `attendance_tracker_{input}_archive.tar.gz`
2. Delete the incomplete project directory
3. Exit cleanly

# Project Structure Created
