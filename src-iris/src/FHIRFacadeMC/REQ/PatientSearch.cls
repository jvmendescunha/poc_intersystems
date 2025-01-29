Class FHIRFacadeMC.REQ.PatientSearch Extends Ens.Response
{

Property LastName As %String;

Property SSN As %String;

Property Gender As %String;

Storage Default
{
<Data name="PatientSearchDefaultData">
<Subscript>"PatientSearch"</Subscript>
<Value name="1">
<Value>LastName</Value>
</Value>
<Value name="2">
<Value>SSN</Value>
</Value>
<Value name="3">
<Value>Gender</Value>
</Value>
</Data>
<DefaultData>PatientSearchDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
