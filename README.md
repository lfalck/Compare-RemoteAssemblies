# About
**Compare-RemoteAssemblies** displays a searchable, sortable and filterable list of local and remote assemblies. 

The idea is to make it easy to tell what version of an assembly that is deployed to which environment.

[Link to PowerShell Gallery](https://www.powershellgallery.com/packages/Compare-RemoteAssemblies).

# Installation

**Install from PowerShell Gallery (recommended)**  
`PS> Install-Script -Name Compare-RemoteAssemblies`

Install-Script uses PowerShellGet which is included on Windows 10 and Windows Server 2016. See [this](https://docs.microsoft.com/en-us/powershell/gallery/psget/get_psget_module) link for installation instructions on older platforms.


It is also possible to download and run the script directly: [Download from GitHub](https://raw.githubusercontent.com/lfalck/Compare-RemoteAssemblies/master/Compare-RemoteAssemblies/Compare-RemoteAssemblies.ps1) (right click, save link as...).


# Usage

**Installed**  
`PS> Compare-RemoteAssemblies`

**Downloaded**  
`PS> .\Compare-RemoteAssemblies.ps1`

The list of servers to target, the folders to look in, and the filter to use is read from Compare-RemoteAssemblies.config which will be created on the first run in the script folder.

# Screenshot

<img src="https://www.dropbox.com/s/1h8h1izjp3xp9jd/compare-remoteassemblies.png?raw=1"/>
