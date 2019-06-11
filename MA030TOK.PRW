#include 'protheus.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'
#include 'topconn.ch'

user function ma030tok()
Local lRet := .F.

	If INCLUI
		lRet := fIncCli(1)
	ElseIf ALTERA
		lRet := fIncCli(2)
	EndIf
return(lRet)

/*
 * Função para incluir no banco de INTEGRACAO o registro do Cliente
 */
User Function fIncCli(nOpc)
Local lRet
Local cQuery := ""
Local cQryAux:= ""
Local cAcao  := ""
Local cIDIncl := ""

If INCLUI
	cAcao := "1"
ElseIf ALTERA
	cAcao := "2"
Else 
	cAcao := "3"
EndIf

cQuery := "INSERT INTO INTEGRACAO.dbo.SA1010 (A1_IDINCL,A1_DTCRIA,A1_STLEIT,A1_ACAO,"
cQryAux:= "VALUES ('"+GetIDInc("SA1")+"','"+DtoS(Date())+"','0','"+cAcao+"',"

cQuery  += ",A1_FILIAL"
cQryAux += ",'"+Alltrim(M->A1_FILIAL)+"'"

cQuery  += ",A1_COD"
cQryAux += ",'"+Alltrim(M->A1_COD)+"'"

cQuery  += ",A1_LOJA"
cQryAux += ",'"+Alltrim(M->A1_LOJA)+"'"

cQuery  += ",A1_NOME"
cQryAux += ",'"+Alltrim(M->A1_NOME)+"'"

cQuery  += ",A1_EST"
cQryAux += ",'"+Alltrim(M->A1_EST)+"'"

cQuery  += ",A1_CEP"
cQryAux += ",'"+Alltrim(M->A1_CEP)+"'"

cQuery  += ",A1_COD_MUN"
cQryAux += ",'"+Alltrim(M->A1_COD_MUN)+"'"

cQuery  += ",A1_MUN"
cQryAux += ",'"+Alltrim(M->A1_MUN)+"'"


If !Empty(M->A1_PESSOA) 
	cQuery  += ",A1_PESSOA"
	cQryAux += ",'"+Alltrim(M->A1_PESSOA)+"'"
EndIf
If !Empty(M->A1_END)    
	cQuery  += ",A1_END"
	cQryAux += ",'"+Alltrim(M->A1_END)+"'"
EndIf
If !Empty(M->A1_NREDUZ) 
	cQuery  += ",A1_NREDUZ"
	cQryAux += ",'"+Alltrim(M->A1_NREDUZ)+"'"
EndIf
If !Empty(M->A1_BAIRRO) 
	cQuery  += ",A1_BAIRRO"
	cQryAux += ",'"+Alltrim(M->A1_BAIRRO)+"'"
EndIf
If !Empty(M->A1_REGIAO) 
	cQuery  += ",A1_REGIAO"
	cQryAux += ",'"+Alltrim(M->A1_REGIAO)+"'"
If !Empty(M->A1_DSCREG)    
	cQuery  += ",A1_DSCREG"
	cQryAux += ",'"+Alltrim(M->A1_DSCREG)+"'"
EndIf
If !Empty(M->A1_TEL)       
	cQuery  += ",A1_TEL"
	cQryAux += ",'"+Alltrim(M->A1_TEL)+"'"
EndIf
If !Empty(M->A1_COMPENT)   
	cQuery  += ",A1_COMPENT"
	cQryAux += ",'"+Alltrim(M->A1_COMPENT)+"'"
EndIf
If !Empty(M->A1_CONTATO)   
	cQuery  += ",A1_CONTATO"
	cQryAux += ",'"+Alltrim(M->A1_CONTATO)+"'"
EndIf
If !Empty(M->A1_CGC)       
	cQuery  += ",A1_CGC"
	cQryAux += ",'"+Alltrim(M->A1_CGC)+"'"
EndIf
If !Empty(M->A1_INSCR)     
	cQuery  += ",A1_INSCR"
	cQryAux += ",'"+Alltrim(M->A1_INSCR)+"'"
