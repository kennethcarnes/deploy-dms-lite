# Call the Connect-Site function to establish a connection
. ".\Connect-Site.ps1"
Connect-Site

# Read input file for document library configuration
$libraryMap = Import-Csv -Path ".\config\library-definition.csv"

foreach ($entry in $libraryMap) {
    try {
        # Process each document library as per the configuration
        Write-Verbose "Processing document library: $($entry.LibraryTitle)"

        # Check if the library already exists
        $existingLibrary = Get-PnPList -Identity $entry.LibraryTitle -ErrorAction SilentlyContinue
        if ($null -eq $existingLibrary) {
            # Splatting parameters for New-PnPList for readability and maintainability
            $listParams = @{
                Title = $entry.LibraryTitle           # The title of the document library
                Url = $entry.LibraryUrl               # The URL for the document library
                Template = "DocumentLibrary"          # The template type for a document library
                EnableVersioning = $true              # Enables versioning for the document library
                OnQuickLaunch = $true                 # Adds the library to the Quick Launch navigation
            }

            # Create the document library with the specified parameters
            New-PnPList @listParams
        }

        # Get the created or existing list
        $list = Get-PnPList -Identity $entry.LibraryTitle
        # Set versioning settings
        $list.EnableMinorVersions = $true
        $list.EnableModeration = $true
        $list.DraftVersionVisibility = 2
        $list.ForceCheckout = $true
        $list.Update()
    
        Write-Verbose "Successfully configured document library: $($entry.LibraryTitle)"
    }
    catch {
        # Error handling with detailed error message
        Write-Host "Failed to create or configure document library $($entry.LibraryTitle). Please check details in the error log." -ForegroundColor Red
        Write-Error $_.Exception.ToString()
    }
}

# Disconnect from the SharePoint site
Disconnect-PnPOnline -ErrorAction SilentlyContinue
Write-Host "Disconnected from SharePoint site." -ForegroundColor Cyan
