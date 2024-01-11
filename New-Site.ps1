# Check if PnP.PowerShell module is installed
if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Install-Module -Name PnP.PowerShell -AllowClobber -Scope CurrentUser
}
Import-Module PnP.PowerShell

# Prompt for SharePoint Admin Center URL
$adminUrl = Read-Host "Please enter your SharePoint Admin Center URL (e.g., https://yourcompany-admin.sharepoint.com)"

try {
    Connect-PnPOnline -Url $adminUrl -Interactive -ErrorAction Stop
    Write-Host "Connected to SharePoint Admin Center at $adminUrl" -ForegroundColor Green
}
catch {
    # Log the full exception details
    Write-Error "Failed to connect to SharePoint Admin Center. Error: $_.Exception"
    exit
}

# Prompt for new site URL
$siteUrl = Read-Host "Enter the URL for the new site (e.g., https://yourcompany.sharepoint.com/sites/yoursite)"

try {
    # Splat for New-PnPSite
    $siteParams = @{
        Type = "TeamSiteWithoutMicrosoft365Group"
        Url = $siteUrl
        TimeZone = "UTCMINUS0600_CENTRAL_TIME_US_AND_CANADA"
        Lcid = 1033
        Wait = $true
    }

    New-PnPSite @siteParams
    Write-Host "Team site created successfully at $siteUrl." -ForegroundColor Green

    # Connect to the new site
    Connect-PnPOnline -Url $siteUrl -Interactive

    # Clear quick launch but keep the "Home" node
    Get-PnPNavigationNode -Location QuickLaunch | Where-Object { $_.Title -ne "Home" } | Remove-PnPNavigationNode -Force

}
catch {
    # Provide a clear, user-friendly error message and log the full exception details
    Write-Host "An error occurred while creating the site: $_.Exception" -ForegroundColor Red
}
finally {
    # Disconnect from the SharePoint Admin Center
    Disconnect-PnPOnline -ErrorAction SilentlyContinue
    Write-Host "Disconnected from SharePoint Admin Center." -ForegroundColor Cyan
}
