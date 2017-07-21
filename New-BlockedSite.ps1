<#
    .SYNOPSIS
    Creates a new DNS record on the DNS server provided to block access to the site provided.

    .DESCRIPTION
    This function came about as several remote locations wanted to block sites that were not safe for work.
    You can easily do this by adding a primary zone forwarder to the DNS Server. This function is simply here
    to help expedite that process and allow you to add several sites to several servers all at the same time.

    .PARAMETER DomainController
    Provide the name of the DNS server you would like to add the record to. This supports multiple servers.

    .PARAMETER Site
    Provide the name of the site you want to block. Ex: "pornhub.com"

    .EXAMPLE
    New-BlockedSite -DomainController "MyDC1" -Site "pornhub.com"
    
    .EXAMPLE
    New-BlockedSite -DomainController "NADC1","EUDC1","ASDC1" -Site "pornhub.com","killmyself.com","bombsarefun.com"
#>
function New-BlockedSite {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$DomainController,
        [Parameter(Mandatory = $true)]
        [string[]]$Site
    )
    BEGIN {} # Begin
    PROCESS {
        foreach ($srv in $DomainController) {
            Write-Verbose "Testing Connection to $srv"
            if (Test-Connection -ComputerName $srv -Count 1 -Quiet) {
                Write-Verbose "Connection successful"
                foreach ($s in $Site) {
                    try {
                        $params = @{
                            'ComputerName' = $srv
                            'Name' = $s
                            'ZoneFile' = "$s.dns"
                            'ErrorAction' = 'Stop'
                        }
                        Add-DnsServerPrimaryZone @params
                        Write-Verbose "Successfully created new zone: $s"
                    } catch {
                        Write-Warning "[Error]: An error has occurred while attempting to create the zone: $s"
                        Write-warning "[Error]: $($_.Exception.Message)"
                    } # try/catch Add-DnsServerPrimaryZone
                } # foreach $site
            } else {
                Write-Warning "[Error]: Unable to contact $srv"
            } # if/else Test-Connection
        } # foreach $srv
    } # Process
    END {} # End
} # function
