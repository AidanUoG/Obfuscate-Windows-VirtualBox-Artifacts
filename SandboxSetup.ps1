# This function moves Virtualbox Files to a new folder, renames them and deletes the original folder
function HideVirtualBoxFiles {
    # Virtualbox Folder containing VirtualBox Guest Additions files
    $sourceFolder = "C:\Program Files\Oracle\VirtualBox Guest Additions"

    # New folder where files will be moved
    $destinationParentFolder = "C:\ProgramData"
    
    # Random name created for the new folder
    $randomFolderName = "CustomFolder_" + [System.IO.Path]::GetRandomFileName()
    $destinationFolder = Join-Path -Path $destinationParentFolder -ChildPath $randomFolderName

    try {
        # Create the new folder
        if (-not (Test-Path -Path $destinationFolder)) {
            New-Item -Path $destinationFolder -ItemType Directory -Force | Out-Null
        }

        # Files are moved to new folder
        Get-ChildItem -Path $sourceFolder | Move-Item -Destination $destinationFolder -Force

        # Files are given new random names
        Get-ChildItem -Path $destinationFolder | ForEach-Object {
            $randomName = [System.IO.Path]::GetRandomFileName()
            $newName = Join-Path -Path $destinationFolder -ChildPath "$randomName$($_.Extension)"
            Rename-Item -Path $_.FullName -NewName $newName -Force
        }

        Write-Host "Files from VirtualBox Guest Additions folder moved to: $destinationFolder"
        
        # Original VirtualBox folder is deleted
        Remove-Item -Path $sourceFolder -Force -Recurse -ErrorAction SilentlyContinue
    } catch {
        Write-Host "Failed to hide VirtualBox files: $_"
    }
}

# This function deletes registry keys that give away VirtualBox
function DeleteRegistry {
    try {
        # Guest Additions Folder
        $firstKeyPath = "SOFTWARE\Oracle"
        Remove-Item -Path "HKLM:\$firstKeyPath" -Recurse -Force
        # ACPI folder where many 'VBOX' values are stored
        $secondKeyPath = "HARDWARE\ACPI"
        Remove-Item -Path "HKLM:\$secondKeyPath" -Recurse -Force

    } catch {
        Write-Host "Failed to modify registry: $_"
    }
}

# This function renames drivers that give away VirtualBox
function ModifyDrivers {
    # Folder containing drivers
    $driversFolder = "C:\Windows\System32\drivers"

    # List of drivers to rename
    $driversToRename = @(
        "VBoxGuest.sys",
        "VBoxWddm.sys",
        "VBoxSF.sys",
        "VBoxMouse.sys"
    )

    # Loop to rename each file in list
    foreach ($driverName in $driversToRename) {
        $oldDriverPath = Join-Path -Path $driversFolder -ChildPath $driverName
        
        # Drivers are given new random names
        $randomString = [System.IO.Path]::GetRandomFileName()
        $newDriverName = "$randomString.sys"
        $newDriverPath = Join-Path -Path $driversFolder -ChildPath $newDriverName
        
        Rename-Item -Path $oldDriverPath -NewName $newDriverName -Force
    }
}

# This function installs dummy applications on the machine
function InstallSoftware {
    $url = "https://ninite.com/-chrome-discord-cdburnerxp-skype-7zip-vlc-spotify-vscode-openoffice-steam/ninite.exe"
    $directory = "C:\Scripts\ninite.exe"

    # Creates Scripts directory in the root of C:
    New-Item C:\Scripts\ -ItemType Directory

    # Calls upon Ninite URL to grab .exe
    Invoke-WebRequest -Uri $url -OutFile $directory

    # Starts Ninite.exe
    Start-Process -FilePath $directory
}

# This function creates dummy documents on the machine
function CreateRandomDocument {
    # Files will be created in the Documents Folder
    $documentsFolder = [System.Environment]::GetFolderPath('MyDocuments')
    $createdDocuments = @()
    # Number of documents created by the script is random from 1 to 5.
    for ($i = 1; $i -le (Get-Random -Minimum 1 -Maximum 5); $i++) {
        # Name will be Document_x.docx with x being a random number between 10000 and 99999
        $FileName = "Document_$((Get-Random -Minimum 10000 -Maximum 99999)).docx"
        $DocumentPath = [System.IO.Path]::Combine($documentsFolder, $FileName)
        [System.IO.Path]::GetRandomFileName() | Out-File -FilePath $DocumentPath -Encoding utf8 -ErrorAction SilentlyContinue
        if (Test-Path $DocumentPath) {
            $createdDocuments += $DocumentPath
        }
    }
    $createdDocuments
}

# This function creates dummy images on the machine
function CreateRandomImage {
    $documentsFolder = [System.Environment]::GetFolderPath('MyDocuments')
    $createdImages = @()
    # Number of images created by the script is random from 1 to 5.
    for ($i = 1; $i -le (Get-Random -Minimum 1 -Maximum 5); $i++) {
        # Name will be Image_x.png with x being a random number between 10000 and 99999
        $FileName = "Image_$((Get-Random -Minimum 10000 -Maximum 99999))_$i.png"
        $ImagePath = [System.IO.Path]::Combine($documentsFolder, $FileName)
        $bitmap = New-Object System.Drawing.Bitmap 300,300
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        # The colour of the image created is random
        $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb((Get-Random -Minimum 0 -Maximum 255), (Get-Random -Minimum 0 -Maximum 255), (Get-Random -Minimum 0 -Maximum 255)))
        $graphics.FillRectangle($brush, 0, 0, 300, 300)
        $bitmap.Save($ImagePath, [System.Drawing.Imaging.ImageFormat]::Png)
        $graphics.Dispose()
        $bitmap.Dispose()
        if (Test-Path $ImagePath) {
            $createdImages += $ImagePath
        }
    }
    $createdImages
}

