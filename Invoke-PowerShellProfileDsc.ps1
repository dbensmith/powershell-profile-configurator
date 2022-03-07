Configuration PoshProfile
{
    Node "localhost"
    {
        File PoshProfile
        {
            DestinationPath = [Environment]::GetFolderPath('MyDocuments') + '\PowerShell' + '\Microsoft.PowerShell_profile.ps1'
            Ensure = "Present" # Ensure the directory is Present on the target node.
            SourcePath =  = "C:\Repos\GitHub\powershell-profile-configurator\Microsoft.PowerShell_profile.ps1"
        }

        Log AfterDirectoryCopy
        {
            # The message below gets written to the Microsoft-Windows-Desired State Configuration/Analytic log
            Message = "Finished running the file resource with ID PoshProfile"
            DependsOn = "[File]PoshProfile" # Depends on successful execution of the File resource.
        }
    }
}