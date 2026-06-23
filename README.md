# 🐍 PowerShell Snake Suite

A collection of custom, interactive PowerShell commands built to turbocharge your Windows Terminal with arcade retro games, system diagnostics, and real-time weather monitoring using rock-solid APIs.

---

## ⚡ Quick One-Line Installation

Run this single command in your PowerShell terminal to automatically download and install the entire **Snake Suite** into your profile:

```powershell
irm "[https://raw.githubusercontent.com/Ligrys111/Snake_Windows_PS/main/Microsoft.PowerShell_profile.ps1](https://raw.githubusercontent.com/Ligrys111/Snake_Windows_PS/main/Microsoft.PowerShell_profile.ps1)" | Out-File -FilePath $PROFILE -Append -Encoding utf8; & $PROFILE
```
## 🚀 Features
* ```Snake```: Animated retro arcade snake running natively inside your PowerShell terminal.
* ```Snake-Info```: Detailed system hardware and OS specs displayed alongside a beautiful custom ASCII snake logo.
* ```Snake-Matrix```: The iconic digital rain effect from The Matrix animated inside your console window.
* ```Snake-Weather```: Lightweight, instant weather monitoring that geolocates any city automatically (even when typed without Polish diacritics like krakow, wroclaw, or warszawa).
* ```Snake-Help```: A beautiful terminal UI showing the full command manual with custom ASCII graphics.

## 📖 Command Reference
```Snake-Help```
Displays the manual interface featuring custom ASCII art and a list of available commands.

```Snake-Weather```
Fetches the exact current temperature and weather conditions from the stable Open-Meteo and OpenStreetMap APIs.
* **Persistent City Storage**: It remembers your city choice after the first run so you don't have to re-type it.
* **Reset Configuration**: Want to change your saved location? Simply run:

```Snake-Weather -Reset```

---

## 🎨 Preview

```text
     ____        ___  _  _    __    _  _  ____ 
    / . .\      / __)( \( )  /__\  ( )/ )( ___)
    \  ---<     \__ \ )  (  /(__)\  )  (  )__) 
     \  \       (___/(_)\_)(__)(__)(_)\_)(____)
     /  /       
     \  \       
    /  /_____   
   (________/   

==================================================================
  COMMAND             |  DESCRIPTION
==================================================================
  Snake               |  Starts the animated retro arcade snake game.
  Snake-Info          |  Displays detailed system specs with custom logos.
  Snake-Matrix        |  Triggers the animated Matrix digital rain effect.
  Snake-Weather       |  Fetches accurate current weather and temperature.
  Snake-Weather -Reset|  Resets the saved city configuration.
==================================================================
```
## 🔒 Requirements
* OS: Windows 10 / 11
* Shell: PowerShell 5.1 or PowerShell Core 7+
* Internet Connection: Required for ```Snake-Weather``` and the one-line installer.
