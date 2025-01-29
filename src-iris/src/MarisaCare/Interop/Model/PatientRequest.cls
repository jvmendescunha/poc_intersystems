Class MarisaCare.Interop.Model.PatientRequest Extends Ens.Request
{

Property PatientId As %String(MAXLEN = 50);

Property PatientCpf As %String(MAXLEN = 50);

Storage Default
{
<Data name="PatientRequestDefaultData">
<Subscript>"PatientRequest"</Subscript>
<Value name="1">
<Value>PatientId</Value>
</Value>
<Value name="2">
<Value>PatientCpf</Value>
</Value>
</Data>
<DefaultData>PatientRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
