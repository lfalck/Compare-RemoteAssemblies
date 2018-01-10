<#PSScriptInfo
.VERSION 1.0.1
.GUID 2ec8a6d3-ccea-46cc-8eb9-2f5a70a5506f
.AUTHOR Ludvig Falck
.DESCRIPTION Display a searchable, sortable and filterable list of local and remote assemblies.
.COMPANYNAME 
.COPYRIGHT 
.TAGS 
.LICENSEURI https://github.com/lfalck/Compare-RemoteAssemblies/LICENSE
.PROJECTURI https://github.com/lfalck/Compare-RemoteAssemblies
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
#>

#Requires -Version 3

function Compare-RemoteAssemblies {
<#
.SYNOPSIS
	Display a searchable, sortable and filterable list of local and remote assemblies.

.DESCRIPTION
	Display a searchable, sortable and filterable list of local and remote assemblies. 
	The list of servers to target, the folders to search, and the filename filter is configurable.
	The configuration file Compare-RemoteAssemblies.config will be created on the first run in the script folder.

.LINK
	https://github.com/lfalck/Compare-RemoteAssemblies
#>
    Set-StrictMode -Version Latest 
    $ErrorActionPreference = "Stop"

    function LoadSettings($PSScriptRoot, $ConfigFileName) {
        if (!(Test-Path $PSScriptRoot\$ConfigFileName)) { 
            Write-Host "`r`nCould not find settings, creating new file at $PSScriptRoot\$ConfigFileName...`r`n"
            CreateConfig($ConfigFileName)
        } 
        Write-Host "`r`nLoading settings from $PSScriptRoot\$ConfigFileName...`r`n"
        [xml]$configFile = Get-Content $PSScriptRoot\$ConfigFileName
        return $configFile
    }

    function GetAssembliesFromServers($ConfigFile) {
        $assemblyFilter = $ConfigFile.Settings.AssemblyFilter
        [array]$servers = $ConfigFile.Settings.Servers.Server.ServerName
        [array]$folders = $ConfigFile.Settings.Servers.Server.Folder
        Write-Host "Connecting to servers $servers...`r`n"
	
        $selectAssemblyInfo = {
            Get-ChildItem $args[0] -Include $args[1] -Recurse | 
                Select-Object Name, FileVersion, AssemblyVersion, LastWriteTime, Length, FullName, VersionInfo
        }
	
        $assemblyList = $servers | ForEach-Object {
            $i = 0;
            if ($_ -eq $env:computername -or $_ -eq "localhost") {
                Invoke-Command -ArgumentList $folders[0], $assemblyFilter -ScriptBlock $selectAssemblyInfo | 
                    Add-Member -MemberType ScriptProperty -Name PSComputerName -Value {$env:computername.ToLower() + " (localhost)"} -PassThru
            }
            else {
                Invoke-Command -ArgumentList $folders[0], $assemblyFilter -ComputerName $_ -ScriptBlock $selectAssemblyInfo
            }
            $i++;
        }
        return $assemblyList
    }

    function DisplayAssemblyList($AssemblyList, $Title) {
        $AssemblyList | 
            Select-Object @{Name = 'Server'; Expression = {$_.PSComputerName}}, 
        Name, 
        @{Name = 'FileVersion'; Expression = {$_.VersionInfo.FileVersion}}, 
        @{Name = 'AssemblyVersion'; Expression = {[Reflection.AssemblyName]::GetAssemblyName($_.FullName).Version}}, 
        LastWriteTime, 
        @{Name = 'Size'; Expression = {$_.Length}}, 
        @{Name = 'Folder'; Expression = { Split-Path $_.FullName -Parent | Split-Path -Leaf}} |
            Sort-Object -Descending Name | 
            Out-GridView -Title $Title -Wait
    }


    function CreateConfig($FileName) {
        [xml]$doc = New-Object System.Xml.XmlDocument
        $root = $doc.CreateElement("Settings")

        $filter = $doc.CreateElement("AssemblyFilter")
        $filter.InnerText = "System*.dll"
 
        $servers = $doc.CreateElement("Servers")
    
        $server = $doc.CreateElement("Server")
    
        $serverName = $doc.CreateElement("ServerName")
        $serverName.InnerText = "localhost"

        $additionalServersComment = $doc.CreateComment(
            "<Server>
		  <ServerName>Name or IP of server</ServerName>
		  <Folder>Full path to folder</Folder>
		</Server>")

        $folder = $doc.CreateElement("Folder")
        $folder.InnerText = "$env:windir\Microsoft.NET\assembly\GAC_MSIL\"
	
        $server.AppendChild($serverName) | Out-Null
        $server.AppendChild($folder) | Out-Null
        $servers.AppendChild($server) | Out-Null
        $servers.AppendChild($additionalServersComment) | Out-Null
        $root.AppendChild($filter) | Out-Null
        $root.AppendChild($servers) | Out-Null
        $doc.AppendChild($root) | Out-Null
    
        $doc.save("$PSScriptRoot\$FileName")
    }

    try {
        $scriptName = ([IO.FileInfo]$MyInvocation.MyCommand.Name).BaseName 
        $configFileName = "$scriptName.config"
        $configFile = LoadSettings $PSScriptRoot $configFileName
        $assemblyList = GetAssembliesFromServers $configFile
        DisplayAssemblyList $assemblyList $scriptName
    }
    catch {
        Write-Host $_.Exception.Message  -ForegroundColor Red -BackgroundColor Black 
        Read-Host -Prompt "`r`nPress enter to exit"
    }
}
Compare-RemoteAssemblies