#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

User Function GravaPV()
Local Ix       := 0
Local cQuery   := {}
Local cQryAux  := ""
Local _cDados  := ""
Local nPosC6_TES     := aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("C6_TES")})
Local nPosC6_ITEM    := aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("C6_ITEM")})
Local nPosC6_PRODUTO := aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("C6_PRODUTO")})
Local nPosC6_QTDVEN  := aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("C6_QTDVEN")})
Local nPosC6_CLI     := aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("C6_CLI")})
Local nPosC6_ENTREG  := aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("C6_ENTREG")})
Local nPosC6_LOJA    := aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("C6_LOJA")})
Local nPosC6_PEDCLI  := aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("C6_PEDCLI")})
Local cA1_NOME       := SA1->A1_NOME
Local cA1_NREDUZ     := SA1->A1_NREDUZ
Local cC5_TPFRETE    := M->C5_TPFRETE
Local cC5_LOJAENT    := M->C5_LOJAENT
Local cC5_NUM        := M->C5_NUM
Local cC5_TRANSP     := M->C5_TRANSP
Local nC5_PESOL      := M->C5_PESOL
Local nC5_PBRUTO     := M->C5_PBRUTO
Local cC5_VOLUME1    := M->C5_VOLUME1
Local cC5_ESPECI1    := M->C5_ESPECI1
Local cC6_XSTATUS    := M->C5_XSTATUS
Local cC6_IDINCL     := GetIDInc("SC6")
Local cC6_ACAO       := IIF(INCLUI,'1',IIF(ALTERA,'2','3'))
Local nResult        := 0

/*
GRUPO DE PRODUTOS - A - AMBOS
                       B - TIMBOX
                       P - TRIMPAPER
                       N - Não Integra
Verifico a TES se controla estoque manda a integração
*/



// Monta query para insert
cQuery  := " INSERT INTO INTEGRACAO.dbo.SC6010 "
cQuery  += "(C6_IDINCL,C6_DTCRIA,C6_STLEIT,C6_ACAO" 
cQryAux += " VALUES ('"+cC6_IDINCL+"','"+DtoS(Date())+"','0','"+cC6_ACAO+"'"



If !Empty(SA1->A1_NOME)
	cQuery   += ",A1_NOME"
	cQryAux  += ",'"+AllTrim(SA1->A1_NOME)+"'"
EndIf

If !Empty(SA1->A1_NREDUZ)
	cQuery   += ",A1_NREDUZ"
	cQryAux  += ",'"+AllTrim(SA1->A1_NREDUZ)+"'"
EndIf

If !Empty(SC5->C5_TPFRETE)
	cQuery   += ",C5_TPFRETE"
	cQryAux  += ",'"+AllTrim(SC5->C5_TPFRETE)+"'"
EndIf

If !Empty(SC5->C5_LOJAENT)
	cQuery   += ",C5_LOJAENT"
	cQryAux  += ",'"+AllTrim(SC5->C5_LOJAENT)+"'"
EndIf


// o XSTATUS está no C5 e não no C6
If !Empty(SC5->C5_XSTATUS)
	cQuery   += ",C6_XSTATUS"
	cQryAux  := ",'"+AllTrim(SC5->C5_XSTATUS)+"'"
EndIf

If !Empty(SC5->C5_NUM)
	cQuery   += ",C5_NUM"
	cQryAux  += ",'"+AllTrim(SC5->C5_NUM)+"'"
EndIf

If !Empty(SC5->C5_TRANSP)
	cQuery   += ",C5_TRANSP"
	cQryAux  += ",'"+AllTrim(SC5->C5_TRANSP)+"'"
EndIf

If !Empty(SC5->C5_PESOL)
	cQuery   += ",C5_PESOL"
	cQryAux  += ","+AllTrim(SC5->C5_PESOL)
EndIf

If !Empty(SC5->C5_PBRUTO)
	cQuery   += ",C5_PBRUTO"
	cQryAux  += ","+AllTrim(SC5->C5_PBRUTO)
EndIf

If !Empty(SC5->C5_VOLUME1)
	cQuery   += ",C5_VOLUME1"
	cQryAux  += ","+AllTrim(SC5->C5_VOLUME1)
