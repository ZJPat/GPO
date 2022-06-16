# inspired by the custom N-Able AMP I built for my old MSP
#Created by ZJP & AM 
Start-Job -ScriptBlock {takeown /f C:\WINDOWS\PolicyDefinitions /r /a; icacls C:\WINDOWS\PolicyDefinitions /grant Administrators:(OI)(CI)F /t; Copy-Item -Path .\Files\PolicyDefinitions\* -Destination C:\Windows\PolicyDefinitions -Force -Recurse -ErrorAction SilentlyContinue}
    #Import to Central Store
Foreach ($sysvolpath in Get-ChildItem "C:\Windows\SYSVOL\sysvol") {
    New-Item "C:\Windows\SYSVOL\sysvol\$sysvolpath\Policies\PolicyDefinitions\" -Force
    Copy-Item -Path "$(Get-Location)\Files\PolicyDefinitions\*" -Destination "C:\Windows\SYSVOL\sysvol\$sysvolpath\Policies\PolicyDefinitions\" -Force -Recurse
}

#Import all manifest exported off our internal DC
$GPOloc = "$(Get-Location)\Files\GPOs"
Foreach ($gpocategory in Get-ChildItem $GPOloc) {
    
    Write-Output "Importing $gpocategory GPOs"

    Foreach ($gpo in (Get-ChildItem "$GPOloc\$gpocategory")) {
        $gpopath = "$GPOloc\$gpocategory\$gpo"
        Write-Output "Importing $gpo"
        New-GPO -Name "$gpo" -Comment "built by ZJP" 
        Import-GPO -BackupGpoName "$gpo" -Path "$gpopath" -TargetName "$gpo" -CreateIfNeeded
    }
}

