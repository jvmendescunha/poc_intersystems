Class FHIRFacadeMC.API.Module Extends apiPub.core.service
{

Parameter Cors = 1;

Parameter OASPath As %String = "Get:/_spec";

Parameter DispatchClass As %String = "FHIRFacadeMC.API.Rest";

/// When the Dispatch class is also a Business Service Component and has a different name
Parameter DispatchBSName As %String = "FHIRFacadeMC.API.Rest";

/// Useful to treat documentation and api (urls) separately (different web applications)
Parameter DispatchBaseURL As %String;

/// If false allows API Calling
Parameter OnlyOAS As %Boolean = 0;

/// Use TracerBSName for monitoring
Parameter Traceable As %Boolean = 0;

Parameter TracerBSName = "apiPub.tracer.bs";

Parameter BeautifyJsonBodyResponse = 0;

Parameter BeautifyJsonBodyRequest = 0;

Parameter APIDomain = "App";

/// 1 for basic or 2 for bearer token
Parameter AuthMethod = 1;

/// Show bearer token if traceable = 1 and AuthMethod = 2
Parameter DecodeBearerToken = 1;

/// If AuthMethod = 2, default (validateAuthorization) method validates using this Oauth Client Id
/// You can also overload this method 
Parameter OAuthClient;

/// Automatically creates app web appplication 
ClassMethod CreateProjection(classname As %String) As %Status [ CodeMode = generator, ForceGenerate ]
{
	Set tSC = $System.Status.OK()
	Try {
        Set tCurrentNS = $namespace
        Set appPath=$Replace("/fhirfacade","{namespace}",tCurrentNS)
        zn "%SYS" 
        Set webName = appPath
        Set webProperties("DispatchClass") = "FHIRFacadeMC.API.Module" 
        Set webProperties("NameSpace") = tCurrentNS
        Set webProperties("Description") = "FHIRFacade API" 
        Set webProperties("Enabled") = 1 
        Set webProperties("AutheEnabled") = 64 
        Set webProperties("DeepSeeEnabled")=1 
        Set webProperties("CorsHeadersList")="*"
        Set webProperties("CorsAllowlist")="*"
        Set webProperties("MatchRoles")="%All:%All,:%All"
        If '(##class(Security.Applications).Exists(webName)) {
            Set tSC = ##class(Security.Applications).Create(webName, .webProperties)
            If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC) 
            If tSC=1 {
                Write !,"Creating App Application ",webName,"..."
            }
        }
        zn tCurrentNS
    }
	Catch(e) {
        zn tCurrentNS
		Set tSC = e.AsStatus()
	}
	Quit tSC
}

}
