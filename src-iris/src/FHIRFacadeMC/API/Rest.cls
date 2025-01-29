Class FHIRFacadeMC.API.Rest Extends (Ens.BusinessService, apiPub.core.jsonBuilder)
{

/// patientId 678e8453fd4cd71a74f06b15 
/// patientCpf 13665837952
Method GetPatientData(patientId As %String, patientCpf As %String) As %DynamicObject [ WebMethod ]
{
    Set tRequest = ##class(MarisaCare.Interop.Model.PatientRequest).%New()
    Set tRequest.PatientId = patientId
    Set tRequest.PatientCpf = patientCpf
    Set tResponse = ##class(MarisaCare.Interop.Model.PatientResponse).%New()
    Set tSC = ..SendRequestSync("FromMongoDB",tRequest,.tResponse)
    If 'tSC Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)
    If $IsObject(tResponse.SDAStream) {
        Set tSC = ##class(apiPub.core.irisMetadata).ClassNameToXSDInfo("HS.SDA3.Container",.tXSDInfo,{"printResults":0})
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}

        Set tSC = ##class(apiPub.core.converter).XMLToJSON(tResponse.SDAStream,tXSDInfo,.pObj,{"printResults":0})
        If 'tSC { Throw ##Class(%Exception.StatusException).CreateFromStatus(tSC)}
        Quit pObj.%Get("Container")
    } Else {
        Quit {"Message":"Patient not found"}
    }
}

Method BadTagTest() As %Status [ WebMethod ]
{
    Set tContainer = ##class(HS.SDA3.Container).%New()
    Set tContainer = ##class(FHIRFacadeMC.MyResource.Patient).GetCachedData("13665837952")
	set tBundle = ##class(HS.FHIR.DTL.Util.API.Transform.SDA3ToFHIR).TransformObject(tContainer,"R4","13665837952")
	if tBundle.bundle.entry.%size>0 {
		set pResourceObj=tBundle.bundle.entry.%Get(0).resource
	}		
    Quit $$$OK
}

ClassMethod FeedMongoDB() As %Status [ WebMethod ]
{
    Set sc = $$$OK
    Set mongoUri = "mongodb+srv://<db_user>:<db_password>@cluster0.y1uie.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0&tlsAllowInvalidCertificates=true"
    Set irisCredentials = "mongodb" //the connection must have been created or the user and pwd will be explicit in you connection string

    Set tPatient = ..GetPatients()
    Set tTrackings = ..GetTrackings()

    Set deleteResponse = ##class(custom.python.pymongo.crud).Delete(mongoUri, irisCredentials, "test", "userresponses", {"userResponse.cpf": "13665837952"})
    Write deleteResponse.%ToJSON(),!
    Set deleteResponse = ##class(custom.python.pymongo.crud).Delete(mongoUri, irisCredentials, "test", "trackings", {"patientCpf": "13665837952"})
    Write deleteResponse.%ToJSON(),!
    Set tIds = ""
    Set queryResponse = ##class(custom.python.pymongo.crud).Query(mongoUri, irisCredentials, "test", "userresponses", {"userResponse.cpf": "13665837952"})
    If queryResponse.%Size()=0 {
        Set insertResponse = ##class(custom.python.pymongo.crud).InsertOrUpdate(mongoUri, irisCredentials, "test", "userresponses", tPatient)
        Write insertResponse.%ToJSON(),!
 
        Set insertResponse = ##class(custom.python.pymongo.crud).InsertOrUpdate(mongoUri, irisCredentials, "test", "trackings", tTrackings)
        Write insertResponse.%ToJSON(),!
    } else {
        Set tIds = queryResponse.%Get(0).%Get("_id")
        Write "Patient Already Exists: _id: ",tIds,!
    }
    Quit sc
}

ClassMethod GetPatients() As %Library.DynamicObject
{
    Quit {
        "userResponse": {
            "cpf":"13665837952",
            "name":"Mayle Vitoria Monteiro Batista",
            "phone":"5541998381643",
            "dataNascimento":"30/7/2004",
            "sexoBiologico":"Feminino",
            "etnia":"Branca",
            "altura":158,
            "peso":65,
            "gravida":"Definitivamente não",
            "possuiDoencas":[
                "Depressão"
            ],
            "cirurgia":[
                "Nenhuma das alternativas"
            ],
            "realizouExames":[
                "Tomografia de crânio (cérebro, cabeça ou encéfalo)",
                "Eletrocardiograma"
            ],
            "historiaFamiliar": [
                "Cancer de Fígado"
            ]
        }        
    }
}

ClassMethod GetTrackings() As %Library.DynamicObject
{
    Quit {
        "patientCpf": "13665837952",
        "trackings": [
            {
                "disease":"Rastreio de hepatite B",
                "dateOfPrescription":"2024-07-04T15:25:03.803000",
                "prescriptions":[
                    {
                        "name":"Indicação de sorologia de hepatite B"
                    }
                ]
            },
            {
                "disease":"Rastreio de hepatite C",
                "dateOfPrescription":"2024-07-04T15:25:03.803000",
                "prescriptions":[
                    {
                        "name":"Indicação de sorologia de hepatite C"
                    }
                ]
            },
            {
                "disease":"Rastreio de HIV",
                "dateOfPrescription":"2024-07-04T15:25:03.803000",
                "prescriptions":[
                    {
                        "name":"Indicação de sorologia de HIV"
                    }
                ]
            },
            {
                "disease":"Rastreio de diabetes",
                "dateOfPrescription":"2024-07-04T15:25:03.803000",
                "prescriptions":[
                    {
                        "name":"Indicação de glicemia de jejum"
                    },
                    {
                        "name":"Indicação de hemoglobina glicada"
                    }
                ]
            },
            {
                "disease":"Rastreio de diabetes",
                "dateOfPrescription":"2024-07-04T15:25:03.803000",
                "prescriptions":[
                    {
                        "name":"Indicação de glicemia de jejum"
                    },
                    {
                        "name":"Indicação de hemoglobina glicada"
                    }
                ]
            },
            {
                "disease":"Rastreio de dislipidemia",
                "dateOfPrescription":"2024-07-04T15:25:03.803000",
                "prescriptions":[
                    {
                        "name":"Indicação de colesterol"
                    },
                    {
                        "name":"Indicação de triglicérides"
                    }
                ]
            },
            {
                "disease":"Rastreio de dislipidemia",
                "dateOfPrescription":"2024-07-04T15:25:03.803000",
                "prescriptions":[
                    {
                        "name":"Indicação de colesterol"
                    },
                    {
                        "name":"Indicação de triglicérides"
                    }
                ]
            },
            {
                "disease":"Rastreio de glaucoma",
                "dateOfPrescription":"2024-07-04T15:25:03.803000",
                "prescriptions":[
                    {
                        "name":"Encaminhamento para Oftalmologia"
                    }
                ]
            },
            {
                "disease":"Rastreio de alterações de ECG por comorbidades",
                "dateOfPrescription":"2024-07-04T15:25:03.803000",
                "prescriptions":[
                    {
                        "name":"Indicação de eletrocardiograma"
                    }
                ]
            },
            {
                "disease":"Acompanhamento nutricional",
                "dateOfPrescription":"2024-07-04T15:25:03.803000",
                "prescriptions":[
                    {
                        "name":"Encaminhamento para Nutrição"
                    }
                ]
            }
        ]
    }
}

}
