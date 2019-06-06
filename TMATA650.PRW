#Include "Protheus.ch"
#include "rwmake.ch"
#include "TbiConn.ch"
#include "TopConn.ch"
 
User Function Tmata650()
Local cQuery    := ""
Local aDados    := {}


PREPARE ENVIRONMENT EMPRESA "01" FILIAL "A0101"

//nHandle := TCLink( "MSSQL/P12LOCAL", "127.0.0.1", 7890 )

CONOUT(OemToAnsi("Acesso ao banco de dados INTEGRACAO..."))
cQuery := " SELECT C2_IDINCL,C2_DTCRIA,C2_STLEIT,C2_ACAO,C2_FILIAL,C2_NUM,C2_ITEM,C2_SEQUEN,C2_PRODUTO,"
cQuery += " C2_LOCAL,C2_CC,C2_QUANT,C2_UM,C2_DTPRI,C2_DTPRF,C2_EMISSAO,C2_STATUS,C2_PEDIDO,C2_ITEMPV FROM "
cQuery += " INTEGRACAO.dbo.SC2010 WHERE C2_STLEIT='0' "

If Select("MURO")>0
	MURO->(dbCloseArea())
EndIf

TcQuery cQuery NEW Alias "MURO"

While !(MURO->(EOF()))
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL MURO->C2_FILIAL
	
	cFilAnt := MURO->C2_FILIAL
    
    AADD(aDados,{   MURO->C2_IDINCL,;	
                    fCvDT(MURO->C2_DTCRIA),; 
                    MURO->C2_STLEIT,; 
                    MURO->C2_ACAO,;	
                    MURO->C2_FILIAL,;	
                    MURO->C2_NUM,; 
                    MURO->C2_ITEM,;	
                    MURO->C2_SEQUEN,;	
                    MURO->C2_PRODUTO,; 
                    MURO->C2_LOCAL,;	
                    MURO->C2_CC,;
                    MURO->C2_QUANT,;	
                    MURO->C2_UM,;	
                    fCvDT(MURO->C2_DTPRI),;	
                    fCvDT(MURO->C2_DTPRF),;
                    fCvDT(MURO->C2_EMISSAO),;	
                    MURO->C2_STATUS,;		
                    MURO->C2_PEDIDO,;	
                    MURO->C2_ITEMPV})

    MURO->(dbSkip())
End



If Len(aDados) > 0
    For nX := 1 to Len(aDados)
//        CONOUT(OemToAnsi("Inicio das validações..."))
        If fValida(aDados[nX])
            fAcao(aDados[nX])
        EndIf
    Next nX    
EndIf

 
RESET ENVIRONMENT
 
Return Nil


/*/{Protheus.doc} fValida
    Função para validação dos dados
    @type  Static Function
    @author Eduardo Pesssoa
    @since 20/05/2019
    @version 1.0
    @param aDados, array, dados da Integração
    @return lRet, boolean, Quando passar por todas as validações retorna True
    @example
    Não se aplica
    @see Documentos da Integração Sengés
/*/
Static Function fValida(aArray)
Local lRet       := .T.
Local cMensError := ""
Local cQuery     := ""
Local nStatus    := 0

/*
01)MURO->C2_IDINCL,;02)MURO->C2_IDINTE,;03)CtoD(MURO->C2_DTCRIA),;04)MURO->C2_STLEIT,;05)MURO->C2_ACAO,;	
06)MURO->C2_FILIAL,;07)MURO->C2_NUM,;08)MURO->C2_ITEM,;09)MURO->C2_SEQUEN,;10)MURO->C2_PRODUTO,;
11)MURO->C2_LOCAL,;12)MURO->C2_CC,;13)MURO->C2_QUANT,;14)MURO->C2_UM,;15)CtoD(MURO->C2_DATPRI),;
16)CtoD(MURO->C2_EMISSAO),;17)MURO->C2_STATUS,;18)MURO->C2_NIVEL,;19)MURO->C2_PEDIDO,;20)MURO->C2_ITEMPV})
*/
// Valida Filial
If aArray[5] <> xFilial("SC2")
    cMensError += "Erro na origem, filial da Integração difere da filial do Protheus. "+Chr(10)+Chr(13)
    lRet := .F.
