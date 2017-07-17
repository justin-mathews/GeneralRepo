<#
    I would like to add testing for providing a credential
#>
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Get-Module GlobalUserAccounts-Pester | Remove-Module -Force
Import-Module $here\GlobalUserAccounts-Pester.psm1 -Force

Describe "Connect-HAExchange Unit Tests" -Tags 'Unit' {
    InModuleScope GlobalUSerAccounts-Pester {
        Context 'Setup' {
            # Remove any PSSessions prior to testing
            Get-PSSession | Remove-PSSession

            # Test that there are no PSSessions loaded
            if (Get-PSSession) {
                $session = $true
            } else {
                $session = $false
            } # if/else Get-PSSession
        
            It "No session should be loaded" {
                $session | Should Be $false
            }
        } # Context 'Setup'

        # Test connecting to computer without FQDN
        Context 'Testing no FQDN' {        
            $ComputerName = '[MyExchSrv]'
            Connect-HAExchange2013 -ComputerName $ComputerName
            $name = Get-PSSession

            It "There should only be one session" {
                $name.Count | Should Be 1
            }
            It "Should create a PSSession named Exchange 2013" {
                $name.Name | Should Be 'Exchange 2013'
            }
            It "ComputerName should be: $ComputerName" {
                $name.ComputerName | Should Be $computerName
            }
            # Cleaning up the connection
            Remove-PSSession -Id $name.Id
        } # Context 'Testing no FQDN'

        # Test connecting to computer with FQDN
        Context 'Testing with FQDN' {
            $ComputerName = 'MyExchSrv.contoso.com'
            Connect-HAExchange2013 -ComputerName $ComputerName
            $name = Get-PSSession
            It "There should only be one session" {
                $name.Count | Should Be 1
            }
            It "Should create a PSSession named Exchange 2013" {
                $name.Name | Should Be 'Exchange 2013'
            }
            It "ComputerName should be: $ComputerName" {
                $name.ComputerName | Should Be $ComputerName
            }
            # Cleaning up the connection
            Remove-PSSession -Id $name.Id
        } # Context 'Testing with FQDN'

        # Test that the module has been loaded into memory
        Context 'The Module is loaded into memory' {
            $ComputerName = 'MyExchSrv.contoso.com'
            Connect-HAExchange2013 -ComputerName $ComputerName
            $name = Get-PSSession
            $module = Get-Module | Where-Object Name -Like 'tmp_*'
            It "Shoud contain the temporary module" {
                $module.Count | Should Be 1
            }
            # Cleaning up the connection
            Remove-PSSession -Id $name.Id
        } # Context 'The Module is loaded into memory'

        # Test providing command names
        Context 'Providing values to the CommandName parameter' {
            $ComputerName = 'MyExchSrv.contoso.com'
            $cmds = 'Get-Mailbox', 'Get-MailboxDatabase'
            Connect-HAExchange2013 -ComputerName $ComputerName -CommandName $cmds
            $module = Get-Module | Where-Object Name -Like 'tmp_*'
            $name = Get-PSSession
            It "Should open a session with only the specified commands" {
                $cmds = Get-Command -Module $module
                $cmds.Count | Should Be 2
            }
            # Cleaning up the connection
            Remove-PSSession -Id $name.Id
        } # Context 'Providing values to the CommandName parameter'

    } # InModuleScope GlobalUSerAccounts-Pester
} # Describe