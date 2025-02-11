Class MarisaCare.Interop.Operations.FromMongoDB Extends (Ens.BusinessOperation, apiPub.core.jsonBuilder, custom.EHRInterop.Core.Util.SDA3)
{

Parameter ADAPTER = "custom.python.pymongo.outboundAdapter";

Property SendingFacility As %String [ Required ];

Property CodingStandard As %String [ Required ];

Parameter SETTINGS = "SendingFacility:Data,CodingStandard:Data";

Parameter INVOCATION = "Queue";

Method OnGetPatientSearchData(pRequest As MarisaCare.Interop.Model.PatientSearchRequest, pResponse As MarisaCare.Interop.Model.PatientSearchResponse) As %Status
{
    set tSc = $$$OK
    try{
        Set tFilter = {}
        If pRequest.Gender'="" Do ..s(tFilter,"userResponse.sexoBiologico",pRequest.Gender,,"^")
        If pRequest.SSN'="" Do ..s(tFilter,"userResponse.cpf",pRequest.SSN,,"^")
        If pRequest.LastName '="" {
            Set tFilter = {
                "$expr": {
                    "$eq": [
                        { "$arrayElemAt": [{ "$split": ["$userResponse.nome", " "] }, -1] },
                        (pRequest.LastName)
                    ]
                }  
            }
        }
        Set pResponse = ##class(MarisaCare.Interop.Model.PatientSearchResponse).%New()
        Set patientResultSet = ..Adapter.Query("test", "userresponses",tFilter)
        While ..i(patientResultSet,,.key,.value,.it) {
            Set tSDAStream = ##class(%Stream.GlobalCharacter).%New()
            Set tSDAPatient = ##class(HS.SDA3.Patient).%New()
            Set tUserResponse = ..g(value,"userResponse")
            Set tPatientCpf = ..g(tUserResponse,"cpf")
            Set tSDAPatient.Name = ..SplitName(..g(tUserResponse,"nome"),.tSC)
            $$$ThrowOnError(tSC)
            Set tSDAPatient.Gender = ..CodeTable("Gender", $ZSTRIP(..g(tUserResponse,"sexo"), "*C"), $ZSTRIP(..g(tUserResponse,"sexo"), "*C"))
            Set tSDAPatient.Race = ..CodeTable("Race", $ZSTRIP(..g(tUserResponse,"etnia"), "*C"), $ZSTRIP(..g(tUserResponse,"etnia"), "*C"))
            Set tSDAPatient.BirthTime = $ZDT($ZDATEH(..g(tUserResponse,"dataNascimento"),4),3)_"T00:00:00"
            Do tSDAPatient.PatientNumbers.Insert(..PatientNumber(value.%Get("_id"),"MRN","","")) 
            Do tSDAPatient.PatientNumbers.Insert(..PatientNumber(..g(tUserResponse,"cpf"),"CPF","","")) 
            Do tSDAPatient.PatientNumbers.Insert(..PatientNumber(..g(tUserResponse,"cpf"),"SSN","","")) 
            if ..g(tUserResponse,"phone")'="" Set tSDAPatient.ContactInfo = ..ContactInfo(..g(tUserResponse,"phone"),,,,.tSC)
            $$$ThrowOnError(tSC)
            Set tSC = tSDAPatient.ToQuickXMLStream(tSDAStream)
            Do pResponse.SDAStreamList.Insert(tSDAStream)
        }
    }
    catch tEx {
        set tSc = tEx.AsStatus()
    }
    return tSc
}

