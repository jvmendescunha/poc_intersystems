Class FHIRFacade.REQ.Patient Extends Ens.Response
{

Property Action As %String(VALUELIST = ",Add,Delete,Update,Read");

Property InternalId As %Integer;

Property FirstName As %String;

Property LastName As %String;

Property SSN As %String;

Property Gender As %String;

Property Deceased As %Boolean;

Storage Default
{
<Data name="PatientDefaultData">
<Subscript>"Patient"</Subscript>
<Value name="1">
<Value>Action</Value>
</Value>
<Value name="2">
<Value>InternalId</Value>
</Value>
<Value name="3">
<Value>FirstName</Value>
</Value>
<Value name="4">
<Value>LastName</Value>
</Value>
<Value name="5">
<Value>SSN</Value>
</Value>
<Value name="6">
<Value>Gender</Value>
</Value>
<Value name="7">
<Value>Deceased</Value>
</Value>
</Data>
<DefaultData>PatientDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
