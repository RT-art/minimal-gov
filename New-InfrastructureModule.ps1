<#
.SYNOPSIS
Creates the basic directory and empty Terraform files for a new Infrastructure module.

.PARAMETER ModuleName
The name of the new infrastructure module (e.g., "vpc", "rds", "compute"). This will be created under the 'infrastructure_modules' directory.

.PARAMETER BasePath
The root path of your Terraform project (where 'composition' and 'infrastructure_modules' directories reside). Defaults to the current directory.

.EXAMPLE
.\New-InfrastructureModule.ps1 -ModuleName rds
Creates ./infrastructure_modules/rds/ with main.tf, variables.tf, outputs.tf.

.EXAMPLE
.\New-InfrastructureModule.ps1 -ModuleName alb -BasePath C:\tf-projects\my-project
Creates C:\tf-projects\my-project\infrastructure_modules\alb\... structure.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ModuleName,

    [Parameter(Mandatory=$false)]
    [string]$BasePath = "." # Default to current directory
)

# --- Configuration ---
$InfraBaseDir = "infrastructure_modules"
# Standard files to create in the module directory
$FilesToCreate = @(
    "main.tf",
    "variables.tf", # Corrected typo from 'valiable'
    "outputs.tf"
    #"locals.tf" # Optionally add locals.tf if you always use it
)
# --- End Configuration ---

# Construct paths
$InfraPath = Join-Path -Path $BasePath -ChildPath $InfraBaseDir
$ModulePath = Join-Path -Path $InfraPath -ChildPath $ModuleName

# --- Directory and File Creation Logic ---
Write-Host "Creating structure for Infrastructure module '$ModuleName'..." -ForegroundColor Cyan

try {
    # Create module directory
    if (-not (Test-Path $ModulePath)) {
        $null = New-Item -ItemType Directory -Path $ModulePath -Force
        Write-Host "Created directory: $ModulePath"
    } else {
        Write-Host "Directory already exists: $ModulePath"
    }

    # Loop through files to create
    Write-Host "  Creating standard files..."
    foreach ($fileName in $FilesToCreate) {
        $filePath = Join-Path -Path $ModulePath -ChildPath $fileName
        if (-not (Test-Path $filePath)) {
            $null = New-Item -ItemType File -Path $filePath -Force
            Write-Host "   - Created file: $filePath"
        } else {
            Write-Host "   - File already exists, skipped: $filePath"
        }
    }

    Write-Host "Successfully created Infrastructure module structure for '$ModuleName'." -ForegroundColor Green

} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
}