#!/bin/bash
##################################################################################################
# Author: Group 2
# Date: 03.04.2024
# Purpose: Backup script
# Version: 1.0.1.0
# Description: This script is used to create, list, delete backups and search for files within backups.
###################################################################################################

# Variables
# informative project-wide variables
project_name="B-Backup"
version="1.0.1.0"
description="This script is used to create, list, delete backups and search for files in backups."
# project-wide variables
homefolder="/home/$(whoami)//.$project_name"
logfile="$homefolder/0log.dll"
# colors
RED='\033[1;31m'
GREEN='\033[1;32m'
NC='\033[0m'

# Functions

# Manage Backups
create_backup() {
    pre_log "LOG: Backup Creating has been started"
    clear
    printf "${GREEN}Preparing for Backup"
    i=0
    while [ $i -lt 4 ]; do
    sleep 0.6
    printf "."
    ((i++))
    done
    printf "${NC}\n"
    clear
    current_dir=$(pwd)
    backup_name=""
    until [ ${#backup_name} -ne 0 ]
    do
      printf "What do you want to call this Backup?: "
      read -r backup_name
    done
    pre_log "LOG: New Backup has this name: $backup_name"

    curbinh="$homefolder/backup-$backup_name"
    mkdir -p $curbinh
    pre_log "LOG: Created new folder: $backup_name"
    remove_after_zip=""
    until [[ $remove_after_zip == "y" ]] || [[ $remove_after_zip == "n" ]]
    do
      printf "Do you want to remove the files from disk after they have been backuped? (y/n): "
      read -r remove_after_zip
      case $remove_after_zip in
          y) printf "Understood, the files are going to be removed.\n\n";;
          n) printf "Understood, the files are not going to be removed.\n\n";;
          *) printf "${RED}Invalid Input, please enter y or n.${NC}\n\n"; pre_log "LOG: Invalid Input during questioning for Backup";;
      esac
    done

    encrypted_backup=""
    until [[ $encrypted_backup == "y" ]] || [[ $encrypted_backup == "n" ]]
    do
      printf "Do you want to encrypt the backup? (y/n): "
      read -r encrypted_backup
      case $encrypted_backup in
          y) printf "Understood, the Backups are going to be encrypted.\n\n";;
          n) printf "Understood, the Backups are not going to be encrypted.\n\n";;
          *) printf "${RED}Invalid Input, please enter y or n.${NC}\n\n"; pre_log "LOG: Invalid Input during questioning for Backup";;
      esac
    done

    compressed_backup=""
    until [[ $compressed_backup == "y" ]] || [[ $compressed_backup == "n" ]]
    do
      printf "Do you want to compress the backup? (y/n): "
      read -r compressed_backup
      case $compressed_backup in
          y) printf "Understood, the Backups are going to be compressed.\n\n";;
          n) printf "Understood, the Backups are not going to be compressed.\n\n";;
          *) printf "${RED}Invalid Input, please enter y or n.${NC}\n\n"; pre_log "LOG: Invalid Input during questioning for Backup";;
      esac
    done

    valid_path="0"
    until [[ valid_path -eq 1 ]]; do
      printf "Provide the path of the file or directory you want to backup (start from root): "
      read -r path
      if [[ -d "$path" ]]; then
        type="d"
        valid_path="1"
        cd "$path"
        path4log="$path"
      elif [[ -f "$path" ]]; then
        type="f"
        valid_path="1"
        cd "$(dirname "$path")"
        path4log="$path"
      else
        printf "${RED}Invalid path. Please provide a valid path.${NC}\n\n"
        path=""
      fi
    done

    clear
    printf "Are you sure you want to create the backup with the following settings?\n\n"
    printf "Backup Name: $backup_name\n"
    printf "Backup Path: $path\n"
    printf "Remove after zip: $remove_after_zip\n"
    printf "Encrypted Backup: $encrypted_backup\n"
    printf "Compressed Backup: $compressed_backup\n"
    choices=""
    until [[ $choices == "y" ]] || [[ $choices == "n" ]]
    do
      printf "\nPlease confirm (y/n): "
      read -r choices
      case $choices in
          y) printf "\nContinuing.\nPlease follow the Instructions from ZIP:\n"; sleep 3;;
          n) printf "Returning to menu\n"; pre_log "LOG: Backup Cancelled; Returning to menu"; sleep 3; return;;
          *) printf "${RED}Invalid Input, please enter y or n.${NC}\n"; pre_log "LOG: Invalid Input during questioning for Backup";;
      esac
    done
    zipname="$curbinh/$backup_name.zip"
    if [[ $type == "d" ]]; then
        backupparam=$compressed_backup$encrypted_backup$remove_after_zip
        case $backupparam in
            nnn) zip -v -r $zipname $path ;;
            nny) zip -v -r -9 $zipname $path ;;
            nyn) zip -v -r -e $zipname $path ;;
            nyy) zip -v -r -9 -e $zipname $path ;;
            ynn) zip -v -r -m $zipname $path ;;
            yny) zip -v -r -9 -m $zipname $path ;;
            yyn) zip -v -r -e -m $zipname $path ;;
            yyy) zip -v -r -9 -e -m $zipname $path ;;
        esac
    elif [[ $type == "f" ]]; then
        backupparam=$compressed_backup$encrypted_backup$remove_after_zip
        case $backupparam in
            nnn) zip -v $zipname $path ;;
            nny) zip -v -9 $zipname $path ;;
            nyn) zip -v -e $zipname $path ;;
            nyy) zip -v -9 -e $zipname $path ;;
            ynn) zip -v -m $zipname $path ;;
            yny) zip -v -9 -m $zipname $path ;;
            yyn) zip -v -e -m $zipname $path ;;
            yyy) zip -v -9 -e -m $zipname $path ;;
        esac
    fi
    exit_status=$?
    if [ $exit_status -eq 0 ]; then
        echo "$path4log" > "$curbinh/$project_name.info.dll"
        cd "$current_dir"
        pre_log "LOG: Backup was created with the following settings: $choices"
        printf "${GREEN}Backup was successfully created.${NC}\n\n"
    else
        pre_log "LOG: ZIP creation failed with the following settings: $choices"
        printf "${RED}Backup creation failed.${NC}\n"
        printf "${RED}ZIP reported an error.\nPlease read ZIP's error message above.${NC}\n\n"
        rm -rf $curbinh
    fi

    printf "Do you want to generate a report? (y/n): "
    read -r choices
    if [[ $choices == "n" ]]; then
      printf "No report will be generated\n\n"
      pre_log "LOG: Backup report cancelled; Returning to menu"
    else
      pre_log "LOG: Generating report"
      printf "Generating report...\n"
      echo -e "$project_name Report ${date}\n" > "/home/$(whoami)/Desktop/$project_name-Report_Create-Backup.txt"
      echo -e "====================================================\n" >> "/home/$(whoami)/Desktop/$project_name-Report_Create-Backup.txt"
      echo -e "Backup Name: $backup_name\n" >> "/home/$(whoami)/Desktop/$project_name-Report_Create-Backup.txt"
      echo -e "Backup Path: $path\n" >> "$logfile" >> "/home/$(whoami)/Desktop/$project_name-Report_Create-Backup.txt"
      echo -e "Should $project_name remove the file/s after zipping?: $remove_after_zip\n" >> "/home/$(whoami)/Desktop/$project_name-Report_Create-Backup.txt"
      echo -e "Encrypted Backup: $encrypted_backup\n" >> "/home/$(whoami)/Desktop/$project_name-Report_Create-Backup.txt"
      echo -e "Compressed Backup: $compressed_backup\n" >> "/home/$(whoami)/Desktop/$project_name-Report_Create-Backup.txt"
      echo -e "Backup was created with the following settings: $backupparam\n" >> "/home/$(whoami)/Desktop/$project_name-Report_Create-Backup.txt"
      echo -e "====================================================\n" >> "/home/$(whoami)/Desktop/$project_name-Report_Create-Backup.txt"
      echo -e "Result:" >> "/home/$(whoami)/Desktop/$project_name-Report_Create-Backup.txt"
        if [ $exit_status -eq 0 ]; then
          echo -e "Backup was successfully created.\n" >> "/home/$(whoami)/Desktop/$project_name-Report_Create-Backup.txt"
        else
          echo -e "Backup creation failed.\n" >> "/home/$(whoami)/Desktop/$project_name-Report_Create-Backup.txt"
          echo -e "ZIP reported an error.\nPlease refer to ZIP's error message\n" >> "/home/$(whoami)/Desktop/$project_name-Report_Create-Backup.txt"
        fi
        pre_log "LOG: Report was generated"
        printf "Report generated, check your desktop.\n\n"
      fi
    pre_log "LOG: Exiting Backup Creation"
    read -n 1 -s -r -p "Press any key to continue..."
    choices=""
    backupparam=""
    remove_after_zip=""
    encrypted_backup=""
    compressed_backup=""
    backup_name=""
    path=""
    path4log=""
    valid_path=""
    current_dir=""
    curbinh=""
    exit_status=""
    type=""
}

