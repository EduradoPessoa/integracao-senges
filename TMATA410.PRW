#Include "Protheus.ch"
#include "rwmake.ch"
#include "TbiConn.ch"
#include "TopConn.ch"
 
User Function Tmata410()
Local cQuery    := ""
Local aDados    := {}
Local lContAct  := .F.

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "A0101"

//nHandle := TCLink( "MSSQL/P12LOCAL", "127.0.0.1", 7890 )

CONOUT(OemToAnsi("Acesso ao banco de dados INTEGRACAO..."))
cQuery := " SELECT * FROM INTEGRACAO.dbo.SC6010 WHERE C6_STLEIT='0' ORDER BY C6_NUM,C6_ITEM"

If Select("MURO")>0
	MURO->(dbCloseArea())
EndIf

TcQuery cQuery NEW Alias "MURO"

	
PREPARE ENVIRONMENT EMPRESA "01" FILIAL MURO->C6_FILIAL
cFilAnt := MURO->C6_FILIAL
		
While !(MURO->(EOF())) .AND. MURO->C6_NUM = cPedido
		
    AADD(aDados,{   MURO->C6_IDINCL,;	
                    fCvDT(MURO->C6_DTCRIA),; 
                    MURO->C6_STLEIT,; 
                    MURO->C6_ACAO,;	
                    MURO->C6_FILIAL,;
                    MURO->C6_CLI,;
                    MURO->C6_LOJACLI,;
                    MURO->C6_TIPOCLI,;
                    MURO->C6_CONDPAG,;
                    MURO->C6_TRANSP,;
                    MURO->C6_TPFRETE,;
                    MURO->C6_PESOL,;
                    MURO->C6_PBRUTO,;
                    MURO->C6_SVOLUME1,;
                    MURO->C6_ESPECI1,;
                    MURO->C6_NATUREZ,;	
                    MURO->C6_NUM,; 
                    MURO->C6_ITEM,;	
                    MURO->C6_PRODUTO,; 
                    MURO->C6_QTDVEN,;
                    MURO->C6_SALPROD,;
                    fCvDT(MURO->C6_ENTREG),;
                    MURO->C6_LOJAENT,;
                    MURO->C6_PEDCLI,;
                    MURO->C6_XSTATUS})

    MURO->(dbSkip())
End

If Len(aDados) > 0
    For nX := 1 to Len(aDados)
        CONOUT(OemToAnsi("Inicio das validações..."))
        If fValida(aDados[nX])
            lContAct := .T.
        Else
            lContAct := .F.    
        EndIf
    Next nX    

    // se validou tudo então processa os dados
    If lContAct
        fAcao(aDados)
    EndIf
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
01-MURO->C6_IDINCL,;	02-fCvDT(MURO->C6_DTCRIA),;    03-MURO->C6_STLEIT,;     04-MURO->C6_ACAO,;	
05-MURO->C6_FILIAL,;    06-MURO->C6_CLI,;              07-MURO->C6_LOJACLI,;    08-MURO->C6_TIPOCLI,;
09-MURO->C6_CONDPAG,;   10-MURO->C6_TRANSP,;           11-MURO->C6_TPFRETE,;    12-MURO->C6_PESOL,;
13-MURO->C6_PBRUTO,;    14-MURO->C6_SVOLUME1,;         15-MURO->C6_ESPECI1,;    16-MURO->C6_NATUREZ,;	
17-MURO->C6_NUM,;       18-MURO->C6_ITEM,;	           19-MURO->C6_PRODUTO,;    20-MURO->C6_QTDVEN,;
21-MURO->C6_SALPROD,;   22-fCvDT(MURO->C6_ENTREG),;    23-MURO->C6_LOJAENT,;    24-MURO->C6_PEDCLI,;
25-MURO->C6_XSTATUS,;
*/
// Valida Filial
If aArray[5] <> xFilial("SC6")
    cMensError += "Erro na origem, filial da Integração difere da filial do Protheus. "+Chr(10)+Chr(13)
    lRet := .F.
EndIf

// Valida se existe a PV
If aArray[4] == '1' // Incluir, não pode existir PV
    dbSelectArea("SC6")
    dbSetOrder(1)
    //ORDEM 1 -> C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO 
    If SC2->(dbSeek(xFilial("SC6")+AllTrim(aArray[17])+Alltrim(aArray[18])+Alltrim(aArray[19])))
        cMensError += "Erro na origem, este número de PV já existe no Protheus, não permite inclusão"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf
