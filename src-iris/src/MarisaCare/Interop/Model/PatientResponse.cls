Class MarisaCare.Interop.Model.PatientResponse Extends Ens.Response
{

Property Success As %Boolean [ InitialExpression = 1 ];

Property ErrorMessage As %String(MAXLEN = 500);

Property SDAStream As %Stream.GlobalCharacter;

Storage Default
{
<Data name="PatientResponseDefaultData">
<Subscript>"PatientResponse"</Subscript>
<Value name="1">
<Value>Success</Value>
</Value>
<Value name="2">
<Value>ErrorMessage</Value>
</Value>
<Value name="3">
<Value>SDAStream</Value>
</Value>
</Data>
<DefaultData>PatientResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