restore_backup() {
    pre_log "LOG: Restore Backup has been started"
    clear
    printf "Listing existing backups:\n"
    ls $homefolder/ | grep -v "0log.dll"
    printf "\nWhich backup do you want to restore? (if you want to exit to menu, hit enter | after restoring a backup, the backup will still be kept in the hidden folder. To remove the backup from $project_name)\nEnter the backup name: "
    read -r backup_name
    if [ -f "$homefolder/backup-$backup_name/$backup_name.zip" ]; then
        report_1="Backup $backup_name exists."
        printf "Do you want to restore the backup $backup_name to the original path? (y/n): "
        read -r choices
        if [[ $choices == "n" ]]; then
          report_2="Backup $backup_name was NOT restored to the original path: $original_path"
          printf "Do you want to extract the backup to a custom path? (y/n): "
          read -r choices
          if [[ $choices == "n" ]]; then
            report_3="Backup $backup_name was not restored at all."
            printf "Returning to menu\n"
            pre_log "LOG: Backup extract cancelled; Returning to menu"
            return
          fi
          printf "Enter the path where you want to extract the backup: "
          read -r custom_path
          unzip "$homefolder/backup-$backup_name/$backup_name.zip" -d "$custom_path"
          pre_log "LOG: Backup $backup_name was extracted to custom path: $custom_path"
          printf "Backup $backup_name was extracted to custom path: $custom_path\n"
          report_3="Backup $backup_name was restored to a custom path: $custom_path"
          return
        fi
        printf "Restoring backup $backup_name to the original path\n"
        original_path=$(cat "$homefolder/backup-$backup_name/$project_name.info.dll")
        unzip "$homefolder/backup-$backup_name/$backup_name.zip" -d "$original_path"
        pre_log "LOG: Backup $backup_name was restored to the original path"
        printf "${GREEN}Backup $backup_name was restored to the original path{NC}\n"
        report_2="Backup $backup_name was restored to the original path: $original_path"
    else
        report_1="Backup $backup_name did not exist."
        pre_log "LOG: Backup $backup_name does not exist."
        printf "${RED}Backup $backup_name does not exist.${NC}\n\n"
    fi
    printf "Do you want to generate a report? (y/n): "
    read -r choices
    if [[ $choices == "n" ]]; then
      printf "No report will be generated\n\n"
      pre_log "LOG: Backup report cancelled; Returning to menu"
    else
      pre_log "LOG: Generating report"
      printf "Generating report...\n"
      echo -e "$project_name Report ${date}\n" > "/home/$(whoami)/Desktop/$project_name-Report_Restore-Backup.txt"
      echo -e "====================================================\n" >> "/home/$(whoami)/Desktop/$project_name-Report_Restore-Backup.txt"
      $report_1 >> "/home/$(whoami)/Desktop/$project_name-Report_Restore-Backup.txt"
      report_2 >> "/home/$(whoami)/Desktop/$project_name-Report_Restore-Backup.txt"
      report_3 >> "/home/$(whoami)/Desktop/$project_name-Report_Restore-Backup.txt"
      pre_log "LOG: Report was generated"
      printf "Report was generated, check your desktop.\n\n"
    fi

    choices=""
    backup_name=""
    report_1=""
    report_2=""
    report_3=""
    original_path=""
    custom_path=""

    read -n 1 -s -r -p "Press any key to continue..."
}

