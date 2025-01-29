Include HS.FHIRServer

Class FHIRFacade.MyResource.Patient Extends %RegisteredObject
{

ClassMethod PatientAdd(pResourceObj As %DynamicObject, pResourceIdToAssign As %String = "") As %DynamicObject
{
	#dim tService as Ens.BusinessService

	//--------------------
	// Instantiate the BS
	//--------------------
	set tStatus=##class(Ens.Director).CreateBusinessService("Patient BS",.tService)
	if $$$ISERR(tStatus) $$$ThrowFHIR($$$GeneralError, $system.Status.GetErrorText(tStatus), $$$OutcomeInvalid(500))
		
	//-------------------------
	// Create request+response
	//-------------------------
	set tResponse					= ##class(FHIRFacade.RES.Patient).%New()
	set tRequest					= ##class(FHIRFacade.REQ.Patient).%New()
	set tRequest.Action				= "Add"
	set tRequest.Gender				= pResourceObj.gender
	set tRequest.Deceased			= pResourceObj.deceasedBoolean
	if pResourceObj.identifier.%Size()>0 {
		set tRequest.SSN			= pResourceObj.identifier."0".value
	}
	if pResourceObj.name.%Size()>0 {
		set tRequest.LastName		= pResourceObj.name."0".family
		if pResourceObj.name."0".given.%Size()>0 {
			set tRequest.FirstName	= pResourceObj.name."0".given."0"
		}
	}
	
	//------------------
	// Send the request
	//------------------
	set tStatus=tService.ProcessInput(tRequest,.tResponse)
	if $$$ISOK(tStatus) {
		if tResponse.Success {
			//------------------------------------------------------------
			// Fill in the required meta properties for the FHIR response
			//------------------------------------------------------------
			set pResourceObj.id=tResponse.PatientData.InternalId
			set pResourceObj.meta={}
			set pResourceObj.meta.versionId=1
			set pResourceObj.meta.lastUpdated=$zdt($h,3,1,3)
		}
		else {
			$$$ThrowFHIR($$$GeneralError, tResponse.ErrorMessage, $$$OutcomeInvalid(500))
		}
	}
	else {
		$$$ThrowFHIR($$$GeneralError, $system.Status.GetErrorText(tStatus), $$$OutcomeInvalid(500))
	}
 return pResourceObj
}

ClassMethod PatientDelete(pResourceId As %String) As %String
{
	#dim tService as Ens.BusinessService
	set VersionId=""
		

	//--------------------
	// Instantiate the BS
	//--------------------
	set tStatus=##class(Ens.Director).CreateBusinessService("Patient BS",.tService)
	if $$$ISERR(tStatus) $$$ThrowFHIR($$$GeneralError, $system.Status.GetErrorText(tStatus), $$$OutcomeInvalid(500))
	
	//-------------------------
	// Create request+response
	//-------------------------
	set tResponse					= ##class(FHIRFacade.RES.Patient).%New()
	set tRequest					= ##class(FHIRFacade.REQ.Patient).%New()
	set tRequest.Action				= "Delete"
	set tRequest.InternalId			= pResourceId
	
	//------------------
	// Send the request
	//------------------
	set tStatus=tService.ProcessInput(tRequest,.tResponse)
	if $$$ISOK(tStatus) {
		if tResponse.Success {
			//------------------------------------------------------------
			// Fill in the required meta properties for the FHIR response
			//------------------------------------------------------------
			set VersionId=1
		}
		else {
			$$$ThrowFHIR($$$GeneralError, tResponse.ErrorMessage, $$$OutcomeNotFound)
		}
	}
	else {
		$$$ThrowFHIR($$$GeneralError, $system.Status.GetErrorText(tStatus), $$$OutcomeInvalid(500))
	}
 return VersionId
}

ClassMethod PatientRead(pResourceId As %String) As %DynamicObject
{
	#dim tService as Ens.BusinessService
	set pResourceObj={}
	
	//--------------------
	// Instantiate the BS
	//--------------------
	set tStatus=##class(Ens.Director).CreateBusinessService("Patient BS",.tService)
	if $$$ISERR(tStatus) $$$ThrowFHIR($$$GeneralError, $system.Status.GetErrorText(tStatus), $$$OutcomeInvalid(500))
		
	//-------------------------
	// Create request+response
	//-------------------------
	set tResponse			= ##class(FHIRFacade.RES.Patient).%New()
	set tRequest			= ##class(FHIRFacade.REQ.Patient).%New()
	set tRequest.Action		= "Read"
	set tRequest.InternalId	= pResourceId
	//------------------
	// Send the request
	//------------------
	set tStatus=tService.ProcessInput(tRequest,.tResponse)
	if $$$ISOK(tStatus) {
		if tResponse.Success {
			//------------------------------------------
			//Transform Query Response to a SDA Patient
			//------------------------------------------
			set tSDAPatient = ##class(HS.SDA3.Patient).%New()
			Set tStatus = ##Class(FHIRFacade.DTL.SDA3.Patient).Transform(tResponse.PatientData,.tSDAPatient)
			if $$$ISERR(tStatus) $$$ThrowFHIR($$$GeneralError, $system.Status.GetErrorText(tStatus), $$$OutcomeInvalid(500))
			
			//----------------------------------------------
			//Transform a SDA Patient SDA to a FHIR Patient
			//----------------------------------------------
			
			set tBundle = ##class(HS.FHIR.DTL.Util.API.Transform.SDA3ToFHIR).TransformObject(tSDAPatient,"R4",pResourceId)
			if tBundle.bundle.entry.%size>0 {
				set pResourceObj=tBundle.bundle.entry.%Get(0).resource
			}
			else {
				$$$ThrowFHIR($$$GeneralError, "Patient not found", $$$OutcomeNotFound)
			}		
		}
		else {
			$$$ThrowFHIR($$$GeneralError, tResponse.ErrorMessage, $$$OutcomeInvalid(500))
		}
	}
	else {
		$$$ThrowFHIR($$$GeneralError, $system.Status.GetErrorText(tStatus), $$$OutcomeInvalid(500))
	}
	return pResourceObj
}

ClassMethod PatientSearch(pParameters As HS.FHIRServer.API.Data.QueryParameters = "") As HS.FHIRServer.Util.SearchResult
{
	set tResultSet=##class(HS.FHIRServer.Util.SearchResult).Create()
	
	//-------------------------
	// Create request+response
	//-------------------------
	set tRequest	=##class(FHIRFacade.REQ.PatientSearch).%New()
	set tResponse 	=##class(FHIRFacade.RES.PatientSearch).%New()

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
				Set tStatus = ##Class(FHIRFacade.DTL.SDA3.Patient).Transform(tResponse.Patients.GetAt(i),.tSDAPatient)
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

}
