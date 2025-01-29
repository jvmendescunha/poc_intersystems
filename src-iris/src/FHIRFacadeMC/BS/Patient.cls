Class FHIRFacadeMC.BS.Patient Extends Ens.BusinessService
{

Property TargetConfigName As Ens.DataType.ConfigName [ InitialExpression = "FHIRFacadeMC.BO.SQL" ];

Parameter SETTINGS = "TargetConfigName";

Method GetPatientDataFromMongo(patientId As %String, Output pResponse As MarisaCare.Interop.Model.PatientResponse) As %Status
{
    Set tSC = $$$OK
	Set tRequest = ##class(MarisaCare.Interop.Model.PatientRequest).%New()
	If $L(patientId)>=24 {
		Set tRequest.PatientId = patientId
	} Else {
		Set tRequest.PatientCpf = patientId
	}
    Set tResponse = ##class(MarisaCare.Interop.Model.PatientResponse).%New()
    Set tSC = ..SendRequestSync("FromMongoDB",tRequest,.pResponse)
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
	Quit tSC
}

Method GetSearchPatientDataFromMongo(pRequest As MarisaCare.Interop.Model.PatientSearchRequest, Output pResponse As MarisaCare.Interop.Model.PatientSearchResponse) As %Status
{
    Set tSC = $$$OK
    Set tResponse = ##class(MarisaCare.Interop.Model.PatientResponse).%New()
    Set tSC = ..SendRequestSync("FromMongoDB",pRequest,.pResponse)
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
	Quit tSC
}

}
