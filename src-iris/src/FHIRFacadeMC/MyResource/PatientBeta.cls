Include HS.FHIRServer

Class FHIRFacadeMC.MyResource.PatientBeta Extends apiPub.core.jsonBuilder
{

ClassMethod GetDataFromMongo(pResourceId As %String, Output pResponse As MarisaCare.Interop.Model.PatientResponse) As %Status
{
	Set tStatus = $$$OK
	#dim tService as Ens.BusinessService
	Set pResourceId=$Piece(pResourceId,"-",1)
	//--------------------
	// Instantiate the BS
	//--------------------
	set tStatus=##class(Ens.Director).CreateBusinessService("Patient BS",.tService)
	if $$$ISERR(tStatus) $$$ThrowFHIR($$$GeneralError, $system.Status.GetErrorText(tStatus), $$$OutcomeInvalid(500))
	set tResponse= ##class(MarisaCare.Interop.Model.PatientResponse).%New()
	//------------------
	// Send the request
	//------------------
	set tStatus=tService.GetPatientDataFromMongo(pResourceId,.pResponse)
	Quit tStatus
}

ClassMethod GetCachedObj(pResourceId As %String) As FHIRFacadeMC.Table.CacheSDA
{
	//--------------------
	// Get the Cached Data
	//--------------------
	Set tCachedObj = ##class(FHIRFacadeMC.Table.CacheSDA).SDAIndexOpen("MC",$Piece(pResourceId,"-",1),.tStatus)
	if ('$IsObject(tCachedObj))||($Replace($H,",","")-($Replace(tCachedObj.TS,",","")>120)) {
		set tStatus=..GetDataFromMongo(pResourceId,.pResponse)
		if $$$ISERR(tStatus) $$$ThrowFHIR($$$GeneralError, $system.Status.GetErrorText(tStatus), $$$OutcomeInvalid(500))
		Set tCachedObj = ##class(FHIRFacadeMC.Table.CacheSDA).SDAIndexOpen("MC",$Piece(pResourceId,"-",1),.tStatus)
		if $$$ISERR(tStatus) $$$ThrowFHIR($$$GeneralError, $system.Status.GetErrorText(tStatus), $$$OutcomeInvalid(500))
	}
	Quit tCachedObj
}

ClassMethod GetCachedSDAResource(pResourceId As %String, pSDAType As %String = "HS.SDA3.Container", pContainerPath As %String = "") As HS.SDA3.SuperClass
{
	//--------------------
	// Get the Cached Data
	//--------------------
	Set tCachedObj = ..GetCachedObj($Piece(pResourceId,",",1))
	If '$IsObject(tCachedObj.JSONStream) {
		$$$ThrowFHIR($$$GeneralError, "Invalid SDA Data", $$$OutcomeNotFound)
	}
	Set tSourceContent = {}.%FromJSON(tCachedObj.JSONStream)
	If pContainerPath'="" Set tSourceContent = ..g(tSourceContent,pContainerPath)
	If tSourceContent = "" $$$ThrowFHIR($$$GeneralError, "Invalid ResourceId", $$$OutcomeNotFound)
   	set key = $Piece(pSDAType,".",*)
	Set tSDAJson = {}
    do ..s(tSDAJson,key,tSourceContent)
	Set tObj = $ClassMethod(pSDAType,"%New")
	Set tSC = ##class(apiPub.core.converter).JSONToObj(tSDAJson,pSDAType,.tObj)
	If 'tSC $$$ThrowFHIR($$$GeneralError, $system.Status.GetErrorText(tSC), $$$OutcomeNotFound)
	Quit tObj
}

ClassMethod ConditionRead(pResourceId As %String) As %DynamicObject
{
	set tSDADiagnosis = ..GetCachedSDAResource(pResourceId,"HS.SDA3.Diagnosis","Diagnoses.Diagnosis."_(+$Piece(pResourceId,"-",2)-1))
	If '$IsObject(tSDADiagnosis) {
		$$$ThrowFHIR($$$GeneralError, "Invalid Condition ("_$Piece(pResourceId,"-",2)_") Resource Index", $$$OutcomeNotFound)		
	}
	//----------------------------------------------
	//Transform a SDA Diagnosis to a FHIR Condition
	//----------------------------------------------
	set tBundle = ##class(HS.FHIR.DTL.Util.API.Transform.SDA3ToFHIR).TransformObject(tSDADiagnosis,"R4",pResourceId)
	if tBundle.bundle.entry.%size>0 {
		set pResourceObj=tBundle.bundle.entry.%Get(0).resource
	}
	else {
		$$$ThrowFHIR($$$GeneralError, "Resource not found", $$$OutcomeNotFound)
	}		
	return pResourceObj
}

