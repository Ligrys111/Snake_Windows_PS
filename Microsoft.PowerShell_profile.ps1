function Snake {
    <#
    .SYNOPSIS
        An animated 15-segment snake with a '%' head and a dynamic body.
        Press Ctrl+C to stop.
    #>
    Clear-Host
    Write-Host "Generating an advanced dynamic snake... Press Ctrl+C to stop." -ForegroundColor Cyan
    Start-Sleep -Seconds 1
    Clear-Host

    $ui = $Host.UI.RawUI
    $maxWidth = $ui.WindowSize.Width - 5
    $maxHeight = $ui.WindowSize.Height - 2

    $charHoriz = "-"
    $charVert  = "|"
    $charSlash = "/"
    $charBack  = "\"
    $charTL    = [char]0x250C 
    $charTR    = [char]0x2510 
    $charBL    = [char]0x2514 
    $charBR    = [char]0x2518 

    $snake = @()
    for ($i = 0; $i -lt 15; $i++) {
        $snake += [PSCustomObject]@{ X = 40 - $i; Y = 12; Char = $charHoriz }
    }

    $dirX = 1
    $dirY = 0
    $loopAngle = 0      
    $inLoop = $false    
    $loopSteps = 0      

    $oldCursorSize = $ui.CursorSize
    $ui.CursorSize = 0

    try {
        while ($true) {
            $oldDirX = $dirX
            $oldDirY = $dirY

            if ($inLoop) {
                $loopSteps--
                $loopAngle += $loopDirection * 0.45
                
                $dirX = [Math]::Round([Math]::Cos($loopAngle) * 2)
                $dirY = [Math]::Round([Math]::Sin($loopAngle))
                
                if ($loopSteps -le 0) {
                    $inLoop = $false
                    $dirX = if ($dirX -gt 0) { 1 } elseif ($dirX -lt 0) { -1 } else { 0 }
                    $dirY = if ($dirY -gt 0) { 1 } elseif ($dirY -lt 0) { -1 } else { 0 }
                }
            }
            else {
                $roll = Get-Random -Minimum 1 -Maximum 101

                if ($roll -le 3) {
                    $inLoop = $true
                    $loopSteps = Get-Random -Minimum 14 -Maximum 18 
                    $loopDirection = if ((Get-Random -Minimum 0 -Maximum 2) -eq 0) { 1 } else { -1 } 
                    $loopAngle = [Math]::Atan2($dirY, $dirX / 2) 
                }
                elseif ($roll -le 20) {
                    do {
                        $newDirX = Get-Random -Minimum -1 -Maximum 2
                        $newDirY = Get-Random -Minimum -1 -Maximum 2
                        
                        $isStandingStill = ($newDirX -eq 0 -and $newDirY -eq 0)
                        $isReversingX = ($newDirX -eq -$dirX -and $newDirX -ne 0)
                        $isReversingY = ($newDirY -eq -$dirY -and $newDirY -ne 0)
                        
                    } while ($isStandingStill -or $isReversingX -or $isReversingY)

                    $dirX = $newDirX
                    $dirY = $newDirY
                }
            }

            $newX = $snake[0].X + $dirX
            $newY = $snake[0].Y + $dirY

            if ($newX -lt 1 -or $newX -gt $maxWidth -or $newY -lt 1 -or $newY -gt $maxHeight) {
                $inLoop = $false
                $loopSteps = 0
                do {
                    $dirX = Get-Random -Minimum -1 -Maximum 2
                    $dirY = Get-Random -Minimum -1 -Maximum 2
                    $newX = $snake[0].X + $dirX
                    $newY = $snake[0].Y + $dirY
                } while ($newX -lt 1 -or $newX -gt $maxWidth -or $newY -lt 1 -or $newY -gt $maxHeight -or ($dirX -eq 0 -and $dirY -eq 0))
            }

            $nextBodyChar = $charHoriz 
            
            if ($inLoop) {
                if (($dirX -gt 0 -and $dirY -gt 0) -or ($dirX -lt 0 -and $dirY -lt 0)) { $nextBodyChar = $charBack }
                elseif (($dirX -lt 0 -and $dirY -gt 0) -or ($dirX -gt 0 -and $dirY -lt 0)) { $nextBodyChar = $charSlash }
                elseif ($dirY -ne 0 -and $dirX -eq 0) { $nextBodyChar = $charVert }
                else { $nextBodyChar = $charHoriz }
            }
            else {
                if ($oldDirY -eq 0 -and $dirX -eq 0 -and $dirY -gt 0) {
                    $nextBodyChar = if ($oldDirX -gt 0) { $charTR } else { $charTL }
                }
                elseif ($oldDirY -eq 0 -and $dirX -eq 0 -and $dirY -lt 0) {
                    $nextBodyChar = if ($oldDirX -gt 0) { $charBR } else { $charBL }
                }
                elseif ($oldDirX -eq 0 -and $dirY -eq 0 -and $dirX -gt 0) {
                    $nextBodyChar = if ($oldDirY -gt 0) { $charBL } else { $charTL }
                }
                elseif ($oldDirX -eq 0 -and $dirY -eq 0 -and $dirX -lt 0) {
                    $nextBodyChar = if ($oldDirY -gt 0) { $charBR } else { $charTR }
                }
                elseif ($dirX -ne 0 -and $dirY -ne 0) {
                    $nextBodyChar = if (($dirX -gt 0 -and $dirY -gt 0) -or ($dirX -lt 0 -and $dirY -lt 0)) { $charBack } else { $charSlash }
                }
                elseif ($dirX -ne 0 -and $dirY -eq 0) { $nextBodyChar = $charHoriz }
                elseif ($dirX -eq 0 -and $dirY -ne 0) { $nextBodyChar = $charVert }
            }

            $snake[0].Char = $nextBodyChar

            $tail = $snake[-1]
            $ui.CursorPosition = New-Object System.Management.Automation.Host.Coordinates ($tail.X, $tail.Y)
            Write-Host " " -NoNewline 

            for ($i = $snake.Count - 1; $i -gt 0; $i--) {
                $snake[$i].X = $snake[$i-1].X
                $snake[$i].Y = $snake[$i-1].Y
                $snake[$i].Char = $snake[$i-1].Char
            }

            $snake[0].X = $newX
            $snake[0].Y = $newY

            for ($i = 0; $i -lt $snake.Count; $i++) {
                $ui.CursorPosition = New-Object System.Management.Automation.Host.Coordinates ($snake[$i].X, $snake[$i].Y)
                if ($i -eq 0) {
                    Write-Host "%" -ForegroundColor Yellow -NoNewline
                } else {
                    Write-Host $snake[$i].Char -ForegroundColor DarkGreen -NoNewline
                }
            }

            Start-Sleep -Milliseconds 60
        }
    }
    finally {
        $ui.CursorSize = $oldCursorSize
    }
}

