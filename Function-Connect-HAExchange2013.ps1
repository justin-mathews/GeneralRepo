<#
    .Synopsis
    Implicit remoting of the Exchange PS Module

    .Description
    Imports the Exchange PowerShell Module into the local session to be used as native commands.

    .Example
    Connect-HAExchange2013 -ComputerName 'MyExch13Srv'

    .Example
    Connect-HAExchange2013 -ComputerName 'MyExch13Srv.contoso.com' -Credential (Get-Credential)

    .Example
    Connect-HAExchange2013 -ComputerName 'MyExch13Srv' -CommandName 'Get-Mailbox','Set-Mailbox','Remove-Mailbox'
#>
function Connect-HAExchange2013 {
    [CmdletBinding()]
    param (
	[Parameter(Mandatory = $true)]
	[string]$ComputerName,
        [Parameter()]
        [string[]]$CommandName,
	[Parameter()]
	[pscredential]$Credential
	)
	BEGIN { }
	
	PROCESS {
        Write-Verbose "Seeing if the Credential parameter was provided"
        if ($PSBoundParameters.ContainsKey('Credential')) {
            Write-Verbose "A Credential Parameter was provided"
            $ExConnectParams = @{'Credential' = $Credential}
        } else {
            Write-Verbose "A credential was not provided. Attempting connection using the current user."
        } # if/else credential
        try {
		    $ExConnectParams += @{
			    'ConfigurationName' = 'Microsoft.Exchange'
			    'ConnectionURI' = ("http://$ComputerName/powershell")
			    'Name' = 'Exchange 2013'
			    'WarningAction' = 'SilentlyContinue'
                'ErrorAction' = 'Stop'
		    }
            Write-Verbose "creating the session to $ComputerName"
		    $MXSession = New-PSSession @ExConnectParams
            $mximport_params = @{
                'Session' = $MXSession
                'AllowClobber' = $true
                'DisableNameChecking' = $true
                'WarningAction' = 'SilentlyContinue'
                'ErrorAction' = 'Stop'
            }
            if ($PSBoundParameters.ContainsKey('CommandName')) {
                $mximport_params += @{'CommandName' = $CommandName}
            } # if CommandName
            Write-Verbose "Importing the session locally"
		    Import-PSSession @mximport_params | Out-Null
        } catch {
            Write-Warning "[ERROR]: An error occurred while connecting to the exchange server: $ComputerName"
            Write-Warning "[ERROR]: $($_.Exception.Message)"
        } # try/catch Import-PSSession
	} # PROCESS
	
	END {}
} # function
