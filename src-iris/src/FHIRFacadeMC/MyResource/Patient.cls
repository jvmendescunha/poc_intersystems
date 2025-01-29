Include HS.FHIRServer

Class FHIRFacadeMC.MyResource.Patient Extends apiPub.core.jsonBuilder
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
	set tResponse			= ##class(MarisaCare.Interop.Model.PatientResponse).%New()
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

ClassMethod GetCachedData(pResourceId As %String) As HS.SDA3.SuperClass
{
	//--------------------
	// Get the Cached Data
	//--------------------
	Set tCachedObj = ..GetCachedObj(pResourceId)
	Set tContainer = ##class(HS.SDA3.Container).%New()
	If $IsObject(tCachedObj.SDAStream) {
		Set tSC = ##class(apiPub.core.converter).XMLToObj(tCachedObj.SDAStream,"HS.SDA3.Container",.tContainer)
		If 'tSC $$$ThrowFHIR($$$GeneralError, $system.Status.GetErrorText(tSC), $$$OutcomeNotFound)
	} Else {
		$$$ThrowFHIR($$$GeneralError, "Invalid SDA Data", $$$OutcomeNotFound)
	}
	/*
	If $IsObject(tCachedObj.JSONStream) {
		Set tSC = ##class(apiPub.core.converter).JSONToObj({}.%FromJSON(tCachedObj.JSONStream),"HS.SDA3.Container",.tContainer)
		If 'tSC $$$ThrowFHIR($$$GeneralError, $system.Status.GetErrorText(tSC), $$$OutcomeNotFound)
	} Else {
		$$$ThrowFHIR($$$GeneralError, "Invalid SDA Data", $$$OutcomeNotFound)
	}
	*/
	Quit tContainer
}

ClassMethod ConditionRead(pResourceId As %String) As %DynamicObject
{
	set tSDADiagnosis = ..GetCachedData(pResourceId).Diagnoses.GetAt($Piece(pResourceId,"-",2))
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
	set tSDAProc = ..GetCachedData(pResourceId).Procedures.GetAt($Piece(pResourceId,"-",2))
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
	set tSDAFH = ..GetCachedData(pResourceId).FamilyHistories.GetAt($Piece(pResourceId,"-",2))
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
	set tSDAObservation = ..GetCachedData(pResourceId).Observations.GetAt($Piece(pResourceId,"-",2))
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
	set tSDAOrder = ..GetCachedData(pResourceId).OtherOrders.GetAt($Piece(pResourceId,"-",2))
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
	set tSDAPatient = ..GetCachedData(pResourceId).Patient
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
	set tRequest	=##class(MarisaCare.Interop.Model.PatientSearchRequest).%New()
	set tResponse 	=##class(MarisaCare.Interop.Model.PatientSearchResponse).%New()

	//------------------------------------------------------------
	// Fill the request according to the allowed query parameters
	//------------------------------------------------------------
	for i=1:1:pParameters.Count() {
		set pName	=$zconvert(pParameters.GetAt(i).name,"L")
		set pValue	=pParameters.GetAt(i).value
			
		//-----------------------------------------------------------------
		// /Patient?identifier=http://hl7.org/fhir/sid/br-cpf|13665837952
		//-----------------------------------------------------------------
		if pName="identifier" {
			set system	=$piece(pValue,"|",1)
			set id		=$piece(pValue,"|",2)

			// empty id
			if id="" {
				$$$FHIRAddError(tResultSet.SearchStatus, $$$ERROR($$$HSFHIRErrInvalidQueryParameterValue, pName, id))
				quit
			}
			// searching by another system than 'us-ssn' or 'br-cpf'
			if (system'="http://hl7.org/fhir/sid/us-ssn")&&(system'="http://hl7.org/fhir/sid/br-cpf") {
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
		// /Patient?family=Batista
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
	
	set tStatus=tService.GetSearchPatientDataFromMongo(tRequest,.tResponse)
	if $$$ISOK(tStatus) {
		if tResponse.Success {
			for i=1:1:tResponse.SDAStreamList.Count() {
				#Dim tSDAPatient As HS.SDA3.Patient
				Set tSC = ##class(apiPub.core.converter).XMLToObj(tResponse.SDAStreamList.GetAt(i),"HS.SDA3.Patient",.tSDAPatient)
				If 'tSC $$$ThrowFHIR($$$GeneralError, $system.Status.GetErrorText(tSC), $$$OutcomeNotFound)

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
				set resourceId		= tSDAPatient.PatientNumbers.GetAt(1).Number
				set patientId		= tSDAPatient.PatientNumbers.GetAt(1).Number
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
	set tContainer = ..GetCachedData(pResourceId)
	Set tCt = 1
	set Row = tResultSet.AddRow(tCt,"Patient",pResourceId,1, "match","Get")
	Set tCt = tCt+1
	For i = 1:1:tContainer.Observations.Count() {
		set Row = tResultSet.AddRow(tCt,"Observation",pResourceId_"-"_i,1, "match","Get")
		Set tCt = tCt+1
	}
	For i = 1:1:tContainer.OtherOrders.Count() {
		set Row = tResultSet.AddRow(tCt,"ServiceRequest",pResourceId_"-"_i,1, "match","Get")
		Set tCt = tCt+1
	}
	For i = 1:1:tContainer.Diagnoses.Count() {
		set Row = tResultSet.AddRow(tCt,"Condition",pResourceId_"-"_i,1, "match","Get")
		Set tCt = tCt+1
	}
	For i = 1:1:tContainer.Procedures.Count() {
		set Row = tResultSet.AddRow(tCt,"Procedure",pResourceId_"-"_i,1, "match","Get")
		Set tCt = tCt+1
	}
	For i = 1:1:tContainer.FamilyHistories.Count() {
		set Row = tResultSet.AddRow(tCt,"FamilyMemberHistory",pResourceId_"-"_i,1, "match","Get")
		Set tCt = tCt+1
	}
	Do tResultSet.%SetIterator(0)
	return tResultSet
}

}
