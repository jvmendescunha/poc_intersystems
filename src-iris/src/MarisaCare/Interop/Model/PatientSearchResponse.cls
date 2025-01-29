Class MarisaCare.Interop.Model.PatientSearchResponse Extends Ens.Response
{

Property Success As %Boolean [ InitialExpression = 1 ];

Property ErrorMessage As %String(MAXLEN = 500);

Property SDAStreamList As list Of %Stream.GlobalCharacter;

Storage Default
{
<Data name="PatientSearchResponseDefaultData">
<Subscript>"PatientSearchResponse"</Subscript>
<Value name="1">
<Value>Success</Value>
</Value>
<Value name="2">
<Value>ErrorMessage</Value>
</Value>
<Value name="3">
<Value>SDAStreamList</Value>
</Value>
</Data>
<DefaultData>PatientSearchResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
