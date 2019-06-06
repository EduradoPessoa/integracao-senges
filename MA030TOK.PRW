#include 'protheus.ch'
#include 'parmtype.ch'

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