ClassMethod ProcedureRead(pResourceId As %String) As %DynamicObject
{
	set tSDAProc = ..GetCachedSDAResource(pResourceId,"HS.SDA3.Procedure","Procedures.Procedure."_(+$Piece(pResourceId,"-",2)-1))
	If '$IsObject(tSDAProc) {
		$$$ThrowFHIR($$$GeneralError, "Invalid Procedure ("_$Piece(pResourceId,"-",2)_") Resource Index", $$$OutcomeNotFound)		
	}
	//----------------------------------------------
	//Transform a SDA Procedure to a FHIR Procedure
	//----------------------------------------------
	set tBundle = ##class(HS.FHIR.DTL.Util.API.Transform.SDA3ToFHIR).TransformObject(tSDAProc,"R4",pResourceId)
	if tBundle.bundle.entry.%size>0 {
		set pResourceObj=tBundle.bundle.entry.%Get(0).resource
	}
	else {
		$$$ThrowFHIR($$$GeneralError, "Resource not found", $$$OutcomeNotFound)
	}		
	return pResourceObj
}

ClassMethod FamilyMemberHistoryRead(pResourceId As %String) As %DynamicObject
{
	set tSDAFH = ..GetCachedSDAResource(pResourceId,"HS.SDA3.FamilyHistory","FamilyHistories.FamilyHistory."_(+$Piece(pResourceId,"-",2)-1))
	If '$IsObject(tSDAFH) {
		$$$ThrowFHIR($$$GeneralError, "Invalid Family History ("_$Piece(pResourceId,"-",2)_") Resource Index", $$$OutcomeNotFound)		
	}
	//----------------------------------------------
	//Transform a SDA Family History to a FHIR Family History
	//----------------------------------------------
	set tBundle = ##class(HS.FHIR.DTL.Util.API.Transform.SDA3ToFHIR).TransformObject(tSDAFH,"R4",pResourceId)
	if tBundle.bundle.entry.%size>0 {
		set pResourceObj=tBundle.bundle.entry.%Get(0).resource
	}
	else {
		$$$ThrowFHIR($$$GeneralError, "Resource not found", $$$OutcomeNotFound)
	}		
	return pResourceObj
}

ClassMethod ObservationRead(pResourceId As %String) As %DynamicObject
{
	set tSDAObservation = ..GetCachedSDAResource(pResourceId,"HS.SDA3.Observation","Observations.Observation."_(+$Piece(pResourceId,"-",2)-1))
	If '$IsObject(tSDAObservation) {
		$$$ThrowFHIR($$$GeneralError, "Invalid Observation ("_$Piece(pResourceId,"-",2)_") Resource Index", $$$OutcomeNotFound)		
	}
	//----------------------------------------------
	//Transform a SDA Observation to a FHIR Observation
	//----------------------------------------------
	set tBundle = ##class(HS.FHIR.DTL.Util.API.Transform.SDA3ToFHIR).TransformObject(tSDAObservation,"R4",pResourceId)
	if tBundle.bundle.entry.%size>0 {
		set pResourceObj=tBundle.bundle.entry.%Get(0).resource
	}
	else {
		$$$ThrowFHIR($$$GeneralError, "Resource not found", $$$OutcomeNotFound)
	}		
	return pResourceObj
}

ClassMethod ServiceRequestRead(pResourceId As %String) As %DynamicObject
{
	set tSDAOrder = ..GetCachedSDAResource(pResourceId,"HS.SDA3.OtherOrder","OtherOrders.OtherOrder."_(+$Piece(pResourceId,"-",2)-1))
	If '$IsObject(tSDAOrder) {
		$$$ThrowFHIR($$$GeneralError, "Invalid ServiceRequest ("_$Piece(pResourceId,"-",2)_") Resource Index", $$$OutcomeNotFound)		
	}
	//----------------------------------------------
	//Transform a SDA OtherOrder to a FHIR ServiceRequest
	//----------------------------------------------
	set tBundle = ##class(HS.FHIR.DTL.Util.API.Transform.SDA3ToFHIR).TransformObject(tSDAOrder,"R4",pResourceId)
	if tBundle.bundle.entry.%size>0 {
		set pResourceObj=tBundle.bundle.entry.%Get(0).resource
	}
	else {
		$$$ThrowFHIR($$$GeneralError, "Resource not found", $$$OutcomeNotFound)
	}		
	return pResourceObj
}

