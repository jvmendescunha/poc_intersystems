Class FHIRFacadeMC.BO.Database Extends Ens.BusinessOperation
{

Parameter ADAPTER = "Ens.OutboundAdapter";

Property Adapter As Ens.OutboundAdapter;

Parameter INVOCATION = "Queue";

Method Patient(pRequest As FHIRFacadeMC.REQ.Patient, Output pResponse As FHIRFacadeMC.RES.Patient) As %Status
{
	#dim Err as %Exception.AbstractException
	try {
		set pResponse=##class(FHIRFacadeMC.RES.Patient).%New()
    	
    	//----------------------
    	// Create a new patient
    	//----------------------
		if pRequest.Action="Add" {
			set SSN=pRequest.SSN
			&sql(select ID into :ID from FHIRFacadeMC_Table.Patient where SSN=:SSN)
			if SQLCODE=100 {
				// New Patient
		        set obj=##class(FHIRFacadeMC.Table.Patient).%New()
		        set obj.SSN 		= pRequest.SSN
		        set obj.FirstName 	= pRequest.FirstName
		        set obj.LastName 	= pRequest.LastName
		        set obj.Gender 		= pRequest.Gender
		        set obj.Deceased 	= pRequest.Deceased
		        set tSC = obj.%Save()
				if tSC {
			        set pResponse.Success=1
			        set pResponse.PatientData.InternalId=obj.%Id()
		        }
		        else {
			        set pResponse.Success=0
			        set pResponse.ErrorMessage=$system.Status.GetErrorText(tSC)
		        }
	   		}
	   		else {
		        set pResponse.Success=0
		        set pResponse.ErrorMessage="Patient with SSN '"_pRequest.SSN_"' already exists"
	   		}
		}
    	//----------------------------
		// Delete an existing patient
    	//----------------------------
		elseif pRequest.Action="Delete" {
	    	if ##class(FHIRFacadeMC.Table.Patient).%ExistsId(pRequest.InternalId) {
				// Patient Found
		        set tStatus=##class(FHIRFacadeMC.Table.Patient).%DeleteId(pRequest.InternalId)
		        if $$$ISOK(tStatus) {
			        set pResponse.Success=1
		        }
		        else {
			        set pResponse.Success=0
			        set pResponse.ErrorMessage=$system.Status.GetErrorText(tStatus)
		        }
	    	}
	   		else {
		        set pResponse.Success=0
		        set pResponse.ErrorMessage="Patient with id '"_pRequest.InternalId_"' does not exist"
	   		}
		}
    	//------------------------------------
		// Get details of an existing patient
    	//------------------------------------
		elseif pRequest.Action="Read" {
	    	if ##class(FHIRFacadeMC.Table.Patient).%ExistsId(pRequest.InternalId) {
				// Found Patient
		        set obj=##class(FHIRFacadeMC.Table.Patient).%OpenId(pRequest.InternalId)
		        set pResponse.PatientData.InternalId 	= obj.%Id()
		        set pResponse.PatientData.SSN 			= obj.SSN
		        set pResponse.PatientData.FirstName 	= obj.FirstName
		        set pResponse.PatientData.LastName 		= obj.LastName
		        set pResponse.PatientData.Gender 		= obj.Gender
		        set pResponse.PatientData.Deceased 		= obj.Deceased
	    	}
	   		else {
		        set pResponse.Success=0
		        set pResponse.ErrorMessage="Patient with id '"_pRequest.InternalId_"' was not found"
	   		}
		}
		else {
	        set pResponse.Success=0
	        set pResponse.ErrorMessage="Invalid action '"_pRequest.Action_"'"
		}

	}
	catch Err {
		set tStatus=Err.AsStatus()
		set pResponse.Success=0
		set pResponse.ErrorMessage=$system.Status.GetErrorText(tStatus)
	}
	Quit $$$OK
}

Method PatientSearch(pRequest As FHIRFacadeMC.REQ.PatientSearch, Output pResponse As FHIRFacadeMC.RES.PatientSearch) As %Status
{
	#dim Err as %Exception.AbstractException
	try {
		set pResponse=##class(FHIRFacadeMC.RES.PatientSearch).%New()
    	
    	//------------------------
		// Built the WHERE clause
    	//------------------------
		set tWhere=""
		if pRequest.SSN'="" {
			set tWhere="SSN='"_pRequest.SSN_"' "
		}
		if pRequest.Gender'="" {
			if tWhere'="" set tWhere=tWhere_" AND Gender='"_pRequest.Gender_"' "
			else  set tWhere="Gender='"_pRequest.Gender_"' "
		}
		if pRequest.LastName'="" {
			if tWhere'="" set tWhere=tWhere_" AND LastName like '"_pRequest.LastName_"%' "
			else  set tWhere="LastName like '"_pRequest.LastName_"%' "
		}
		
		if tWhere="" {
			set pResponse.Success=0
			set pResponse.ErrorMessage="No search parameters"
			quit
		}
		
		$$$TRACE(tWhere)

    	//---------------------------
		// Execute the SQL statement
    	//---------------------------
		set tResultset=##class(%ResultSet).%New("%DynamicQuery:SQL")
		set SQL = "SELECT ID,FirstName,LastName,SSN,Gender,Deceased FROM FHIRFacadeMC_Table.Patient WHERE "_tWhere
  		set tStatus = tResultset.Prepare(SQL)
		if $$$ISERR(tStatus)="" {
			set pResponse.Success=0
			set pResponse.ErrorMessage=$system.Status.GetErrorText(tStatus)
			quit
		}
		set tStatus=tResultset.Execute()
		if $$$ISERR(tStatus)="" {
			set pResponse.Success=0
			set pResponse.ErrorMessage=$system.Status.GetErrorText(tStatus)
			quit
		}
		
    	//---------------------------------------
		// Fill the results list in the resposne
    	//---------------------------------------
		while tResultset.Next() {
			set tPatient=##class(FHIRFacadeMC.RES.PatientData).%New()
			set tPatient.InternalId	=tResultset.Get("ID")
			set tPatient.FirstName	=tResultset.Get("FirstName")
			set tPatient.LastName	=tResultset.Get("LastName")
			set tPatient.Gender		=tResultset.Get("Gender")
			set tPatient.SSN		=tResultset.Get("SSN")
			set tPatient.Deceased	=tResultset.Get("Deceased")
			do pResponse.Patients.Insert(tPatient)
			kill tPatient
		}
	}
	catch Err {
		set tStatus=Err.AsStatus()
		set pResponse.Success=0
		set pResponse.ErrorMessage=$system.Status.GetErrorText(tStatus)
	}
	Quit $$$OK
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="FHIRFacadeMC.REQ.Patient"> 
		<Method>Patient</Method>
	</MapItem>
	<MapItem MessageType="FHIRFacadeMC.REQ.PatientSearch"> 
		<Method>PatientSearch</Method>
	</MapItem>
</MapItems>
}

}