EndIf

If !Empty(SC5->C5_ESPECI1)
	cQuery   += ",C5_ESPECI1"
	cQryAux  += ",'"+AllTrim(SC5->C5_ESPECI1)+"'"
EndIf

For Ix := 1 to Len(Acols)
	dbSelectArea("SF4")
	dbSetOrder(1)
	If dbSeek(xFilial("SF4")+aCols[Ix,nPosC6_TES])
		If SF4->F4_ESTOQUE=="S"
			lEstoque := .T.
		Else
			lEstoque := .F.
		EndIf
	EndIf
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	If dbSeek(xFilial("SB1")+aCols[Ix,nPosC6_PRODUTO])
		dbSelectArea("SBM")
		dbSetOrder(1)
		If dbSeek(xFilial("SBM")+SB1->B1_GRUPO)
			If SBM->BM_INTEGRA == "N"
				lIntegra := .F.
			Else
				lIntegra := .T.
			EndIf
		EndIf
	EndIf			

	// C6_QUANT
	cQuery   += ",C6_QTDVEN"
	cQryAux  += ","+cValtoChar(aCols[Ix,nPosC6_QTDVEN])


	//C6_SALPROD
	dbSelectArea("SB2")
	dbSetOrder(1)
	If dbSeek(xFilial("SB2")+aCols[Ix,nPosC6_PRODUTO])
		cQuery  += ", C6_SALPROD"
		cQryAux += ","+cValtoChar(SaldoSB2())
	Else 
		cQuery  += ", C6_SALPROD"
		cQryAux += ",0"
	EndIf
		
	If !Empty(M->C5_FILIAL)
		cQuery   += ",C6_FILIAL"
		cQryAux  += ",'"+Alltrim(M->C5_FILIAL)+"'"
	EndIf
	
	If !Empty(aCols[Ix,nPosC6_ITEM])
		cQuery   += ",C6_ITEM"
		cQryAux  += ",'"+Alltrim(aCols[Ix,nPosC6_ITEM])+"'"
	EndIf
	
	If !Empty(aCols[Ix,nPosC6_PRODUTO])
		cQuery   += ",C6_PRODUTO"
		cQryAux  += ",'"+Alltrim(aCols[Ix,nPosC6_PRODUTO])+"'"
	EndIf

	
	If !Empty(aCols[Ix,nPosC6_ENTREG])
		cQuery   += ",C6_ENTREG"
		cQryAux  += ",'"+DtoS(aCols[Ix,nPosC6_ENTREG])+"'"
	EndIf
	

	If !Empty(aCols[Ix,nPosC6_PEDCLI])
		cQuery   += ",C6_PEDCLI"
		cQryAux  += ",'"+Alltrim(aCols[Ix,nPosC6_PEDCLI])+"'"
	EndIf
	cQuery  += " ) "
	cQryAux += " ) "
	
	If lEstoque .AND. lIntegra
		nResult := TcSqlExec(cQuery+cQryAux)
		
		If nResult > 0
			CONOUT("INTEGRACAO COM SC6 EXECUTADA COM SUCESSO...")
		Else
			CONOUT(OemToAnsi("Erro ao atualizar banco INTEGRACAO: ")+TCSqlError())	
		Endif
	Else
		MSGInfo("Não gerado por causa do Grupo ou da TES", "Registro não gerado")
	EndIf
next Ix	

Return()


/*
 * Função para retornar o ID de Inclusao
 */
Static Function GetIDInc(cTabela)
Local cID  := SPACE(10)
Local cQry := "SELECT ISNULL(MAX(C6_IDINCL),1) as C6_IDINCL FROM INTEGRACAO.dbo.SC6010" 

If Select("INTSC6")>0
	INTSC6->(dbCloseArea())
EndIf
	
TcQuery cQry New Alias "INTSC6"

If !Eof()
	cID := Soma1(STRZero(Val(INTSC6->C6_IDINCL),10))
Else
 	MsgInfo("Erro na geração do ID de Inclusão da tabela SC6","Integração")
EndIf

Return(cID)

