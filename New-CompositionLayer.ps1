<#
.SYNOPSIS
Creates the basic directory structure and empty Terraform files for a new Composition layer service.

.PARAMETER ServiceName
The name of the new service or application for the Composition layer (e.g., "WebApp", "BatchJob"). This will be created under the 'composition' directory.

.PARAMETER BasePath
The root path of your Terraform project (where 'composition' and 'infrastructure_modules' directories reside). Defaults to the current directory.

.EXAMPLE
.\New-CompositionLayer.ps1 -ServiceName MyWebApp
Creates ./composition/MyWebApp/ap-northeast-1/{dev, prd, stg}/ with standard .tf files inside each environment.

.EXAMPLE
.\New-CompositionLayer.ps1 -ServiceName AnotherApp -BasePath C:\tf-projects\my-project
Creates C:\tf-projects\my-project\composition\AnotherApp\... structure.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$ServiceName,

    [Parameter(Mandatory=$false)]
    [string]$BasePath = ".", # Default to current directory

    [Parameter(Mandatory=$false)]
    [string]$RegionName = "ap-northeast-1" # Default region folder
)

# --- Configuration ---
$CompositionBaseDir = "composition"
$Environments = @("dev", "prd", "stg")
# Standard files to create in each environment directory
$FilesToCreate = @(
    "local.tf",
    "main.tf",
    "provider.tf",
    "terraform.tfvars",
    "variables.tf", # Corrected typo from 'valiable'
    "outputs.tf"
)
# --- End Configuration ---

# Construct paths
$CompositionPath = Join-Path -Path $BasePath -ChildPath $CompositionBaseDir
$ServicePath = Join-Path -Path $CompositionPath -ChildPath $ServiceName
$RegionPath = Join-Path -Path $ServicePath -ChildPath $RegionName

# --- Directory and File Creation Logic ---
Write-Host "Creating structure for Composition layer '$ServiceName'..." -ForegroundColor Cyan

try {
    # Create base service and region directories
    if (-not (Test-Path $RegionPath)) {
        $null = New-Item -ItemType Directory -Path $RegionPath -Force
        Write-Host "Created directory: $RegionPath"
    } else {
         Write-Host "Directory already exists: $RegionPath"
    }

    # Loop through environments
    foreach ($envName in $Environments) {
        $envPath = Join-Path -Path $RegionPath -ChildPath $envName
        if (-not (Test-Path $envPath)) {
            $null = New-Item -ItemType Directory -Path $envPath -Force
            Write-Host " - Created environment directory: $envPath"
        } else {
             Write-Host " - Environment directory already exists: $envPath"
        }


        # Loop through files to create
        Write-Host "   Creating standard files in '$envName'..."
        foreach ($fileName in $FilesToCreate) {
            $filePath = Join-Path -Path $envPath -ChildPath $fileName
            if (-not (Test-Path $filePath)) {
                $null = New-Item -ItemType File -Path $filePath -Force
                Write-Host "    - Created file: $filePath"
            } else {
                Write-Host "    - File already exists, skipped: $filePath"
            }
        }
    }

    Write-Host "Successfully created Composition layer structure for '$ServiceName'." -ForegroundColor Green

} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
}