function Snake-Info {
    <#
    .SYNOPSIS
        Displays highly detailed system info alongside a green snake.
    #>
    Clear-Host
    Write-Host "Gathering full system information..." -ForegroundColor Cyan

    $osObj = Get-CimInstance Win32_OperatingSystem
    $os = $osObj.Caption
    $version = [Environment]::OSVersion.Version.ToString()
    
    $uptime = (Get-Date) - $osObj.LastBootUpTime
    $uptimeString = "{0} hours, {1} mins" -f [Math]::Floor($uptime.TotalHours), $uptime.Minutes
    
    $shell = "Windows PowerShell ($($PSVersionTable.PSVersion))"
    $locale = [System.Globalization.CultureInfo]::CurrentCulture.Name
    
    $displays = Get-CimInstance Win32_VideoController | ForEach-Object { "$($_.Name): $($_.CurrentHorizontalResolution)x$($_.CurrentVerticalResolution)" }
    $gpu = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name
    
    $cpu = (Get-CimInstance Win32_Processor).Name.Trim()
    $computerSystem = Get-CimInstance Win32_ComputerSystem
    $totalRAM = [Math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
    $freeRAMBytes = $osObj.FreePhysicalMemory * 1KB
    $usedRAM = [Math]::Round(($computerSystem.TotalPhysicalMemory - $freeRAMBytes) / 1GB, 2)

    $disks = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | ForEach-Object {
        $total = [Math]::Round($_.Size / 1GB, 2)
        $free = [Math]::Round($_.FreeSpace / 1GB, 2)
        "Disk ($($_.DeviceID)): [Free: $free GB / Total: $total GB]"
    }

    $localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -like "*Ethernet*" -or $_.InterfaceAlias -like "*Wi-Fi*" } | Select-Object -First 1).IPAddress

    $infoData = @()
    $infoData += "OS:              $os"
    $infoData += "Kernel:          WIN32_NT $version"
    $infoData += "Uptime:          $uptimeString"
    $infoData += "Shell:           $shell"
    foreach ($disp in $displays) { $infoData += "Display:         $disp" }
    $infoData += "CPU:             $cpu"
    $infoData += "GPU:             $gpu"
    $infoData += "Memory:          $usedRAM GiB / $totalRAM GiB"
    foreach ($disk in $disks) { $infoData += "$disk" }
    $infoData += "Local IP:        $localIP"
    $infoData += "Locale:          $locale"

    Clear-Host

    $ui = $Host.UI.RawUI
    $snakeColor = "Green"
    $logoColor = "Cyan"

    $snakeArt = @(
        "     ____       ",
        "    / . .\      ",
        "    \  ---<     ",
        "     \  \       ",
        "     /  /       ",
        "     \  \       ",
        "    /  /_____   ",
        "   (________/   "
    )

    $logoArt = @(
        "##########    ##########",
        "##########    ##########",
        "##########    ##########",
        "##########    ##########",
        "                        ",
        "##########    ##########",
        "##########    ##########",
        "##########    ##########",
        "##########    ##########"
    )

    $maxTextLength = 0
    foreach ($line in $infoData) {
        if ($line.Length -gt $maxTextLength) { $maxTextLength = $line.Length }
    }
    
    $textStartX = 18
    $logoStartX = $textStartX + $maxTextLength + 5

    for ($i = 0; $i -lt $snakeArt.Count; $i++) {
        $ui.CursorPosition = New-Object System.Management.Automation.Host.Coordinates (0, $i)
        Write-Host $snakeArt[$i] -ForegroundColor $snakeColor -NoNewline
    }

    for ($i = 0; $i -lt $logoArt.Count; $i++) {
        if (-not [string]::IsNullOrWhiteSpace($logoArt[$i])) {
            $ui.CursorPosition = New-Object System.Management.Automation.Host.Coordinates ($logoStartX, $i)
            Write-Host $logoArt[$i] -ForegroundColor $logoColor
        }
    }

    for ($i = 0; $i -lt $infoData.Count; $i++) {
        if ($i -lt $ui.WindowSize.Height) {
            $ui.CursorPosition = New-Object System.Management.Automation.Host.Coordinates ($textStartX, $i)
            
            $line = $infoData[$i]
            if ($line -match "^([^:]+):(.*)$") {
                Write-Host "=> $($Matches[1]):" -ForegroundColor Yellow -NoNewline
                Write-Host $Matches[2] -ForegroundColor White
            } else {
                Write-Host "=> $line" -ForegroundColor White
            }
            Start-Sleep -Milliseconds 25
        }
    }

    $finalY = [Math]::Max($infoData.Count + 1, [Math]::Max($snakeArt.Count, $logoArt.Count) + 1)
    $ui.CursorPosition = New-Object System.Management.Automation.Host.Coordinates (0, $finalY)
}

