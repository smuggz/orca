<#

226 - Check Safe Links Policy Exists for all domains

#>

using module "..\ORCA.psm1"

class ORCA226 : ORCACheck
{
    <#
    
        CONSTRUCTOR with Check Header Data
    
    #>

    ORCA226()
    {
        $this.Control=226
        $this.Services=[ORCAService]::OATP
        $this.Area="Advanced Threat Protection Policies"
        $this.Name="Safe Links Policy Rules"
        $this.PassText="Each domain has a Safe Link policy applied to it"
        $this.FailRecommendation="Apply a Safe Links policy to every domain"
        $this.Importance="Office 365 ATP Safe Links policies are applied using rules. The recipient domain condition is the most effective way of applying the Safe Links policy, ensuring no users are left without protection. If polices are applied using group membership make sure you cover all users through this method. Applying polices this way can be challenging, users may left unprotected if group memberships are not accurate and up to date."
        $this.ExpandResults=$True
        $this.CheckType=[CheckType]::ObjectPropertyValue
        $this.ObjectType="Domain"
        $this.ItemName="Policy"
        $this.DataType="Priority"
        $this.Links= @{
            "Security & Compliance Center - Safe links"="https://protection.office.com/safelinksconverged"
            "Recommended settings for EOP and Office 365 ATP security"="https://docs.microsoft.com/en-us/microsoft-365/security/office-365-security/recommended-settings-for-eop-and-office365-atp#office-365-advanced-threat-protection-security"
        }
    }

    <#
    
        RESULTS
    
    #>

    GetResults($Config)
    {

        ForEach($AcceptedDomain in $Config["AcceptedDomains"]) 
        {
    
            #$AcceptedDomain.Name

            $DomainPolicyExists = $False

            # Set up the config object
            $ConfigObject = [ORCACheckConfig]::new()

            $ConfigObject.Object=$($AcceptedDomain.Name)

            # Go through each Safe Links Policy

            ForEach($Rule in ($Config["SafeLinksRules"] | Sort-Object Priority)) 
            {
                if($null -eq $Rule.SentTo -and $null -eq $Rule.SentToMemberOf -and $Rule.State -eq "Enabled")
                {
                    if($Rule.RecipientDomainIs -contains $AcceptedDomain.Name -and $Rule.ExceptIfRecipientDomainIs -notcontains $AcceptedDomain.Name)
                    {
                        # Policy applies to this domain

                        $DomainPolicyExists = $True

                        $ConfigObject.ConfigItem=$($Rule.SafeLinksPolicy)
                        $ConfigObject.ConfigData=$($Rule.Priority)
                        $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Pass")

                        $this.AddConfig($ConfigObject)
                    }
                }

            }

            if($DomainPolicyExists -eq $False)
            {
                # No policy is applying to this domain

                $ConfigObject.ConfigItem="No Policy Applying"
                $ConfigObject.SetResult([ORCAConfigLevel]::Standard,"Fail")            
    
                $this.AddConfig($ConfigObject)     
            }

        }

    }

}