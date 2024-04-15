# Folder path to the desktop is defined
$folderPath = Join-Path -Path ([Environment]::GetFolderPath("Desktop")) -ChildPath "Run File"

# Create Run File folder if it does not exist
if (-not (Test-Path -Path $folderPath)) {
    New-Item -Path $folderPath -ItemType Directory | Out-Null
}

# Warn the user and prompt them to continue
Write-Host "WARNING: If you are running malware please be cautious and ensure that the network is set to Host Only Adapter."
$ready = Read-Host "Are you ready to analyse the file?  (Yes/Y to continue)"

# Check for Yes or Y
if ($ready -eq "Yes" -or $ready -eq "Y") {
    # Check for executable file in the folder
    $executableFiles = Get-ChildItem -Path $folderPath -Filter "*.exe"

    if ($executableFiles) {
        foreach ($file in $executableFiles) {
            try {
                # Run each executable file
                Write-Host "Analysing '$($file.Name)'"
                $process = Start-Process -FilePath $file.FullName -PassThru -ErrorAction Stop
                $parentProcessId = $process.Id
                $startTime = Get-Date
                # Set the analysis to run for 2 minutes
                $endTime = $startTime.AddMinutes(2)

                # Event subscription is used to monitor process creation
                $eventSubscriber = Register-WmiEvent -Class Win32_ProcessStartTrace -SourceIdentifier "ProcessStarted" -Action {
                    $processId = $event.SourceEventArgs.NewEvent.ProcessId
                    $parentProcessId = $event.SourceEventArgs.NewEvent.ParentProcessId

                    # Newly created processes are filtered to see if they are a child of the analysed sample process
                    if ($parentProcessId -eq $parentProcessId) {
                        $childProcess = Get-Process -Id $processId -ErrorAction SilentlyContinue
                        if ($childProcess) {
                            # Child process is listed to the analyst
                            Write-Host "Detected Child Process: $($childProcess.Name), PID: $($childProcess.Id)"
                        }
                    }
                }

                # Wait for specified duration
                while ((Get-Date) -lt $endTime) {
                    Start-Sleep -Seconds 1
                }

                # Event subscription ends
                Unregister-Event -SourceIdentifier "ProcessStarted" | Out-Null

                # Process is terminated after 2 minutes have passed
                if (Get-Process -Id $parentProcessId -ErrorAction SilentlyContinue) {
                    Stop-Process -Id $parentProcessId -Force
                    Write-Host "Execution of $($file.Name) terminated successfully."
                } else {
                    # If process has already ended this message is displayed
                    Write-Host "Process $($parentProcessId) not found. Might have terminated already."
                }
            } catch {
                Write-Host "Error running $($file.Name): $_"
            }
        }
    } else {
        Write-Host "No executable files found in the 'Run File' folder."
    }
} else {
    Write-Host "Exiting script..."
}