function Snake-Matrix {
    <#
    .SYNOPSIS
        Digital matrix rain falling effect.
        Press Ctrl+C to stop.
    #>
    Clear-Host
    $ui = $Host.UI.RawUI
    $w = $ui.WindowSize.Width
    $h = $ui.WindowSize.Height - 3

    $streams = @()
    for ($x = 0; $x -lt $w; $x += 2) {
        $streams += ,@{ x = $x; y = Get-Random -Minimum 0 -Maximum $h; len = Get-Random -Minimum 5 -Maximum 20 }
    }

    $oldCursorSize = $ui.CursorSize
    $ui.CursorSize = 0

    try {
        while ($true) {
            $ui.CursorPosition = New-Object System.Management.Automation.Host.Coordinates (2, ($h + 1))
            Write-Host " [MATRIX MODE] -- GUARD SNAKE ONLINE -- " -ForegroundColor Green -NoNewline

            for ($i = 0; $i -lt $streams.Count; $i++) {
                $s = $streams[$i]
                $x = $s.x
                
                $eraseY = $s.y - $s.len
                if ($eraseY -ge 0 -and $eraseY -lt $h) {
                    $ui.CursorPosition = New-Object System.Management.Automation.Host.Coordinates ($x, $eraseY)
                    Write-Host " " -NoNewline
                }

                if ($s.y -lt $h) {
                    $ui.CursorPosition = New-Object System.Management.Automation.Host.Coordinates ($x, $s.y)
                    $char = [char](Get-Random -Minimum 33 -Maximum 126)
                    Write-Host $char -ForegroundColor White -NoNewline
                    
                    if ($s.y -gt 0) {
                        $ui.CursorPosition = New-Object System.Management.Automation.Host.Coordinates ($x, ($s.y - 1))
                        Write-Host $char -ForegroundColor DarkGreen -NoNewline
                    }
                }

                $s.y += 1
                if (($s.y - $s.len) -ge $h) {
                    $s.y = 0
                    $s.len = Get-Random -Minimum 5 -Maximum 20
                }
            }
            Start-Sleep -Milliseconds 30
        }
    }
    finally {
        $ui.CursorSize = $oldCursorSize
        Clear-Host
    }
}