Method OnGetPatientData(pRequest As MarisaCare.Interop.Model.PatientRequest, pResponse As MarisaCare.Interop.Model.PatientResponse) As %Status
{
    set tSc = $$$OK
    try{
        set tPatientId = pRequest.PatientId
        set tPatientCpf = pRequest.PatientCpf

        // Adicionando formatação ao CPF
        set tPatientCpf = $extract(pRequest.PatientCpf,1,3) _ "." _ $extract(pRequest.PatientCpf,4,6) _ "." _ $extract(pRequest.PatientCpf,7,9) _ "-" _ $extract(pRequest.PatientCpf,10,11)
        $$$TRACE(tPatientCpf)

        set pResponse = ##class(MarisaCare.Interop.Model.PatientResponse).%New()

        If tPatientCpf'="" {
            Set tFilter = {"userResponse.cpf": (tPatientCpf)}
        } Else {
            Set tFilter = {"_id": (tPatientId)}
        }
        //get Patient data
        set patientResultSet = ..Adapter.Query("test", "userresponses",tFilter)
        If patientResultSet.%Size() = 0 Throw ##Class(%Exception.StatusException).CreateFromStatus($$$ERROR($$$GeneralError, "Patient Not Found"))

        Set tSDAContainer = ##class(HS.SDA3.Container).%New()
        Set tAction = "AddOrUpdate"
        Set tCodingStandard = ..CodingStandard
        Set tSDAContainer.SendingFacility = ..SendingFacility
        While ..i(patientResultSet,,.key,.value,.it) {
            Set tSDAPatient = ##class(HS.SDA3.Patient).%New()
            Set tUserResponse = ..g(value,"userResponse")
            Set tPatientCpf = ..g(tUserResponse,"cpf")
            Set tSDAPatient.Name = ..SplitName(..g(tUserResponse,"nome"),.tSC)
            $$$ThrowOnError(tSC)
            Set tSDAPatient.Gender = ..CodeTable("Gender", $ZSTRIP(..g(tUserResponse,"sexoBiologico"), "*C"), $ZSTRIP(..g(tUserResponse,"sexoBiologico"), "*C"))
            Set tSDAPatient.Race = ..CodeTable("Race", $ZSTRIP(..g(tUserResponse,"etnia"), "*C"), $ZSTRIP(..g(tUserResponse,"etnia"), "*C"))
            Set tSDAPatient.BirthTime = $ZDT($ZDATEH(..g(tUserResponse,"dataNascimento"),4),3)_"T00:00:00"
            Do tSDAPatient.PatientNumbers.Insert(..PatientNumber(value.%Get("_id"),"MRN","","")) 
            Do tSDAPatient.PatientNumbers.Insert(..PatientNumber(..g(tUserResponse,"cpf"),"CPF","","")) 
            Do tSDAPatient.PatientNumbers.Insert(..PatientNumber(..g(tUserResponse,"cpf"),"SSN","","")) 
            if ..g(tUserResponse,"phone")'="" Set tSDAPatient.ContactInfo = ..ContactInfo(..g(tUserResponse,"phone"),,,,.tSC)
            $$$ThrowOnError(tSC)
            set tSDAContainer.Patient = tSDAPatient
            If ..g(tUserResponse,"peso")'="" {
                Set tSDAObservation = ##class(HS.SDA3.Observation).%New()
                Set tSDAObservation.ObservationCode = ..CodeTable("Observation","29463-7","Body Weight",..CodingStandard)
                Set tSDAObservation.ObservationCode.ObservationValueUnits = ..CodeTable("UoM","kg","kg",..CodingStandard)
                Set tSDAObservation.ObservationValue = ..g(tUserResponse,"peso")
                Do tSDAContainer.Observations.Insert(tSDAObservation)
            }
            If ..g(tUserResponse,"altura")'="" {
                Set tSDAObservation = ##class(HS.SDA3.Observation).%New()
                Set tSDAObservation.ObservationCode = ..CodeTable("Observation","8302-2","Body Height",..CodingStandard)
                Set tSDAObservation.ObservationCode.ObservationValueUnits = ..CodeTable("UoM","cm","cm",..CodingStandard)
                Set tSDAObservation.ObservationValue = ..g(tUserResponse,"altura")
                Do tSDAContainer.Observations.Insert(tSDAObservation)
            }
            If ..g(tUserResponse,"gravida")'="" {
                Set tSDAObservation = ##class(HS.SDA3.Observation).%New()
                Set tSDAObservation.ObservationCode = ..CodeTable("Observation","82810-3","Pregnancy status",..CodingStandard)
                Set tSDAObservation.ObservationValueType = "ST"
                Set tSDAObservation.ObservationValue = ..g(tUserResponse,"gravida")
                Do tSDAContainer.Observations.Insert(tSDAObservation)
            }
            //get Surgeries data
            set surgeriesArray = ..g(tUserResponse,"cirurgia")
            While ..i(surgeriesArray,,.trackKey, .trackValue, .tSurgeriesCursor)   {
                Set trackValue=$ZSTRIP(trackValue,"*C")
                Set tSDAProcedure = ##class(HS.SDA3.Procedure).%New()
                Set tSDAProcedure.Procedure.Description = trackValue
                Set tSDAProcedure.Procedure.Code = trackValue
                Set tSDAProcedure.Procedure.SDACodingStandard = ..CodingStandard_"_"_"Surgery"
	            Do tSDAContainer.Procedures.Insert(tSDAProcedure)
            }
            //get Conditions data
            set conditionsArray = ..g(tUserResponse,"possuiDoencas")
            While ..i(conditionsArray,,.trackKey, .trackValue, .tConditionsCursor)   {
                Set trackValue=$ZSTRIP(trackValue,"*C")
                Set tSDACondition = ##class(HS.SDA3.Diagnosis).%New()
	            Set tSDACondition.Diagnosis = ..CodeTable("Diagnosis",trackValue,trackValue,..CodingStandard)
                Do tSDAContainer.Diagnoses.Insert(tSDACondition)
            }
            //get PreviousExams data
            set previousExamsArray = ..g(tUserResponse,"realizouExames")
            While ..i(previousExamsArray,,.trackKey, .trackValue, .tPreviousExamsCursor)   {
                Set trackValue=$ZSTRIP(trackValue,"*C")
                Set tSDAProcedure = ##class(HS.SDA3.Procedure).%New()
                Set tSDAProcedure.Procedure.Description = trackValue
                Set tSDAProcedure.Procedure.Code = trackValue
                Set tSDAProcedure.Procedure.SDACodingStandard = ..CodingStandard_"_"_"PreviousExam"
	            Do tSDAContainer.Procedures.Insert(tSDAProcedure)
            }
            //get FamilyRecord data
            set familyHistoryArray = ..g(tUserResponse,"historiaFamiliar")
            While ..i(familyHistoryArray,,.trackKey, .trackValue, .tFamilyHistoryCursor)   {
                Set tSDAFamilyHistory = ##class(HS.SDA3.FamilyHistory).%New()
                Set tSDAFM = ##class(HS.SDA3.CodeTableDetail.FamilyMember).%New()
                Set tSDAFM.Code = "ND"       
	            Set tSDAFamilyHistory.FamilyMember = tSDAFM
	            Set tSDAFamilyHistory.NoteText = trackValue
	            Do tSDAContainer.FamilyHistories.Insert(tSDAFamilyHistory)
            }
        }
        Set tFilter = {"patientCpf": (tPatientCpf)}
        //get Orders data
        set ordersResultSet = ..Adapter.Query("test", "prescriptions", tFilter)
        While ..i(ordersResultSet,,.key,.value,.tCursor) {
            set trackingsArray = value.%Get("medicalRules")
            While ..i(trackingsArray,,.trackKey,.trackValue,.tTrackingsCursor) {
                set prescriptionsArray = ..g(trackValue,"intervencao")
                While ..i(prescriptionsArray,,.prescriptionKey,.prescriptionValue,.tPrescriptionsCursor) {
                    Set tSDAOrder = ##class(HS.SDA3.OtherOrder).%New()
                    Set tSDAOrder.FromTime = ..g(trackValue,"dateOfPrescription")
                    Set tSDAOrder.ToTime = ..g(trackValue,"dateOfPrescription")
                    Set tSDAOrder.Condition = ..g(trackValue,"regraMedica")
                    Set tSDAOrder.OrderItem = ..CodeTable("Order",..g(prescriptionValue,"name"),..g(prescriptionValue,"name"),..CodingStandard)
                    Set tSDAOrder.Priority = ..CodeTable("Priority","intent","intent",..CodingStandard)
                    Set tSDAOrder.Status = "active"
                    Do tSDAContainer.OtherOrders.Insert(tSDAOrder)
                }
            }
        }
        Set tSDAStream = ##class(%Stream.GlobalCharacter).%New()
        Set tSC = tSDAContainer.ToQuickXMLStream(tSDAStream)
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        //Set tSC = ##class(apiPub.core.irisMetadata).ClassNameToXSDInfo("HS.SDA3.Container",.tXSDInfo,{"printResults":0})
        //If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        //Set tSC = ##class(apiPub.core.converter).XMLToJSON(tSDAStream,tXSDInfo,.pObj,{"printResults":0})
        //If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        //Do pObj.%Get("Container").%ToJSON(pResponse.JSONStream)
        Do pResponse.SDAStream.CopyFrom(tSDAStream)
	    Set tCache = ##class(FHIRFacadeMC.Table.CacheSDA).SDAIndexOpen(..SendingFacility,$Select(pRequest.PatientId'="":pRequest.PatientId,1:pRequest.PatientCpf),.tStatus)
        If '$IsObject(tCache) Set tCache = ##class(FHIRFacadeMC.Table.CacheSDA).%New()
        Set tCache.Id = $Select(pRequest.PatientId'="":pRequest.PatientId,1:pRequest.PatientCpf)
        Set tCache.Facility = ..SendingFacility
        Set tCache.SDAStream = tSDAStream
        Set tCache.TS = $Replace($H,",","")
        //Do pObj.%Get("Container").%ToJSON(tCache.JSONStream)
        Set tSC = tCache.%Save()
        $$$ThrowOnError(tSC)
    }
    catch tEx {
        set tSc = tEx.AsStatus()
    }
    
    return tSc
}

XData MessageMap
{
<MapItems>
  <MapItem MessageType="MarisaCare.Interop.Model.PatientRequest">
    <Method>OnGetPatientData</Method>
  </MapItem>
  <MapItem MessageType="MarisaCare.Interop.Model.PatientSearchRequest">
    <Method>OnGetPatientSearchData</Method>
  </MapItem>
</MapItems>
}

}