list_backups() {
    pre_log "LOG: List Backups has been started:"
    clear
    printf "Listing existing backups:\n"
    ls $homefolder/ | grep -v "0log.dll"

    read -n 1 -s -r -p "Press any key to return to menu..."
    pre_log "LOG: List Backups has been closed; Returning to menu"
}

delete_backup() {
    pre_log "LOG: Delete Backup has been started"
    clear
    printf "Listing existing backups:\n"
    ls $homefolder/ | grep -v "0log.dll"
    printf "${RED}Which backup do you want to delete? (if you want to exit to menu, hit enter)\nEnter the backup name:${NC} "
    read backup_name
    pre_log "LOG: Backup $backup_name wants to be deleted"
    if [ -d "$homefolder/backup-$backup_name" ]; then
        rm -r "$homefolder/backup-$backup_name"
        printf "${RED}Backup $backup_name was deleted.${NC}\n\n"
        pre_log "LOG: Backup $backup_name was deleted."
    else
        printf "${RED}Backup $backup_name does not exist.${NC}\n\n"
        pre_log "LOG: Backup $backup_name does not exist; returning to menu"
    fi

    printf "Do you want to generate a report? (y/n): "
    read -r choices
    if [[ $choices == "n" ]]; then
      printf "No report will be generated\n\n"
      pre_log "LOG: No report will be generated for Delete Backup; Returning to menu"
    else
      pre_log "LOG: Generating report"
      printf "Generating report...\n"
      echo -e "$project_name Report ${date}\n" > "/home/$(whoami)/Desktop/$project_name-Report_Delete-Backup.txt"
      echo -e "====================================================\n" >> "/home/$(whoami)/Desktop/$project_name-Report_Delete-Backup.txt"
      if [ -d "$homefolder/backup-$backup_name" ]; then
        echo -e "Backup $backup_name was NOT deleted.\n" >> "/home/$(whoami)/Desktop/$project_name-Report_Delete-Backup.txt"
      else
        echo -e "Backup $backup_name was deleted successfully.\n" >> "/home/$(whoami)/Desktop/$project_name-Report_Delete-Backup.txt"
      fi
      pre_log "LOG: Report was generated"
      printf "Report was generated, check your desktop.\n\n"
    fi

    choices=""
    backup_name=""

    read -n 1 -s -r -p "Press any key to continue..."
}