function Snake-Weather {
    <#
    .SYNOPSIS
        Fetches live weather data and automatically handles Polish cities written without diacritics.
    #>
    [CmdletBinding()]
    param(
        [string]$City = "",
        [switch]$Reset
    )

    $ConfigFile = "$HOME\.snake_weather_city.txt"

    if ($Reset) {
        if (Test-Path $ConfigFile) { Remove-Item $ConfigFile -Force }
        Write-Host "City configuration has been reset." -ForegroundColor Yellow
        $City = ""
    }

    if ([string]::IsNullOrWhiteSpace($City) -and (Test-Path $ConfigFile)) {
        $City = (Get-Content $ConfigFile -Raw).Trim()
    }

    Clear-Host

    if ([string]::IsNullOrWhiteSpace($City)) {
        $City = Read-Host "Enter your city name (e.g., Tluszcz, Krakow, Warszawa)"
        if ([string]::IsNullOrWhiteSpace($City)) {
            Write-Host "City name cannot be empty." -ForegroundColor Red
            return
        }
        $City.Trim() | Out-File -FilePath $ConfigFile -Force
    }

    Write-Host "Searching location and current weather for: $City..." -ForegroundColor Green

    try {
        $encodedCity = [Uri]::EscapeDataString($City)
        $geoUrl = "https://nominatim.openstreetmap.org/search?q=${encodedCity}&format=json&limit=1"
        
        $geoResponse = Invoke-RestMethod -Uri $geoUrl -UserAgent "PowerShellSnakeWeatherScript"

        if (-not $geoResponse) {
            Write-Host "Could not find coordinates for '$City'. Make sure the name is correct." -ForegroundColor Red
            return
        }

        $lat = $geoResponse[0].lat
        $lon = $geoResponse[0].lon
        $displayName = $geoResponse[0].display_name -split "," | Select-Object -First 1


        $weatherUrl = "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,weather_code&timezone=auto"
        $weatherResponse = Invoke-RestMethod -Uri $weatherUrl
        
        Clear-Host

        $currentTemp = $weatherResponse.current.temperature_2m
        $code = $weatherResponse.current.weather_code

        Write-Host "Current Weather (NOW):" -ForegroundColor Cyan
        Write-Host "Report: $displayName" -ForegroundColor White
        Write-Host "Temperature: $currentTemp °C" -ForegroundColor Yellow

        # Mapowanie kodów pogodowych WMO
        if ($code -eq 0) {
            Write-Host "Condition: Sunny / Clear Sky" -ForegroundColor Green
        } elseif ($code -le 3) {
            Write-Host "Condition: Cloudy / Partly Cloudy" -ForegroundColor Gray
        } elseif ($code -ge 51 -and $code -le 67) {
            Write-Host "Condition: Rainy / Drizzle" -ForegroundColor LightRed
        } elseif ($code -ge 71 -and $code -le 86) {
            Write-Host "Condition: Snowy / Winter Weather" -ForegroundColor LightCyan
        } elseif ($code -ge 95) {
            Write-Host "Condition: Stormy / Thunderstorm" -ForegroundColor LightRed
        } else {
            Write-Host "Condition: Variable Weather" -ForegroundColor Gray
        }

        Write-Host "`n[Tip] To change your saved city, type: Snake-Weather -Reset" -ForegroundColor DarkGray
    }
    catch {
        Write-Host "Failed to load weather data. Check your connection." -ForegroundColor Red
    }
}

