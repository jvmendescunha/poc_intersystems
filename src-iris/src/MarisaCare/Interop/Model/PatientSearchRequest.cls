Class MarisaCare.Interop.Model.PatientSearchRequest Extends Ens.Request
{

Property LastName As %String;

Property SSN As %String;

Property Gender As %String;

Storage Default
{
<Data name="PatientSearchRequestDefaultData">
<Subscript>"PatientSearchRequest"</Subscript>
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
<DefaultData>PatientSearchRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
