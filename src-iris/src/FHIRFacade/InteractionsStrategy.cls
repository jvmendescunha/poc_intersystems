Class FHIRFacade.InteractionsStrategy Extends HS.FHIRServer.Storage.Json.InteractionsStrategy
{

Parameter StrategyKey = "MyFacade";

Parameter InteractionsClass = "FHIRFacade.Interactions";

Method GetMetadataResource() As %DynamicObject
{
	set MyCapabilityStatement = ##super()
	set iter = MyCapabilityStatement.rest."0".resource.%GetIterator()
	while iter.%GetNext(.key, .resourceItem) {
		if resourceItem.type="Patient" {
			set MyCapabilityStatement.rest."0".resource.%Get(key).interaction=[
																				{"code": "read"},
																				{"code": "create"},
																				{"code": "delete"},
																				{"code": "search-type"}
																			  ]
																			  
			set MyCapabilityStatement.rest."0".resource.%Get(key).searchParam=[
																				{"name": "family","type": "string"},
																				{"name": "gender","type": "token"},
																				{"name": "identifier","type": "token"}
																			  ]
                     
		}
	}
	
	return MyCapabilityStatement
}

/// @API - 
/// NOTE: This method is defined in the HS.FHIRServer.Storage.Json.InteractionsStrategy class.  Subclasses may
/// override.
Method GetCapabilityTemplate() As %DynamicObject
{
	Set json = {
		  "resourceType": "CapabilityStatement",
		  "id": "InterSystemsFHIRServer",
		  "meta": {
		    "versionId": "1",
	    	"lastUpdated": ($zdatetime($horolog,3,7))  //replaced at runtime, but must match 'instant' syntax
		  },
		  "url": "<replaced-at-runtime>",
		  "version": "1",
		  "name": "InterSystems FHIR Server CapabilityStatement",
		  "status": "active",
		  "experimental": false,
		  "date": ($zdate($horolog, 3)),
		  "publisher": "InterSystems Corporation 1",
		  "kind": "instance",
		  "software": {
		    "name": ("InterSystems " _ $select(##class(%ZHSLIB.HealthShareMgr).InstanceType()=$$$HSisHealthShare:"HealthShare Unified Care Record",
		    								##class(%ZHSLIB.HealthShareMgr).InstanceType()=$$$HSisIRISforHealth:"IRIS for Health",
		    								##class(%ZHSLIB.HealthShareMgr).InstanceType()=$$$HSisHealthConnect:"Health Connect",
		    								1:"")),
		    "version": (##class(%ZHSLIB.HealthShareMgr).VersionInfo())
		  },
		  "implementation": {
		    "description": "InterSystems FHIR Server 11",
		    "url": "<replaced-at-runtime>"
		  },
		  "fhirVersion": "<replaced-by-builder>",
		  "acceptUnknown": "no",
		  "format": [
		    "xml",
		    "json"
		  ],
		  "patchFormat": [
		  	"application/json-patch+json"
		  ],
		  "rest": [
		  ]
	}
	return json
}

}