function Snake-Help {
    <#
    .SYNOPSIS
        Displays the beautiful help menu for all Snake commands with a custom ASCII title and snake art.
    #>
    Clear-Host

    $snakeColor = "Green"
    $textColor  = "White"
    $cmdColor   = "Cyan"
    $titleColor = "Yellow"


    $ui = $Host.UI.RawUI
    
    $snakeArt = @(
        "     ____       ",
        "    / . .\      ",
        "    \  ---<     ",
        "     \  \       ",
        "     /  /       ",
        "     \  \       ",
        "    /  /_____   ",
        "   (________/   "
    )

    $titleArt = @(
        " ___  _  _    __    _  _  ____ ",
        "/ __)( \( )  /__\  ( )/ )( ___)",
        "\__ \ )  (  /(__)\  )  (  )__) ",
        "(___/(_)\_)(__)(__)(_)\_)(____)"
    )


    for ($i = 0; $i -lt $snakeArt.Count; $i++) {
        $ui.CursorPosition = New-Object System.Management.Automation.Host.Coordinates (0, $i)
        Write-Host $snakeArt[$i] -ForegroundColor $snakeColor -NoNewline
    }


    for ($i = 0; $i -lt $titleArt.Count; $i++) {
        $ui.CursorPosition = New-Object System.Management.Automation.Host.Coordinates (18, ($i + 2))
        Write-Host $titleArt[$i] -ForegroundColor $titleColor
    }


    $ui.CursorPosition = New-Object System.Management.Automation.Host.Coordinates (0, 9)

    Write-Host "==================================================================" -ForegroundColor Gray
    Write-Host "  COMMAND             |  DESCRIPTION" -ForegroundColor Yellow
    Write-Host "==================================================================" -ForegroundColor Gray


    Write-Host "  Snake               " -ForegroundColor $cmdColor -NoNewline
    Write-Host "|  Starts the animated retro arcade snake game." -ForegroundColor $textColor

    Write-Host "  Snake-Info          " -ForegroundColor $cmdColor -NoNewline
    Write-Host "|  Displays detailed system specs with custom logos." -ForegroundColor $textColor

    Write-Host "  Snake-Matrix        " -ForegroundColor $cmdColor -NoNewline
    Write-Host "|  Triggers the animated Matrix digital rain effect." -ForegroundColor $textColor

    Write-Host "  Snake-Weather       " -ForegroundColor $cmdColor -NoNewline
    Write-Host "|  Fetches accurate current weather and temperature." -ForegroundColor $textColor

    Write-Host "  Snake-Weather -Reset" -ForegroundColor $cmdColor -NoNewline
    Write-Host "|  Resets the saved city configuration." -ForegroundColor $textColor

    Write-Host "==================================================================" -ForegroundColor Gray
    Write-Host "Type any command above to start! Press Ctrl+C to exit loops.`n" -ForegroundColor DarkGray
}