ElseIf aArray[4]  == '2'  // Alterar, tem que existir a PV
    dbSelectArea("SC6")
    dbSetOrder(1)
    If !SC2->(dbSeek(xFilial("SC6")+AllTrim(aArray[17])+Alltrim(aArray[18])+Alltrim(aArray[19])))
        cMensError += "Erro na origem, este número de PV não existe no Protheus, não permite Alteração"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf
ElseIf aArray[4] == '3'  // Excluir, tem que existir a PV
    dbSelectArea("SC6")
    dbSetOrder(1)
    If !SC2->(dbSeek(xFilial("SC6")+AllTrim(aArray[17])+Alltrim(aArray[18])+Alltrim(aArray[19])))
        cMensError += "Erro na origem, este número de PV não existe no Protheus, não permite Exclusão"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf    
ElseIf aArray[4] <> '1' .AND. aArray[4] <> '2' .AND. aArray[4] <> '3'
    cMensError += "Erro na origem, ação inválida para operações com PV"+Chr(10)+Chr(13)   
    lRet := .F.
EndIf

// Valida o Produto - Verifica se existe no cadastro de Produtos e se não está bloqueado
dbSelectArea("SB1")
dbSetOrder(1)
//ORDEM 1 -> B1_FILIAL+B1_COD   
If dbSeek(xFilial("SB1")+Alltrim(aArray[19]))
    If SB1->B1_MSBLQL == '1'
        cMensError += "Erro na origem, este produto encontra-se bloquado no sistema Protheus, não será permitido operação com PV"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf
Else
    cMensError += "Erro na origem, este produto não existe no cadastro do Protheus"+Chr(10)+Chr(13)        
    lRet := .F.
EndIf


// Grava o status de leitura e a mensagem do erro
If !lRet
    cQuery := " UPDATE INTEGRACAO.dbo.SC6010 SET C6_STLEIT='2',C6_MENSAG='"+cMensError+"',C6_DTLEIT='"+DTOS(DATE())+"' WHERE C6_IDINCL='"+aArray[1]+"' "
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
Local aCabec  := {} 
Local aItens  := {}
Local aLinha  := {}
Local nRecno := 0
Local cPedido := ""
Local cItemPV := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 3 - Inclusao ³
//³ 4 - Alteracao ³
//³ 5 - Exclusao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nOpc := 0
Local aLog := {}
Local cMensError := ""
Private lMsErroAuto := .F. // variável que define que o help deve ser gravado no arquivo de log e que as informações estão vindo à partir da rotina automática.
Private lMsHelpAuto	:= .T. // força a gravação das informações de erro em array para manipulação da gravação ao invés de gravar direto no arquivo temporário 
Private lAutoErrNoFile := .T.


If aArray[4]=='1'
	nOpc := 3
ElseIf aArray[4]=='2'
	nOpc := 4
ElseIf aArray[4]=='3'
	nOpc := 5
EndIf	

