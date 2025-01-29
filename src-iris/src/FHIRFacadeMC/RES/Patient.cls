Class FHIRFacadeMC.RES.Patient Extends Ens.Response
{

Property Success As %Boolean [ InitialExpression = 1 ];

Property ErrorMessage As %String(MAXLEN = 500);

Property PatientData As FHIRFacadeMC.RES.PatientData;

Storage Default
{
<Data name="PatientDefaultData">
<Subscript>"Patient"</Subscript>
<Value name="1">
<Value>Success</Value>
</Value>
<Value name="2">
<Value>ErrorMessage</Value>
</Value>
<Value name="3">
<Value>PatientData</Value>
</Value>
</Data>
<DefaultData>PatientDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