search_file() {
    pre_log "LOG: File search has been opened"
    clear
    printf "Listing existing backups:\n"
    ls $homefolder/ | grep -v "0log.dll"
    printf "\nIn which backup do you want to search a file in?\nEnter the backup name: "
    read -r backup_name
    printf "\nWhich file are you searching for?\nEnter the file name: "
    read -r file_name

    if [ -f "$homefolder/backup-$backup_name/$backup_name.zip" ]; then
        report_1="Backup $backup_name existed."
        pre_log "LOG: Backup $backup_name exists."
        if unzip -l "$homefolder/backup-$backup_name/$backup_name.zip" | grep -q "$file_name"; then
            report_2="File $file_name found in backup $backup_name."
            pre_log "LOG: File $file_name found in backup $backup_name."
            printf "${GREEN}File $file_name found in backup $backup_name.${NC}\n"
            printf "Do you want to extract the file to the Desktop? (y/n): "
            read -r choices
            if [[ $choices == "n" ]]; then
              report_3="File $file_name was not extracted to Desktop."
              printf "Do you want to extract the file to a custom path? (y/n): "
              read -r choices
              if [[ $choices == "n" ]]; then
                report_4="File $file_name was not extracted at all."
                printf "Returning to menu\n"
                pre_log "LOG: Backup extract cancelled; Returning to menu"
                return
              fi
              until [ -e $custom_path ]; do
                  printf "Enter the path where you want to extract the file in: "
                  read -r custom_path
              done
              report_4="File $file_name was extracted to custom path $custom_path."
              unzip "$homefolder/backup-$backup_name/$backup_name.zip" "$file_name" -d "$custom_path"
              pre_log "LOG: File $file_name was extracted to custom path: $custom_path"
              printf "File $file_name was extracted to custom path: $custom_path\n"
              return
            fi
            report_3="File $file_name was extracted to Desktop."
            printf "Extracting file $file_name from backup $backup_name to Desktop\n"
            unzip "$homefolder/backup-$backup_name/$backup_name.zip" "$file_name" -d "/home/$(whoami)/Desktop/"
        else
          report_2="However file $file_name was not found in backup $backup_name."
          pre_log "LOG: File $file_name not found in backup $backup_name"
          printf "${RED}File $file_name not found in backup $backup_name.${NC}\n\n"
        fi
    else
        report_1="However backup $backup_name does not exist."
        pre_log "LOG: Backup $backup_name does not exist"
        printf "${RED}Backup $backup_name does not exist.${NC}\n\n"
    fi

    printf "Do you want to generate a report? (y/n): "
    read -r choices
    if [[ $choices == "n" ]]; then
      printf "No report will be generated\n\n"
      pre_log "LOG: No report will be generated for Search File"
    else
      pre_log "LOG: Generating report"
      printf "Generating report...\n"
      echo -e "$project_name Report ${date}\n" > "/home/$(whoami)/Desktop/$project_name-Report_Search-File.txt"
      echo -e "====================================================\n" >> "/home/$(whoami)/Desktop/$project_name-Report_Search-File.txt"
      echo -e "User searched for file $file_name in backup $backup_name.\n" >> "/home/$(whoami)/Desktop/$project_name-Report_Search-File.txt"
      $report_1 >> "/home/$(whoami)/Desktop/$project_name-Report_Search-File.txt"
      $report_2 >> "/home/$(whoami)/Desktop/$project_name-Report_Search-File.txt"
      $report_3 >> "/home/$(whoami)/Desktop/$project_name-Report_Search-File.txt"
      $report_4 >> "/home/$(whoami)/Desktop/$project_name-Report_Search-File.txt"
      pre_log "LOG: Report was generated"
      printf "Report was generated, check your desktop.\n\n"
    fi

    choices=""
    backup_name=""
    file_name=""
    custom_path=""
    report_1=""
    report_2=""
    report_3=""
    report_4=""

    read -n 1 -s -r -p "Press any key to continue..."
    pre_log "LOG: File search finished; Returning to menu"
}

