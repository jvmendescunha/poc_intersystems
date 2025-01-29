Class custom.EHRInterop.Core.Util.SDA3 Extends %RegisteredObject
{

ClassMethod StrippedValue(pRawValue As %String) As %String
{
	Quit $ZSTRIP($ZSTRIP(pRawValue,"*C"),"<>W")
}

ClassMethod CodeTable(pTableName As %String, pCode As %String, pDescription As %String = "", pCodingStandard As %String = "") As HS.SDA3.CodeTableDetail
{
	Set tCodingStandard = pCodingStandard
	If (pCodingStandard '= "") {
		Set tCodingStandard = pCodingStandard_"_"_$ZCONVERT(pTableName,"U")
	}
	Quit ..CodeTableRaw(pTableName,pCode,pDescription,tCodingStandard)
}

ClassMethod CodeTableRaw(pTableName As %String, pCode As %String, pDescription As %String = "", pCodingStandard As %String = "") As HS.SDA3.CodeTableDetail
{
	If (pTableName = "") || (pCode = "") {
		Quit ""
	}
	If ##class(%Dictionary.CompiledClass).%ExistsId("HS.SDA3.CodeTableDetail."_pTableName) {
		Set tTable = $ZObjClassMethod("HS.SDA3.CodeTableDetail."_pTableName,"%New")
	}
	Else {
		Set tTable = ##class(HS.SDA3.CodeTableDetail).%New()
	}
	Set tTable.SDATableName = pTableName
	Set tTable.Code = pCode
	Set tTable.Description = pDescription
	Set tTable.SDACodingStandard = pCodingStandard
	Quit tTable
}

ClassMethod CodeTableClinician(pTableName As %String, pClinicianCod As %String, pClinicianRegCod As %String, pClinicianRegDesc As %String = "", pClinicianName As %String = "", pCodingStandard As %String) As HS.SDA3.CodeTableDetail
{
	; O usuário é o código do usuário no conselho (CRM) e o Coding Standard é seu respectivo CONSELHO (Ex: CRM-SP).
	; Caso seja nulo, usa o código do usuario na tabela e o Coding Standard padrão
	Set tClinCod = pClinicianCod, tClinCodStd = pCodingStandard
	If ($ZSTRIP(pClinicianRegCod,"*C")'="") && ($ZSTRIP(pClinicianRegDesc,"*C")'="")
	{
		Set tClinCod = pClinicianRegCod
		Set tClinCodStd = pClinicianRegDesc
	}
	If tClinCod '= "" Quit ..CodeTableRaw(pTableName,tClinCod,pClinicianName,tClinCodStd)
	Quit ""
}

ClassMethod CodeTableText(pTableName As %String, pText As %String, pCodingStandard As %String = "") As HS.SDA3.CodeTableDetail
{
	If pText = "" {
		Quit ""
	}
	Set tText = $ZStrip($ZConvert(pText,"W"),"<>W")
	Quit ..CodeTable(pTableName, $Extract(tText), tText, pCodingStandard)
}

// Remove caracteres de controle, exceto line feed, carriage return e tab

ClassMethod RemoveControlChars(pText) As %String
{
	FOR code=1:1:31
	{
		if (code '= 10) && (code '= 13) && (code '= 9)
		{
			Set byte = $Char(code)
			Set pText = $Translate(pText,byte,"")
		}
	}
	
	Quit pText
}

ClassMethod ExisteConteudo(pTexto) As %String
{
	Set ExisteConteudo=1
	If $ZSTRIP(pTexto,"*C")="" Set ExisteConteudo=""
	Quit ExisteConteudo
}

ClassMethod StripWideChars(pInput As %String) As %String
{
	Set tInput = ##class(%Stream.TmpCharacter).%New()
	Do tInput.Write(pInput)
	Do tInput.Rewind()

	Set tOutput = ##class(%Stream.TmpCharacter).%New()

	While 'tInput.AtEnd 
	{
		Set tChar = tInput.Read(1)
		
		If ('$ZISWIDE(tChar)) 
		{
			Do tOutput.Write(tChar)
		}
	}

	Do tOutput.Rewind()
	
	Quit tOutput.Read()
}

ClassMethod SplitName(fullname As %String, Output tSC) As HS.SDA3.Name
{
	Set tSC = $$$OK
    Set tOutput = ""
    Set tName = $ZStrip($ZStrip(fullname, "*C"),"<>W")

    If (tName '= "")
    {
        While $Find(tName,"  ") > 0 
        {
            Set tName = $Replace(tName,"  "," ")
        }

        Set tPieces = $Length(tName," "), (tMiddleName, tSuffix) = ""
        Set tSurname = $Piece(tName," ",tPieces)
        
        If (",FILHO,JUNIOR,NETO,JR,JR.,"[(","_$ZConvert(tSurname,"U")_",")) 
        { 
            // Sufixo
            Set tPieces = tPieces - 1
            Set tSuffix = tSurname
            Set tSurname = $Piece(tName," ",tPieces)
        }

        Set tFirstName = $Piece(tName," ",1)
        
        If (tPieces > 2) 
        {
            Set tMiddleName = $Piece(tName," ",2,tPieces-1)
        }
        
        Set tOutput = ##class(HS.SDA3.Name).%New()
        Set tOutput.FamilyName = tSurname
        Set tOutput.NameSuffix = tSuffix
        Set tOutput.GivenName = tFirstName
        Set tOutput.MiddleName = $Extract(tMiddleName,1,50)
    }
	
	Quit tOutput
}

ClassMethod PatientNumber(number As %String, pTipo As %String, pCodigoOrganizacao As %String, pOrganizacao As %String, Output tSC As %Status) As HS.SDA3.PatientNumber
{
	Set tSC = $$$OK
    Set target = ##class(HS.SDA3.PatientNumber).%New()
	If (number '="")
	{
		Set target.Number       = number
		If pCodigoOrganizacao'="" Set target.Organization = ..CodeTable("Organization",pCodigoOrganizacao,pOrganizacao)
		Set target.NumberType   = pTipo
	}
    Quit target
}

ClassMethod ContactInfo(res As %String = "", com As %String = "", mob As %String = "", email As %String = "", Output tSC As %Status) As HS.SDA3.ContactInfo
{
	Set tSC = $$$OK
	Set target = ##class(HS.SDA3.ContactInfo).%New()
	
	Set target.HomePhoneNumber = $ZStrip(res,"*C")
	Set target.WorkPhoneNumber = $ZStrip(com,"*C")
	Set target.MobilePhoneNumber = $ZStrip(mob,"*C")
	Set target.EmailAddress = $ZStrip(email,"*C")
   
	Quit target
}

}
