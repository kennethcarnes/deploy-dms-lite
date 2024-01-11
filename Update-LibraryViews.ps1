# Call the Connect-Site function to establish a connection
. ".\Connect-Site.ps1"
Connect-Site

# Load column and library information from CSV files
$columnDefinitions = Import-Csv -Path ".\config\site-column-definition.csv"
$libraries = Import-Csv -Path ".\config\library-definition.csv"

# Define the specific views we want to update
$targetViews = @("All Documents", "Approve/reject Items", "My Submissions")

# Iterate over each library defined in the CSV
foreach ($library in $libraries) {
    $libraryName = $library.LibraryTitle
    # Iterate over each column defined in the CSV
    foreach ($column in $columnDefinitions) {
        # Get all views of the current library
        $views = Get-PnPView -List $libraryName
        # Iterate over each view
        foreach ($view in $views) {
            # Check if the current view is one of the target views
            if ($view.Title -in $targetViews) {
                try {
                    # Fetch the current state of the view
                    $updatedView = Get-PnPView -List $libraryName -Identity $view.Id
                    $viewFields = $updatedView.ViewFields

                    # Check if the view does not already contain the column
                    if ($viewFields -notcontains $column.InternalName) {
                        # Add the new column to the existing fields of the view
                        $newViewFields = $viewFields + $column.InternalName
                        # Update the view with the new fields array
                        Set-PnPView -List $libraryName -Identity $updatedView.Id -Fields $newViewFields
                        Write-Host "Updated view $($updatedView.Title) in $libraryName to include $($column.DisplayName)." -ForegroundColor Green
                    } else {
                        # If the view already contains the column, log a message
                        Write-Host "View $($updatedView.Title) in $libraryName already contains $($column.DisplayName)." -ForegroundColor Yellow
                    }
                } catch {
                    # Provide a clear, user-friendly error message, and log the full exception details
                    Write-Error "Error updating view for $($column.DisplayName) in $libraryName. Detailed Error: $($_.Exception.ToString())"
                } finally {
                    # Code in this block will run regardless of whether the try block succeeded or caught an exception
                    Write-Verbose "Completed processing for view $($view.Title) in $libraryName."
                }
            }
        }
    }
}

# Disconnect from SharePoint site
Disconnect-PnPOnline
Write-Host "Disconnected from SharePoint site." -ForegroundColor Cyan
