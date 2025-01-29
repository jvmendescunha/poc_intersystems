Class FHIRFacadeMC.PROD.FoundationProduction Extends Ens.Production [ Not ProcedureBlock ]
{

XData ProductionDefinition
{
<Production Name="FHIRFacadeMC.PROD.FoundationProduction" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>1</ActorPoolSize>
  <Item Name="FHIRFacadeMC.API.Rest" Category="" ClassName="FHIRFacadeMC.API.Rest" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="Patient BS" Category="" ClassName="FHIRFacadeMC.BS.Patient" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigName"></Setting>
  </Item>
  <Item Name="Patient Database" Category="" ClassName="FHIRFacadeMC.BO.Database" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
  </Item>
  <Item Name="FromMongoDB" Category="" ClassName="MarisaCare.Interop.Operations.FromMongoDB" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="SendingFacility">MC</Setting>
    <Setting Target="Host" Name="CodingStandard">MC</Setting>
    <Setting Target="Adapter" Name="Credentials">mongodb</Setting>
    <Setting Target="Adapter" Name="MongoUri"><![CDATA[mongodb+srv://<db_user>:<db_password>@cluster0.y1uie.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0&tlsAllowInvalidCertificates=true]]></Setting>
  </Item>
</Production>
}

}