EndIf

// Valida se existe a OP
If aArray[4] == '1' // Incluir, não pode existir OP
    dbSelectArea("SC2")
    dbSetOrder(1)
    If SC2->(dbSeek(xFilial("SC2")+AllTrim(aArray[7])+Alltrim(aArray[8])+Alltrim(aArray[9])))
        cMensError += "Erro na origem, este número de OP já existe no Protheus, não permite inclusão"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf
ElseIf aArray[4]  == '2'  // Alterar, tem que existir a OP
    dbSelectArea("SC2")
    dbSetOrder(1)
    If !SC2->(dbSeek(xFilial("SC2")+AllTrim(aArray[6])+Alltrim(aArray[7])+Alltrim(aArray[8])))
        cMensError += "Erro na origem, este número de OP não existe no Protheus, não permite Alteração"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf
ElseIf aArray[4] == '3'  // Excluir, tem que existir a OP
    dbSelectArea("SC2")
    dbSetOrder(1)
    If !SC2->(dbSeek(xFilial("SC2")+AllTrim(aArray[6])+Alltrim(aArray[7])+Alltrim(aArray[8])))
        cMensError += "Erro na origem, este número de OP não existe no Protheus, não permite Exclusão"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf    
ElseIf aArray[4] <> '1' .AND. aArray[4] <> '2' .AND. aArray[4] <> '3'
    cMensError += "Erro na origem, ação inválida para operações com OP"+Chr(10)+Chr(13)   
    lRet := .F.
EndIf

// Valida o Produto - Verifica se existe no cadastro de Produtos e se não está bloqueado
dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1")+Alltrim(aArray[09]))
    If SB1->B1_MSBLQL == '1'
        cMensError += "Erro na origem, este produto encontra-se bloquado no sistema Protheus, não será permitido operação com OP"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf
Else
    cMensError += "Erro na origem, este produto não existe no cadastro do Protheus"+Chr(10)+Chr(13)        
    lRet := .F.
EndIf

// Verifica se o local veio na Integração e se veio verifica se é valido
If Empty(aArray[10])
    If Empty(SB1->B1_LOCPAD)
        cMensError += "Erro na origem, os armazéns da Integração quanto do Cadastro de Produtos estão vazios, não será permitido operações com OP"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf
Else
    dbSelectArea("NNR")
    dbSetOrder(1)
    If !dbSeek(xFilial("NNR")+AllTrim(aArray[10]))
        cMensError += "Erro na origem, não existe o armazém no sistema Protheus, não será permitido operações com OP"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf
EndIf    

// Grava o status de leitura e a mensagem do erro
If !lRet
    cQuery := " UPDATE INTEGRACAO.dbo.SC2010 SET C2_STLEIT='2',C2_MENSAG='"+cMensError+"',C2_DTLEIT='"+DTOS(DATE())+"' WHERE C2_IDINCL='"+aArray[1]+"' "
    nStatus := TcSQLExec(cQuery)
    If nStatus < 0
        CONOUT(OemToAnsi("Erro ao atualizar banco INTEGRACAO: ")+TCSqlError())
    EndIf
EndIf

Return(lRet)

/*/{Protheus.doc} fAcao
    Executa a ação no cadastro de OP (Inclusão, Alteração ou Exclusão)
    @type  Static Function
    @author Eduardo Pessoa
    @since 20/05/2019
    @version 1.0
    @param aDados, Array, Array com dados da tabela muro para integração
    @return lRet, boolean, Indica se a integração ocorreu com sucesso
    @example
    Não se aplica
    @see Documentos de integração
/*/
Static Function fAcao(aArray)
Local lRet := .T.
Local aMATA650  := {} //-Array com os campos

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 3 - Inclusao ³
//³ 4 - Alteracao ³
//³ 5 - Exclusao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nOpc := 0
Private lMsErroAuto := .F.

