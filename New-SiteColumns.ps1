$VerbosePreference = 'Continue'

# Call the Connect-Site function to establish a connection
. ".\Connect-Site.ps1"
Connect-Site

foreach ($column in $columnDefinitions) {
    try {
        # Check if the field already exists
        $fieldExists = Get-PnPField -Identity $column.InternalName -ErrorAction SilentlyContinue
        if ($null -eq $fieldExists) {
            # Handling choice fields with specified choices
            if ($column.Type -eq "Choice" -and $column.Choices) {
                $choices = $column.Choices -split ";"
                $fieldParams = @{
                    DisplayName = $column.DisplayName
                    InternalName = $column.InternalName
                    Type = $column.Type
                    Group = $addedColumnsGroup
                    Choices = $choices
                    Required = [System.Convert]::ToBoolean($column.Required)
                }
                Add-PnPField @fieldParams
            }
            # Handling calculated fields with formulas
            elseif ($column.Type -eq "Calculated") {
                $fieldParams = @{
                    DisplayName = $column.DisplayName
                    InternalName = $column.InternalName
                    Type = $column.Type
                    Group = $addedColumnsGroup
                    Required = [System.Convert]::ToBoolean($column.Required)
                    Formula = $column.Formula
                }
                Add-PnPField @fieldParams
            }            
            # Handling other field types
            else {
                $fieldParams = @{
                    DisplayName = $column.DisplayName
                    InternalName = $column.InternalName
                    Type = $column.Type
                    Group = $addedColumnsGroup
                    Required = [System.Convert]::ToBoolean($column.Required)
                }
                Add-PnPField @fieldParams
            }
            Write-Host "Site column $($column.DisplayName) created." -ForegroundColor Green
        } else {
            Write-Host "Site column $($column.DisplayName) already exists." -ForegroundColor Cyan
        }
    } catch {
        Write-Error "Error creating site column $($column.DisplayName): $_.Exception.Message"
    }
}

# Disconnect from the SharePoint site
Disconnect-PnPOnline
Write-Host "Disconnected from SharePoint site." -ForegroundColor Cyan