EndIf
If !Empty(M->A1_PAIS)      
	cQuery  += ",A1_PAIS"
	cQryAux += ",'"+Alltrim(M->A1_PAIS)+"'"
EndIf
If !Empty(M->A1_VEND)      
	cQuery  += ",A1_VEND"
	cQryAux += ",'"+Alltrim(M->A1_VEND)+"'"
EndIf
If !Empty(M->A3_NOME)      
	cQuery  += ",A3_NOME"
	cQryAux += ",'"+Alltrim(M->A3_NOME)+"'"
EndIf
If !Empty(M->A1_TRANSP    
	cQuery  += ",A1_LOJA"
	cQryAux += ",'"+Alltrim(M->A1_LOJA)+"'"
EndIf
If !Empty(M->A4_NOME)      
	cQuery  += ",A4_NOME"
	cQryAux += ",'"+Alltrim(M->A4_NOME)+"'"
EndIf
If !Empty(M->A1_EMAIL)     
	cQuery  += ",A1_EMAIL"
	cQryAux += ",'"+Alltrim(M->A1_EMAIL)+"'"
EndIf

cQuery  += ") "
cQryAux += ") " 

/*
cQuery := " INSERT INTO INTEGRACAO.dbo.SA1010 "
cQuery += " A1_IDINCL,A1_IDINTE,A1_DTCRIA,A1_DTLEIT,A1_STLEIT,A1_MENSAG,A1_ACAO,A1_FILIAL,A1_COD,A1_LOJA,A1_NOME, "
cQuery += " A1_PESSOA,A1_END,A1_NREDUZ,A1_BAIRRO,A1_EST,A1_CEP,A1_COD_MUN,A1_MUN,A1_REGIAO,A1_DSCREG,A1_TEL, "
cQuery += " A1_COMPENT,A1_CONTATO,A1_CGC,A1_INSCR,A1_PAIS,A1_VEND,A1_TRANSP,A1_EMAIL " 
cQuery += "  VALUES ('"+GetIDInc("SA1")+"','','"+DtoS(Date())+"','','0','','"+cValtoChar(nOpc)+"','"+SA1->A1_FILIAL+"',"
cQuery += " '"+SA1->A1_COD+"','"+SA1->A1_LOJA+"','"+SA1->A1_NOME+"','"+SA1->A1_PESSOA+"','"+SA1->A1_END+"',"
cQuery += " '"+SA1->A1_NREDUZ+"','"+SA1->A1_BAIRRO+"','"+SA1->A1_EST+"','"+SA1->A1_CEP+"','"+SA1->A1_COD_MUN+"' "
cQuery += " '"+SA1->A1_A1_MUN+"','"+SA1->A1_A1_REGIAO+"','"+SA1->A1_A1_DSCREG+"','"+SA1->A1_A1_TEL+"', " 
cQuery += " '"+SA1->A1_COMPENT+"','"+SA1->A1_CONTATO+"','"+SA1->A1_CGC+"','"+SA1->A1_INSCR+"','"+SA1->A1_PAIS+"','"+SA1->A1_VEND+"', "
cQuery += " '"+SA1->A1_TRANSP+"','"+Alltrim(A1_EMAIL)+"' )"
*/

nStatus := TcSQLExec(cQuery)
If nStatus < 0
    MSGInfo(OemToAnsi("Erro ao atualizar banco INTEGRACAO: ")+TCSqlError(),"Integração")
    lRet := .F.
EndIf
 
Return(lRet)
 

/*
 * Função para retornar o ID de Inclusao
 */
User Function GetIDInc(cTabela)
Local cID  := SPACE(10)
Local cQry := "SELECT ISNULL(MAX(A1_IDINCL),1) as A1_IDINCL FROM INTEGRACAO.dbo."+cTabela+"010" 

If Select("INTSA1")>0
	INTSA1->(dbCloseArea())
EndIf
	
TcQuery cQry New Alias "INTSA1"

If !Eof()
	cID := Soma1(STRZero(Val(INTSA1->A1_IDINC),10))
Else
 	MsgInfo("Erro na geração do ID de Inclusão","Integração")
 
Return(cID)