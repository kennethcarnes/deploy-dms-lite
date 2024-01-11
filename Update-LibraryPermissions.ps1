# Call the Connect-Site function to establish a connection
. ".\Connect-Site.ps1"
Connect-Site

try {
    # Read input file for document library configuration
    $libraryMap = Import-Csv -Path ".\config\library-definition.csv"

    foreach ($entry in $libraryMap) {
        try {
            $libraryName = $entry.LibraryUrl.Split('/')[-1]
            Write-Verbose "Processing library: $libraryName"

            $approverGroup = "$libraryName Approvers"
            $contributorGroup = "$libraryName Contributors"
            $readerGroup = "$libraryName Readers"

            foreach ($group in @($approverGroup, $contributorGroup, $readerGroup)) {
                if (-not (Get-PnPGroup -Identity $group -ErrorAction SilentlyContinue)) {
                    New-PnPGroup -Title $group
                    Write-Host "Group $group created." -ForegroundColor Green
                }
            }

            $list = Get-PnPList -Identity $libraryName -ErrorAction SilentlyContinue
            if ($null -eq $list) {
                Write-Host "Library $libraryName does not exist. Skipping..." -ForegroundColor Yellow
                continue
            }

            $list.BreakRoleInheritance($true, $false)
            $list.Update()
            Invoke-PnPQuery

            Set-PnPListPermission -Identity $libraryName -Group $approverGroup -AddRole "Full Control"
            Set-PnPListPermission -Identity $libraryName -Group $contributorGroup -AddRole "Contribute"
            Set-PnPListPermission -Identity $libraryName -Group $readerGroup -AddRole "Read"

            Write-Host "Permissions set for library $libraryName." -ForegroundColor Green
        }
        catch {
            Write-Host "An error occurred for library $libraryName. Error: $_.Exception.ToString()" -ForegroundColor Red
        }
    }
}
finally {
    # Disconnect from SharePoint site
    Disconnect-PnPOnline -ErrorAction SilentlyContinue
    Write-Host "Disconnected from SharePoint site." -ForegroundColor Cyan
}