export_backup() {
    pre_log "LOG: Export Backup has been started"
    clear
    printf "Listing existing backups:\n"
    ls $homefolder/ | grep -v "0log.dll"
    printf "\n\nWhich backup do you want to export?\nNote:\nIf you want to exit to menu, hit enter.\nThe backup will still be kept in the secret file path after export.\nTo remove it from there too, you have to delete it\n\nEnter the backup name: "
    read -r backup_name
    if [ -f "$homefolder/backup-$backup_name/$backup_name.zip" ]; then
        report_1="Backup $backup_name exists."
        pre_log "LOG: Backup $backup_name exists and wants to be exported."
        printf "Where do you want to export the backup to? (Desktop is default): "
        read -r export_path
        if [[ -d "$export_path" ]]; then
          cp -r "$homefolder/backup-$backup_name" "$export_path/"
          printf "${GREEN}Backup $backup_name was exported to $export_path.${NC}\n"
          pre_log "LOG: Backup $backup_name was exported to $export_path"
          report_2="Backup $backup_name was exported to $export_path."
        else
           report_2="An invalid path was entered."
           printf "${RED}Invalid path was entered${NC}\n"
           printf "Do you want to export to Desktop? (y/n): "
            read -r choices
            if [[ $choices == "n" ]]; then
              report_3="Backup $backup_name was not exported."
              printf "Returning to menu\n"
              pre_log "LOG: Backup export cancelled; Returning to menu"
              return
            fi
            report_3="Backup $backup_name was exported to Desktop."
          pre_log "LOG: Backup $backup_name was exported to Desktop."
          cp -r "$homefolder/backup-$backup_name" "/home/$(whoami)/Desktop/"
          printf "${GREEN}Backup $backup_name was exported to Desktop.${NC}\n"
        fi
    else
        report_1="Backup $backup_name did not exist."
        pre_log "LOG: Backup $backup_name does not exist"
        printf "${RED}Backup $backup_name does not exist.${NC}\n\n"
        sleep 3
    fi

    printf "Do you want to generate a report? (y/n): "
    read -r choices
    if [[ $choices == "n" ]]; then
      printf "No report will be generated\n\n"
      pre_log "LOG: No report will be generated for Export Backup"
    else
      pre_log "LOG: Generating report for Export Backup"
      printf "Generating report...\n"
      echo -e "$project_name Report ${date}\n" > "/home/$(whoami)/Desktop/$project_name-Report_Export-Backup.txt"
      echo -e "====================================================\n" >> "/home/$(whoami)/Desktop/$project_name-Report_Export-Backup.txt"
      $report_1 >> "/home/$(whoami)/Desktop/$project_name-Report_Export-Backup.txt"
      $report_2 >> "/home/$(whoami)/Desktop/$project_name-Report_Export-Backup.txt"
      $report_3 >> "/home/$(whoami)/Desktop/$project_name-Report_Export-Backup.txt"
      pre_log "LOG: Report was generated"
      printf "Report was generated, check your desktop.\n\n"
    fi

    printf "Do you want to export another backup? (y/n): "
    read -r choices
    if [[ $choices != "y" ]]; then
      printf "Returning to menu\n"
      pre_log "LOG: Finished exporting backups; Returning to menu"
      sleep 3
      report_1=""
      report_2=""
      report_3=""
      choices=""
      backup_name=""
      return
    fi
    pre_log "LOG: Exporting another Backup"
    report_1=""
    report_2=""
    report_3=""
    choices=""
    backup_name=""
    export_backup
}