ClassMethod PatientRead(pResourceId As %String) As %DynamicObject
{
	set pResourceObj={}
	set tSDAPatient = ..GetCachedSDAResource(pResourceId,"HS.SDA3.Patient","Patient")
	If '$IsObject(tSDAPatient) {
		$$$ThrowFHIR($$$GeneralError, "Invalid Patient ("_$Piece(pResourceId,"-",1)_") Data", $$$OutcomeNotFound)
	}
	set tBundle = ##class(HS.FHIR.DTL.Util.API.Transform.SDA3ToFHIR).TransformObject(tSDAPatient,"R4",pResourceId)
	if tBundle.bundle.entry.%size>0 {
		set pResourceObj=tBundle.bundle.entry.%Get(0).resource
	}
	else {
		$$$ThrowFHIR($$$GeneralError, "Patient not found", $$$OutcomeNotFound)
	}		
	return pResourceObj
}

ClassMethod PatientSearch(pParameters As HS.FHIRServer.API.Data.QueryParameters = "") As HS.FHIRServer.Util.SearchResult
{
	set tResultSet=##class(HS.FHIRServer.Util.SearchResult).Create()
	
	//-------------------------
	// Create request+response
	//-------------------------
	set tRequest	=##class(FHIRFacadeMC.REQ.PatientSearch).%New()
	set tResponse 	=##class(FHIRFacadeMC.RES.PatientSearch).%New()

	//------------------------------------------------------------
	// Fill the request according to the allowed query parameters
	//------------------------------------------------------------
	for i=1:1:pParameters.Count() {
		set pName	=$zconvert(pParameters.GetAt(i).name,"L")
		set pValue	=pParameters.GetAt(i).value
			
		//-----------------------------------------------------------------
		// /Patient?identifier=http://hl7.org/fhir/sid/us-ssn|121-62-67521
		//-----------------------------------------------------------------
		if pName="identifier" {
			set system	=$piece(pValue,"|",1)
			set id		=$piece(pValue,"|",2)

			// empty id
			if id="" {
				$$$FHIRAddError(tResultSet.SearchStatus, $$$ERROR($$$HSFHIRErrInvalidQueryParameterValue, pName, id))
				quit
			}
			// searching by another system than 'us-ssn'
			if system'="http://hl7.org/fhir/sid/us-ssn" {
				$$$FHIRAddError(tResultSet.SearchStatus, $$$ERROR($$$HSFHIRErrInvalidQueryParameterValue, pName,system))
				quit
			}
			set tRequest.SSN=id
		}
		//------------------------
		// /Patient?gender=female
		//------------------------
		elseif pName="gender" {
			// empty gender
			if pValue="" {
				$$$FHIRAddError(tResultSet.SearchStatus, $$$ERROR($$$HSFHIRErrInvalidQueryParameterValue, pName, pValue))
				quit
			}
			set tRequest.Gender=pValue
		}
		//-------------------------
		// /Patient?family=skubach
		//-------------------------
		elseif pName="family" {
			// empty last name
			if pValue="" {
				$$$FHIRAddError(tResultSet.SearchStatus, $$$ERROR($$$HSFHIRErrInvalidQueryParameterValue, pName, pValue))
				quit
			}
			set tRequest.LastName=pValue
		}
		else {
			// only the identifier/gender/family query parametrs are allowed in this FHIR Facade
			$$$FHIRAddError(tResultSet.SearchStatus, $$$ERROR($$$HSFHIRErrParameterNotSupported, pName,""))
			quit
		}
	}			

	if $$$ISERR(tResultSet.SearchStatus) $$$ThrowFHIR($$$GeneralError, $system.Status.GetErrorText(tResultSet.SearchStatus), $$$OutcomeInvalid(500))
	//--------------------
	// Instantiate the BS
	//--------------------
	set tStatus=##class(Ens.Director).CreateBusinessService("Patient BS",.tService)
	if $$$ISERR(tStatus) $$$ThrowFHIR($$$GeneralError, $system.Status.GetErrorText(tStatus), $$$OutcomeInvalid(500))
	
	set tStatus=tService.ProcessInput(tRequest,.tResponse)
	if $$$ISOK(tStatus) {
		
		if tResponse.Success {
			for i=1:1:tResponse.Patients.Count() {
				
				//----------------------------------------
				//Transform patient data to a SDA Patient
				//----------------------------------------
				set tSDAPatient = ##class(HS.SDA3.Patient).%New()
				Set tStatus = ##Class(FHIRFacadeMC.DTL.SDA3.Patient).Transform(tResponse.Patients.GetAt(i),.tSDAPatient)
				if $$$ISERR(tStatus) $$$ThrowFHIR($$$GeneralError, $system.Status.GetErrorText(tStatus), $$$OutcomeInvalid(500))
				
				//----------------------------------------------
				//Transform a SDA Patient SDA to a FHIR Patient
				//----------------------------------------------
				set tBundle = ##class(HS.FHIR.DTL.Util.API.Transform.SDA3ToFHIR).TransformObject(tSDAPatient,"R4")
				if tBundle.bundle.entry.%size>0 {
					set tResourceObj=tBundle.bundle.entry.%Get(0).resource
				}
				else {
					$$$ThrowFHIR($$$GeneralError, "SDA Error", $$$OutcomeInvalid(500))
				}		
								
				//----------------------------------------
				// add the found patient to the resultset
				//----------------------------------------
				set resourceId		= tResponse.Patients.GetAt(i).InternalId
				set patientId		= tResponse.Patients.GetAt(i).InternalId
				set tResourceObj.id	= resourceId
				set Row = tResultSet.AddRow(i,"Patient",resourceId,1, "match",,tResourceObj,,patientId)
				kill tFHIRPatient,tSDAPatient
			}
		}
		else {
			$$$ThrowFHIR($$$GeneralError, tResponse.ErrorMessage, $$$OutcomeInvalid(500))
		}
	}		
	else {
		$$$ThrowFHIR($$$GeneralError, $system.Status.GetErrorText(tStatus), $$$OutcomeInvalid(500))
	}
	
	return tResultSet
}

