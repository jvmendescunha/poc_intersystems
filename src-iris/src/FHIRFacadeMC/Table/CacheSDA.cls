Class FHIRFacadeMC.Table.CacheSDA Extends %Persistent
{

Property Id As %String;

Property Facility As %String;

Property TS As %Numeric;

Property SDAStream As %Stream.GlobalCharacter;

Property JSONStream As %Stream.GlobalCharacter;

Index SDAIndex On (Facility, Id) [ Unique ];

Storage Default
{
<Data name="CacheSDADefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Id</Value>
</Value>
<Value name="3">
<Value>Facility</Value>
</Value>
<Value name="4">
<Value>ContainerSDA</Value>
</Value>
<Value name="5">
<Value>SDAStream</Value>
</Value>
<Value name="6">
<Value>TS</Value>
</Value>
<Value name="7">
<Value>JSONStream</Value>
</Value>
</Data>
<DataLocation>^FHIRFacadeMC.Table.CacheSDAD</DataLocation>
<DefaultData>CacheSDADefaultData</DefaultData>
<IdLocation>^FHIRFacadeMC.Table.CacheSDAD</IdLocation>
<IndexLocation>^FHIRFacadeMC.Table.CacheSDAI</IndexLocation>
<StreamLocation>^FHIRFacadeMC.Table.CacheSDAS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
