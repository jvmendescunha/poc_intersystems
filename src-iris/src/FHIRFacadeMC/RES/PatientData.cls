Class FHIRFacadeMC.RES.PatientData Extends (%SerialObject, %XML.Adaptor)
{

Property InternalId As %Integer;

Property FirstName As %String;

Property LastName As %String;

Property SSN As %String;

Property Gender As %String;

Property Deceased As %Boolean;

Storage Default
{
<Data name="PatientDataState">
<Value name="1">
<Value>InternalId</Value>
</Value>
<Value name="2">
<Value>FirstName</Value>
</Value>
<Value name="3">
<Value>LastName</Value>
</Value>
<Value name="4">
<Value>SSN</Value>
</Value>
<Value name="5">
<Value>Gender</Value>
</Value>
<Value name="6">
<Value>Deceased</Value>
</Value>
</Data>
<State>PatientDataState</State>
<StreamLocation>^FHIRFacadeMC.RES.PatientDataS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}
