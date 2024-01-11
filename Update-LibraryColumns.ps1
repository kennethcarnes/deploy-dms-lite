# Call the Connect-Site function to establish a connection
. ".\Connect-Site.ps1"
Connect-Site

# Add site columns to specified document libraries
$libraries = Import-Csv -Path ".\config\library-definition.csv"
$columnDefinitions = Import-Csv -Path ".\config\site-column-definition.csv"
foreach ($library in $libraries) {
    $libraryName = $library.LibraryTitle
    $list = Get-PnPList -Identity $libraryName -ErrorAction SilentlyContinue
    if ($null -eq $list) {
        Write-Host "Library $libraryName not found. Skipping..." -ForegroundColor Yellow
        continue
    }

    foreach ($column in $columnDefinitions) {
        try {
            Add-PnPField -List $libraryName -Field $column.InternalName
            Write-Host "Added site column $($column.DisplayName) to $libraryName." -ForegroundColor Green
        } catch {
            Write-Error "Error adding site column $($column.DisplayName) to ${libraryName}: $_.Exception.Message"
        }
    }
}

# Disconnect
Disconnect-PnPOnline
Write-Host "Disconnected from SharePoint site." -ForegroundColor Cyan