If aArray[4]=='1'
	nOpc := 3
ElseIf aArray[4]=='2'
	nOpc := 4
ElseIf aArray[4]=='3'
	nOpc := 5
EndIf	

/*
01)MURO->C2_IDINCL,;	
02)fCvDT(MURO->C2_DTCRIA),; 
03)MURO->C2_STLEIT,; 
04)MURO->C2_ACAO,;	
05)MURO->C2_FILIAL,;	
06)MURO->C2_NUM,; 
07)MURO->C2_ITEM,;	
08)MURO->C2_SEQUEN,;	
09)MURO->C2_PRODUTO,; 
10)MURO->C2_LOCAL,;	
11)MURO->C2_CC,;
12)MURO->C2_QUANT,;	
13)MURO->C2_UM,;	
14)fCvDT(MURO->C2_DTPRI),;	
15)fCvDT(MURO->C2_DTPRF),;
16)fCvDT(MURO->C2_EMISSAO),;	
17)MURO->C2_STATUS,;		
18)MURO->C2_PEDIDO,;	
19)MURO->C2_ITEMPV})


*/

aMATA650 := {   {'C2_FILIAL',aArray[5],NIL},;
                {'C2_NUM',aArray[6],NIL},; 
                {'C2_ITEM',aArray[7],NIL},; 
                {'C2_SEQUEN',aArray[8],NIL},;
                {'C2_PRODUTO',aArray[9],NIL},;
                {'C2_LOCAL',aArray[10],NIL},;
                {'C2_QUANT',aArray[12],NIL},;
                {'C2_UM',aArray[13],NIL},;
                {'C2_TPOP',"F",NIL},;
                {'C2_TPPR',"I",NIL},;
                {'C2_DATPRI',aArray[14],NIL},;
                {'C2_DATPRF',aArray[15],NIL},;
                {'C2_EMISSAO',aArray[16],NIL},;
                {'C2_STATUS',aArray[17],NIL},;
                {'C2_PEDIDO',aArray[18],NIL},;
                {'C2_ITEMPV',aArray[19],NIL},;
                {'AUTEXPLODE' ,"S" ,NIL}}
 

ConOut("Inicio : "+Time())
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se alteracao ou exclusao, deve-se posicionar no registro ³
//³ da SC2 antes de executar a rotina automatica ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 4 .Or. nOpc == 5
 SC2->(DbSetOrder(1))//FILIAL + NUM + ITEM + SEQUEN + ITEMGRD
 SC2->(DbSeek(xFilial("SC2")+aArray[7]+aArray[8]+aArray[9]))
EndIf

msExecAuto({|x,Y| Mata650(x,Y)},aMata650,nOpc)

If !lMsErroAuto
 	ConOut("Sucesso! ")
	// Grava o status de leitura
	If lRet
	    cQuery := " UPDATE INTEGRACAO.dbo.SC2010 SET C2_STLEIT='4',C2_DTLEIT='"+DtoS(Date())+"',C2_IDINTE=C2_IDINCL "
	    cQuery += " WHERE C2_IDINCL='"+aArray[1]+"' "
	    nStatus := TcSQLExec(cQuery)
	    If nStatus < 0
	        CONOUT(OemToAnsi("Erro ao atualizar banco INTEGRACAO: ")+TCSqlError())
	    EndIf
	EndIf
Else
    ConOut("Erro!")
    MostraErro()
    lRet := .F.
EndIf
 
ConOut("Fim : "+Time())

Return(lRet)


/*----------------------------------------------------------*
 * Converte uma data String (AAAAMMDD) em date (DD/MM/AAAA)
 *----------------------------------------------------------*/
static function fCvDT(cData)
Local dRet := cTod("  /  /  ")
dRet := cTod(SubSTR(cData,7,2)+"/"+SubSTR(cData,5,2)+"/"+SubSTR(cData,1,4))
Return(dRet)