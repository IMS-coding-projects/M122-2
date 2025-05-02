# B-Backup

![Project Status](https://img.shields.io/badge/Status-Decommissioned-darkblue.svg)

B-Backup is a Bash tool designed to simplify the process of backing up files and directories. It offers a range of features to ensure seamless backup and recovery of data, making it a reliable and user-friendly solution for managing backups.

---

## Features

B-Backup provides the following features:

- **Backup**: Back up files and directories to a hidden location on the user's system.
- **Encryption**: Encrypt backups using PKZIP encryption.
- **Compression**: Compress backups using DEFLATE compression.
- **Deletion**: Optionally delete original files after backup.
- **Restore**: Restore backups to the original or a custom location.
- **Export**: Export backups to a custom location.
- **Logging**: Log all actions for future reference.
- **List Backups**: View all backups created by B-Backup.
- **Delete Backups**: Remove individual backups.
- **Search Files**: Search for specific files within backups.
- **Error Handling**: Gracefully handle errors with helpful messages.
- **Help Menu**: Access detailed help directly from the script.

---

## Minimum Requirements

- **Operating System**: Tested on **Ubuntu 20.04** and **Kali Linux 2024.1**.
- **Bash Version**: Minimum tested version is **5.1.16**.
- **Dependencies**: 
  - `zip`, `unzip`, `mv`, `rm`, `ls`, `grep`, `echo`, `read`, `date`, `cat`, `printf` (all standard tools available on most Linux distributions).

> **Note**: B-Backup **cannot** run with root privileges. Running the script as root will result in an error message and termination.

---

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/IMS-coding-projects/M122-2.git
   ```
2. Navigate to the project directory:
   ```bash
   cd M122-2
   ```
3. Make the script executable:
   ```bash
   chmod +x B-Backup.sh
   ```

---

## Usage

Run the script using the following command:
```bash
B-Backup.sh
```

### Main Menu Options:
1. **Manage Backups**: Create, restore, delete, or search backups.
2. **Help**: Access detailed documentation.
3. **Display Logs**: View the log file.
4. **Export All Backups**: Export all backups to a specified location.
5. **Uninstall**: Remove all backups and logs.
6. **Exit**: Exit the script.

---

## Testing

The script has been rigorously tested on various Linux distributions and scenarios. Below are some key test cases:

| Test Number | Description                                                                 | Expected Outcome | Result |
|-------------|-----------------------------------------------------------------------------|------------------|--------|
| 1           | Start the script for the first time.                                       | Creates necessary folders and files. | ✅ Pass |
| 2           | Create a backup with encryption and compression.                          | Backup is created successfully. | ✅ Pass |
| 3           | Restore a backup to the original location.                                | Backup is restored successfully. | ✅ Pass |
| 4           | Search for a specific file in a backup.                                   | File is found and can be extracted. | ✅ Pass |
| 5           | Run the script with root privileges.                                      | Script exits with an error message. | ✅ Pass |

For a full list of tests, refer to the [Documentation](https://github.com/IMS-coding-projects/M122-2/blob/main/Writerside/topics/Documentation.md).

---

## Screenshots

### Main Menu
![Main Menu](/images/menu-new.png)

### Backup Management
![Backup Management](/images/manage-menu.png)

---

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository.
2. Create a new branch:
   ```bash
   git checkout -b feature-name
   ```
3. Commit your changes:
   ```bash
   git commit -m "Add feature-name"
   ```
4. Push to your branch:
   ```bash
   git push origin feature-name
   ```
5. Open a pull request.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.