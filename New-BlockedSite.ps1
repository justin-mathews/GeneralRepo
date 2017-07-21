function New-HABlockedSite {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string[]]$DomainController,
        [Parameter()]
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