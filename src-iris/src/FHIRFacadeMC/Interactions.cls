Class FHIRFacadeMC.Interactions Extends HS.FHIRServer.Storage.Json.Interactions
{

Method Add(pResourceObj As %DynamicObject, pResourceIdToAssign As %String = "", pHttpMethod = "POST") As %String
{
	if pResourceObj.resourceType="Patient" {
		set tResourceObj=##class(FHIRFacadeMC.MyResource.Patient).PatientAdd(pResourceObj,pResourceIdToAssign)
	}
	else {
		$$$ThrowFHIR($$$HSFHIRErrResourceNotSupported,pResourceObj.resourceType,$$$OutcomeNotSupported(404))
	}
	return pResourceObj.id
}

Method Delete(pResourceType As %String, pResourceId As %String) As %String
{
	set vId=""
	if pResourceType="Patient" {
		set vId=##class(FHIRFacadeMC.MyResource.Patient).PatientDelete(pResourceId)
	}
	else {
		$$$ThrowFHIR($$$HSFHIRErrResourceNotSupported,pResourceType,$$$OutcomeNotSupported(404))
	}
	return vId
}

Method Read(pResourceType As %String, pResourceId As %String, pVersionId As %String = "") As %DynamicObject
{
	if pResourceType="Patient" {
		set obj=##class(FHIRFacadeMC.MyResource.Patient).PatientRead(pResourceId)
	}
	elseif pResourceType="Observation" {
		set obj=##class(FHIRFacadeMC.MyResource.Patient).ObservationRead(pResourceId)
	}
	elseif pResourceType="ServiceRequest" {
		set obj=##class(FHIRFacadeMC.MyResource.Patient).ServiceRequestRead(pResourceId)
	}
	elseif pResourceType="Condition" {
		set obj=##class(FHIRFacadeMC.MyResource.Patient).ConditionRead(pResourceId)
	}
	elseif pResourceType="Procedure" {
		set obj=##class(FHIRFacadeMC.MyResource.Patient).ProcedureRead(pResourceId)
	}
	elseif pResourceType="FamilyMemberHistory" {
		set obj=##class(FHIRFacadeMC.MyResource.Patient).FamilyMemberHistoryRead(pResourceId)
	}
	else {
		$$$ThrowFHIR($$$HSFHIRErrResourceNotSupported,pResourceType,$$$OutcomeNotSupported(404))
	}
	return obj
}

Method Search(pResourceType As %String, pCompartment As %String, pCompartmentId As %String, pParameters As HS.FHIRServer.API.Data.QueryParameters = "", ByRef pSortKeys = "") As HS.FHIRServer.Util.SearchResult
{
	set tResultSet=##class(HS.FHIRServer.Util.SearchResult).Create()
	if pResourceType="Patient" {
		if pParameters.Count()=0 {
			// no query parameter
			$$$FHIRAddError(tResultSet.SearchStatus, $$$ERROR($$$HSFHIRErrInvalidQueryParameter, "No query parameters", $$$OutcomeIs(400, "warning", "incomplete")))
		}
		set tResultSet=##class(FHIRFacadeMC.MyResource.Patient).PatientSearch(pParameters)
	}
	else {
		// resource not supported for this interaction
		$$$ThrowFHIR($$$HSFHIRErrResourceNotSupported,pResourceType,$$$OutcomeNotSupported(404))
	}
	return tResultSet
}

Method History(pResourceType As %String, pResourceId As %String, pSince As %String, pAt As %String) As HS.FHIRServer.Util.SearchResult
{
	#dim tResultSet as HS.FHIRServer.Util.SearchResult = ##class(HS.FHIRServer.Util.SearchResult).Create()
	if pResourceType="Patient" {
		set tResultSet=##class(FHIRFacadeMC.MyResource.Patient).PatientHistory(pResourceId)
	}
	else {
		$$$ThrowFHIR($$$HSFHIRErrResourceNotSupported,pResourceType,$$$OutcomeNotSupported(404))
	}
	return tResultSet
}

}
