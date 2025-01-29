Class FHIRFacade.BS.Patient Extends Ens.BusinessService
{

Property TargetConfigName As Ens.DataType.ConfigName [ InitialExpression = "FHIRFacade.BO.SQL" ];

Parameter SETTINGS = "TargetConfigName";

Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject) As %Status
{
	#dim tStatus As %Status = $$$OK
	#dim Err As %Exception.AbstractException
		
	Try {
		Set tStatus = ..SendRequestSync("Patient Database",pInput,.pOutput)
		$$$ThrowOnError(tStatus)
	}
	catch Err{
		set tStatus = Err.AsStatus()	
	}
	return tStatus
}

}
