Class FHIRFacade.RES.PatientSearch Extends Ens.Response
{

Property Success As %Boolean [ InitialExpression = 1 ];

Property ErrorMessage As %String(MAXLEN = 500);

Property Patients As list Of FHIRFacade.RES.PatientData;

Storage Default
{
<Data name="PatientSearchDefaultData">
<Subscript>"PatientSearch"</Subscript>
<Value name="1">
<Value>Success</Value>
</Value>
<Value name="2">
<Value>ErrorMessage</Value>
</Value>
<Value name="3">
<Value>Patients</Value>
</Value>
</Data>
<DefaultData>PatientSearchDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