export_all_backups() {
    pre_log "LOG: Export all backups has been started"
    clear
    printf "Are you sure you want to export all backups? Please note that encryption and compression will still be in place. (y/n): "
    read -r choices
    if [[ $choices != "y" ]]; then
        pre_log "LOG: Export all backups cancelled; Returning to menu"
      printf "Returning to menu\n"
      pre_log "LOG: Export all backups cancelled; Returning to menu"
      sleep 3
      return
    fi
    printf "Where do you want to export the backups to? (Don't type anything to export it to Desktop): "
    read -r export_path
    if [[ -d "$export_path" ]]; then
        pre_log "LOG: All backups were exported to $export_path"
      cp -r $homefolder/* "$export_path/"
      printf "${GREEN}All backups were exported to $export_path.${NC}\n"
      pre_log "LOG: All backups were exported to $export_path"
      read -n 1 -s -r -p "Press any key to continue..."
      return
    elif [[ $export_path == "" ]]; then
        pre_log "LOG: All backups were exported to Desktop"
      printf "${RED}Exporting to Desktop...${NC}\n"
      cp -r $homefolder/* "/home/$(whoami)/Desktop/"
      printf "${GREEN}All backups were exported to the Desktop.${NC}\n\n"
    fi
    export_path=""
    choices=""
    read -n 1 -s -r -p "Press any key to continue..."
    pre_log "LOG: Export all backups has been closed"
}
# End of Manage Backups

display_help() {
    pre_log "LOG: Help message opened"
    clear
    printf "Welcome to $project_name!\n\nThis Script is designed to backup files from a designated path to a hidden location within your device with other options like logging, managing backups and encryption for safer storage.\n\n"
    printf "This script is on GitHub! You can find it here: https://github.com/An0n-00/$project_name/blob/main/$project_name.sh\n\n"
    printf "If you need help, read this handy documentation: https://github.com/An0n-00/$project_name/blob/main/README.md\n\n"
    
    pre_log "LOG: Help message closed"
    read -n 1 -s -r -p "Press Enter to return to menu..."
}

uninstall() {
    pre_log "LOG: Uninstall function started"
    clear
    printf "${RED}READ BEFORE YOU ENTER\nThis will delete ALL backups and logs! Are you sure you want to continue?${NC}\n\n"
    printf "Please confirm by typing the following:\n'uninstall': "
    choices=""
    read -r choices
    if [[ $choices != "uninstall" ]]; then
      printf "${RED}Failed to uninstall!${NC}"
      pre_log "LOG: Uninstall failed. Input was '$choices'"
      pre_log "LOG: Returning to menu"
      sleep 3
      return
    else
      printf "\nUninstalling $project_name"
      i=0
      while [ $i -lt 3 ]; do
        sleep 0.6
        printf "."
        ((i++))
      done
      rm -rf "$homefolder"
      printf "\n\n${GREEN}Uninstall completed.${NC}"
      printf "\n\nIf you restart this script, a folder will be automatically generated.\n\n"
      read -n 1 -s -r -p "Press any key to exit..."
      clear
      exit 0
    fi
}

pre_log() {
    log "$1" || printf ""
}

log() {
  if [ ! -f "$logfile" ]; then
    return
  fi
  echo "[$(date '+%a %b %d %T %Z %Y')] - $*" >> $logfile
}

display_log() {
  pre_log "LOG: Log has been opened"
  clear
  cat $logfile
  printf "\n\n"
  read -n 1 -s -r -p "Press any key to return to menu..."
  pre_log "LOG: Log has been closed"
}

# Startup and Menus
startup() {
  clear
  echo "  ____        ____             _"
  echo " | __ )      | __ )  __ _  ___| | ___   _ _ __"
  echo " |  _ \ _____|  _ \ / _  |/ __| |/ / | | | '_ \ "
  echo " | |_) |_____| |_) | (_| | (__|   <| |_| | |_) |"
  echo " |____/      |____/ \__,_|\___|_|\_\\\__,_| .__/"
  echo "                                         |_|"
  printf "\n"
  echo "                                            $version "
  echo "==================================================== "
  printf "\nWelcome to B-Bash\n\nInitializing $project_name v$version"
  i=0
  while [ $i -lt 3 ]; do
  sleep 0.8
  printf "."
  ((i++))
  done
  printf "\n"

  if [ $(whoami) == "root" ]; then
      printf "${RED}$project_name CANNOT run with root. Please use an installed User!\n\n"
      read -n 1 -s -r -p "Press Enter to return to exit...${NC}"
  fi

  if [ ! -d "$homefolder" ]; then
    mkdir "$homefolder"
    echo "" > "$logfile"
    printf "\nThis Script is designed to backup files from a designated path to a hidden location within your device with other options like logging, managing backups and encryption for safer storage.\n\n"
    read -n 1 -s -r -p "Press Enter to return to continue..."

  fi

  if [ ! -f "$logfile" ]; then
    echo "" > "$logfile"
  fi

  report_1=""
  report_2=""
  report_3=""
  report_4=""

  pre_log "START: Script started"
}

backup_menu() {
    choice=""
  while [ true ]; do
      pre_log "LOG: Backup Menu has been opened"
      clear
      printf "\n"
      echo "==========================================="
      echo "| Backup Management                       |"
      echo "|_________________________________________|"
      echo "| 1. Create Backup                        |"
      echo "| 2. Delete Backup                        |"
      echo "| 3. Restore Backup                       |"
      echo "| 4. List Backups                         |"
      echo "| 5. Search File in Backup                |"
      echo "| 6. Export Backup(s)                     |"
      echo "|                                         |"
      echo "| 99. Return to main menu                 |"
      echo "|_________________________________________|"
      printf "\n"
      read -r -e -p "Enter your option: " choice
      case $choice in
          1) create_backup;;
          2) delete_backup;;
          3) restore_backup;;
          4) list_backups;;
          5) search_file;;
          6) export_backup;;
          99) return;;
          *) printf "Invalid Input, please enter a valid option.\n${RED}To return to main menu, enter 99!${NC}"; pre_log "LOG: Invalid Input in backup_menu"; sleep 2;;
      esac
  done
}

menu(){
    choice=""
  while true; do
      clear
      printf "\n"
      echo "==========================================="
      echo "| $project_name (ver.$version)                  |"
      echo "|_________________________________________|"
      echo "| 1. Manage Backups                       |"
      echo "| 2. Help                                 |"
      echo "| 3. Display Logs                         |"
      echo "| 4. Export all Backups                   |"
      echo "|                                         |"
      echo "| 95. Uninstall                           |"
      echo "| 99. Exit                                |"
      echo "|_________________________________________|"
      printf "\n"
      read -r -e -p "Enter your option: " choice
      pre_log "LOG: Menu successfully printed to console"
      case $choice in
          1) backup_menu;;
          2) display_help;;
          3) display_log;;
          4) export_all_backups;;
          95) uninstall;;
          99) printf "${GREEN}Bye.${NC}"; sleep 1; clear; pre_log "END: $project_name Exiting successfully"; exit 0;;
          *) printf "Invalid Input, please enter a valid option. \n${RED}To exit enter 99!${NC}"; pre_log "LOG: Invalid Input in menu"; sleep 2;;
      esac
  done
}

main() {
    startup
    menu
}

main