# This function creates dummy audio and video files on the machine
function AudioAndVideo {
    $documentsFolder = [System.Environment]::GetFolderPath('MyDocuments')
    $createdAudio = @()
    $createdVideo = @()
    # Number of audio and video files created by the script is random from 1 to 5 each.
    for ($i = 1; $i -le (Get-Random -Minimum 1 -Maximum 5); $i++) {
        # Name will be Audio_x.wav with x being a random number between 10000 and 99999
        $audioFileName = "Audio_" + (Get-Date -Format "yyyyMMddHHmmss") + "_$i.wav"
        # Name will be Video_x.mp4 with x being a random number between 10000 and 99999
        $videoFileName = "Video_" + (Get-Date -Format "yyyyMMddHHmmss") + "_$i.mp4"
        $audioFilePath = [System.IO.Path]::Combine($documentsFolder, $audioFileName)
        $videoFilePath = [System.IO.Path]::Combine($documentsFolder, $videoFileName)
        New-Item -Path $audioFilePath -ItemType File | Out-Null
        New-Item -Path $videoFilePath -ItemType File | Out-Null
        if (Test-Path $audioFilePath) {
            $createdAudio += $audioFilePath
        }
        if (Test-Path $videoFilePath) {
            $createdVideo += $videoFilePath
        }
    }
    $createdAudio, $createdVideo
}

# This function creates system devices on the machine
function ModifySystemDevices {
    # A random printer name is created
    $printerName = "Printer_" + (-join ((48..57) + (97..122) | Get-Random -Count 8 | % {[char]$_}))

    # Required printer driver is installed
    $driverName = "Generic / Text Only"
    if (-not (Get-PrinterDriver $driverName -ErrorAction SilentlyContinue)) {
        Write-Output "Installing generic printer driver..."
        Add-PrinterDriver -Name $driverName
    }

    # Fake printer port is created
    $portName = "LPT1"
    # Fake printer IP is created
    $fakePrinterIP = "192.168.1.100"  # Replace with your desired printer address
    if (-not (Get-PrinterPort $portName -ErrorAction SilentlyContinue)) {
        Write-Output "Creating printer port..."
        Add-PrinterPort -Name $portName -PrinterHostAddress $fakePrinterIP
    }

    # Printer is created with port and IP set
    Add-Printer -Name $printerName -DriverName $driverName -PortName $portName

    Write-Output "Device '$printerName' created successfully."
}

# This function sets Applications to autorun on system startup
function AddApplicationsToAutorun {
    # List of applications and the path to their executables
    $applications = @{
        "Google Chrome" = "C:\Program Files\Google\Chrome\Application\chrome.exe"
        "Discord" = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Discord\Update.exe"
        "Steam" = "C:\Program Files (x86)\Steam\steam.exe"
        "Skype" = "C:\Program Files (x86)\Microsoft\Skype for Desktop\Skype.exe"
    }
    # Path to the Autorun registry
    $regKeyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"

    try {
        foreach ($appName in $applications.Keys) {
            $appPath = $applications[$appName]
            $regKey = "$regKeyPath\$appName"

            # Checks that the applications have been installed by InstalledSoftware function
            if (-not (Test-Path $appPath)) {
                Write-Host "Waiting for $appName executable to be available..."
                while (-not (Test-Path $appPath)) {
                    Start-Sleep -Seconds 1
                }
                Write-Host "$appName executable is now available."
            }

            # Check if the application is already in autorun
            if (-not (Test-Path $regKey)) {
                # Applications are added to autorun
                New-ItemProperty -Path $regKeyPath -Name $appName -Value $appPath -PropertyType String -Force | Out-Null
                Write-Output "Application '$appName' added to autorun."
            } else {
                Write-Output "Application '$appName' is already in autorun."
            }
        }
    } catch {
        Write-Output "Failed to add applications to autorun: $_"
    }
}

# This function modifies the default MAC address of the network adapter
function ModifyHypervisorMAC {
    # Random MAC address is generated
    $RandomMacAddress = (0..5 | ForEach-Object {Get-Random -Minimum 0 -Maximum 256}).ForEach({"{0:X2}" -f $_}) -join '-'

    # Generated MAC address is displayed
    Write-Output "Generated MAC Address: $RandomMacAddress"

    # Get the current ethernet network adapter
    $adapter = Get-NetAdapter -Name "Ethernet"

    if ($adapter) {
        Write-Output "Found network adapter: $($adapter.Name)"
        try {
            # Change the MAC address of the network adapter to the randomly generataed one
            $adapter | Set-NetAdapter -MacAddress $RandomMacAddress -Confirm:$false
            Write-Output "MAC address changed successfully."
        }
        catch {
            Write-Output "Failed to change MAC address: $_"
        }
    }
    else {
        Write-Output "Network adapter 'Ethernet' not found."
    }
}

# All functions are called
HideVirtualBoxFiles
ModifyDrivers
DeleteRegistry
InstallSoftware
CreateRandomDocument
CreateRandomImage
AudioAndVideo
ModifySystemDevices
AddApplicationsToAutorun
ModifyHypervisorMAC

Write-Output "All software is installed and all modifications are complete. The Sandbox setup has completed."