ClassMethod PatientHistory(pResourceId As %String) As HS.FHIRServer.Util.SearchResult
{
	set tResultSet=##class(HS.FHIRServer.Util.SearchResult).Create()
	set pResourceObj={}
	Set tCachedObj = {}.%FromJSON(..GetCachedObj(pResourceId).JSONStream)
	Set tCt = 1
	set Row = tResultSet.AddRow(tCt,"Patient",pResourceId,1, "match","Get")
	Set tCt = tCt+1
	For i = 1:1:..g(tCachedObj,"Observations.Observation").%Size() {
		set Row = tResultSet.AddRow(tCt,"Observation",pResourceId_"-"_i,1, "match","Get")
		Set tCt = tCt+1
	}
	For i = 1:1:..g(tCachedObj,"OtherOrders.OtherOrder").%Size() {
		set Row = tResultSet.AddRow(tCt,"ServiceRequest",pResourceId_"-"_i,1, "match","Get")
		Set tCt = tCt+1
	}
	For i = 1:1:..g(tCachedObj,"Diagnoses.Diagnosis").%Size() {
		set Row = tResultSet.AddRow(tCt,"Condition",pResourceId_"-"_i,1, "match","Get")
		Set tCt = tCt+1
	}
	For i = 1:1:..g(tCachedObj,"Procedures.Procedure").%Size() {
		set Row = tResultSet.AddRow(tCt,"Procedure",pResourceId_"-"_i,1, "match","Get")
		Set tCt = tCt+1
	}
	For i = 1:1:..g(tCachedObj,"FamilyHistories.FamilyHistory").%Size() {
		set Row = tResultSet.AddRow(tCt,"FamilyMemberHistory",pResourceId_"-"_i,1, "match","Get")
		Set tCt = tCt+1
	}
	Do tResultSet.%SetIterator(0)
	return tResultSet
}

}
