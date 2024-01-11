function Connect-Site {
    # Prompt for the URL of the SharePoint site within the function
    $siteUrl = Read-Host "Please enter the URL of your SharePoint site (e.g., https://yourcompany.sharepoint.com/sites/yoursite)"

    # Check if PnP.PowerShell module is installed
    if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
        Install-Module -Name PnP.PowerShell -AllowClobber -Scope CurrentUser
    }
    Import-Module PnP.PowerShell

    try {
        Write-Host "Please log in through the interactive browser to connect to SharePoint site at $siteUrl..." -ForegroundColor Cyan
        Connect-PnPOnline -Url $siteUrl -Interactive -ErrorAction Stop
        Write-Host "Connected to SharePoint site at $siteUrl" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to connect to SharePoint site. Error: $_.Exception"
        exit
    }
}