/*
01-MURO->C6_IDINCL,;	02-fCvDT(MURO->C6_DTCRIA),;    03-MURO->C6_STLEIT,;     04-MURO->C6_ACAO,;	
05-MURO->C6_FILIAL,;    06-MURO->C6_CLI,;              07-MURO->C6_LOJACLI,;    08-MURO->C6_TIPOCLI,;
09-MURO->C6_CONDPAG,;   10-MURO->C6_TRANSP,;           11-MURO->C6_TPFRETE,;    12-MURO->C6_PESOL,;
13-MURO->C6_PBRUTO,;    14-MURO->C6_VOLUME1,;          15-MURO->C6_ESPECI1,;    16-MURO->C6_NATUREZ,;	
17-MURO->C6_NUM,;       18-MURO->C6_ITEM,;	           19-MURO->C6_PRODUTO,;    20-MURO->C6_QTDVEN,;
21-MURO->C6_SALPROD,;   22-fCvDT(MURO->C6_ENTREG),;    23-MURO->C6_LOJAENT,;    24-MURO->C6_PEDCLI,;
25-MURO->C6_XSTATUS,;
*/
For nI := 1 to Len(aArray)

    If cPedido <> aArray[nI,17]
        If Len(aCabec) > 0 .and. Len(aItens) > 0 .and. nI < Len(aArray) // Mudou de pedido
            fGeraPV(aCabec, aItens, nOpc)
            aCabec := {}
            aItens := {}
            aLinha := {}
            aCabec := { {'C5_FILIAL',   aArray[nI,4],  Nil},;
                        {'C5_CLIENTE',  aArray[nI,6],  Nil},;
                        {'C5_LOJACLI',  aArray[nI,7],  Nil},;
                        {'C5_TIPOCLI',  aArray[nI,8],  Nil},;
                        {'C5_CONDPAG',  aArray[nI,9],  Nil},;
                        {'C5_TRANSP',   aArray[nI,10], Nil},;
                        {'C5_TPFRETE',  aArray[nI,11], Nil},;
                        {'C5_PESOL',    aArray[nI,12], Nil},;
                        {'C5_PBRUTO',   aArray[nI,13], Nil},;
                        {'C5_NUM',      aArray[nI,17], Nil},;
                        {'C5_VOLUME1',  aArray[nI,14], Nil},;
                        {'C5_ESPECI1',  aArray[nI,15], Nil},;
                        {'C5_TIPO',     "N",           Nil}}
        Else
            aCabec := { {'C5_FILIAL',   aArray[nI,4],  Nil},;
                        {'C5_CLIENTE',  aArray[nI,6],  Nil},;
                        {'C5_LOJACLI',  aArray[nI,7],  Nil},;
                        {'C5_TIPOCLI',  aArray[nI,8],  Nil},;
                        {'C5_CONDPAG',  aArray[nI,9],  Nil},;
                        {'C5_TRANSP',   aArray[nI,10], Nil},;
                        {'C5_TPFRETE',  aArray[nI,11], Nil},;
                        {'C5_PESOL',    aArray[nI,12], Nil},;
                        {'C5_PBRUTO',   aArray[nI,13], Nil},;
                        {'C5_NUM',      aArray[nI,17], Nil},;
                        {'C5_VOLUME1',  aArray[nI,14], Nil},;
                        {'C5_ESPECI1',  aArray[nI,15], Nil},;
                        {'C5_TIPO',     "N",           Nil}}
        EndIf                
        cPedido := aArray[nI,17]
    EndIf    

    If cPedido == aArray[nI,17]
        aLinha := { {'C6_ITEM',     aArray[nI,18],  Nil},;
                    {'C6_PRODUTO',  aArray[nI,13],  Nil},;
                    {'C6_QTDVEN',   aArray[nI,20],  Nil},;
                    {'C6_PRCVEN',   aArray[nI,  ],  Nil},;
                    {'C6_PRUNIT',   aArray[nI,  ],  Nil},;
                    {'C6_VALOR',    aArray[nI,  ],  Nil},;
                    {'C6_TES',      aArray[nI,  ],  Nil}}
        
        aadd(aItens, aLinha)
    EndIf

    
Next nI 
fGeraPV(aCabec, aItens, nOpc)

Return(Nil)


Static Function fGeraPV(aCabec,aItens,nOpc)
ConOut("Inicio : "+Time())
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se alteracao ou exclusao, deve-se posicionar no registro ³
//³ da SC2 antes de executar a rotina automatica ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 4 .Or. nOpc == 5
 SC6->(DbSetOrder(1))//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
 SC6->(DbSeek(xFilial("SC6")+aArray[17]+aArray[18]+aArray[19]))
 nRecno := Recno()
 cPedido := SC6->C6_NUM
 EndIf

MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpc, .F.)

If !lMsErroAuto
 	ConOut("Sucesso! ")
	// Grava o status de leitura
	If lRet
	    cQuery := " UPDATE INTEGRACAO.dbo.SC6010 SET C2_STLEIT='4',C6_DTLEIT='"+DtoS(Date())+"',C6_IDINTE=C6_IDINCL "
	    cQuery += " WHERE C6_IDINCL='"+aArray[1]+"' "
	    nStatus := TcSQLExec(cQuery)
	    If nStatus < 0
	        CONOUT(OemToAnsi("Erro ao atualizar banco INTEGRACAO: ")+TCSqlError())
	    EndIf	
	EndIf
Else
    ConOut("Erro!")
    //MostraErro()
    aLog := GetAutoGRLog()
    // Procurar a linha com o erro no array < -- Invalido
    nPosErro := 0
    For nE := 1 to Len(aLog)
    	If AT("< -- Invalido",aLog[nE]) > 0
    		nPosErro := nE
    	EndIf
    Next nE
    
    If nPosErro > 0
    	cMensError := "Erro no destino, "+aLog[nPosErro]+" | "+aLog[1]
    Else
    	cMensError := "Erro no destino, não consegui identificar o erro."+" | "+aLog[1]	
    EndIf
    
    cQuery := " UPDATE INTEGRACAO.dbo.SC6010 SET C6_STLEIT='3',C6_MENSAG='"+cMensError+"',C6_DTLEIT='"+DTOS(DATE())+"',C6_IDINTE='"+aArray[1]+"' WHERE C6_IDINCL='"+aArray[1]+"' "
    nStatus := TcSQLExec(cQuery)
    lRet := .F.
    
    CONOUT(cMensError)
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