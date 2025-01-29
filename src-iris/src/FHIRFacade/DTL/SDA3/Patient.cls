Class FHIRFacade.DTL.SDA3.Patient Extends Ens.DataTransformDTL [ DependsOn = (FHIRFacade.RES.PatientData, HS.SDA3.Patient) ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='FHIRFacade.RES.PatientData' targetClass='HS.SDA3.Patient' create='new' language='objectscript' >
<assign value='source.FirstName' property='target.Name.GivenName' action='set' />
<assign value='source.LastName' property='target.Name.FamilyName' action='set' />
<assign value='source.SSN' property='target.PatientNumbers.(1).Number' action='set' />
<assign value='"MRN"' property='target.PatientNumbers.(1).NumberType' action='set' />
<assign value='"MinistryOfHealth"' property='target.PatientNumbers.(1).ISOAssigningAuthority' action='set' />
<assign value='source.Gender' property='target.Gender.Code' action='set' />
<assign value='source.Deceased' property='target.IsDead' action='set' />
<assign value='source.InternalId' property='target.MPIID' action='set' />
</transform>
}

}
