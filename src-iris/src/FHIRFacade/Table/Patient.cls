Class FHIRFacade.Table.Patient Extends %Persistent
{

Property FirstName As %String;

Property LastName As %String;

Property SSN As %String;

Index SSNIndex On SSN [ Unique ];

Property Gender As %String;

Property Deceased As %Boolean [ InitialExpression = 0 ];

Storage Default
{
<Data name="PatientDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
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
<DataLocation>^FHIRFacade.Table.PatientD</DataLocation>
<DefaultData>PatientDefaultData</DefaultData>
<ExtentSize>3</ExtentSize>
<IdLocation>^FHIRFacade.Table.PatientD</IdLocation>
<IndexLocation>^FHIRFacade.Table.PatientI</IndexLocation>
<Property name="%%CLASSNAME">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="%%ID">
<AverageFieldSize>3</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<Property name="Deceased">
<AverageFieldSize>2</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="FirstName">
<AverageFieldSize>9</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="Gender">
<AverageFieldSize>6</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="LastName">
<AverageFieldSize>7</AverageFieldSize>
<Selectivity>100.0000%</Selectivity>
</Property>
<Property name="SSN">
<AverageFieldSize>14.67</AverageFieldSize>
<Selectivity>1</Selectivity>
</Property>
<SQLMap name="IDKEY">
<BlockCount>-4</BlockCount>
</SQLMap>
<SQLMap name="SSNIndex">
<BlockCount>-4</BlockCount>
</SQLMap>
<StreamLocation>^FHIRFacade.Table.PatientS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
