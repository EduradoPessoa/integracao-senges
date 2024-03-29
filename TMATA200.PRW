#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"


User Function TMata200()
Local PARAMIXB1 := {}
Local PARAMIXB2 := {}
Local aGets     := {}
Local lOK       := .T.
Local lContAct  := .F.
Local cString   := ""

Private lMsErroAuto := .F.


CONOUT(OemToAnsi("Acesso ao banco de dados INTEGRACAO..."))
cQuery := " SELECT G1_IDINCL,G1_IDINTE,G1_DTCRIA,G1_DTLEIT,G1_STLEIT,G1_MENSAG,G1_ACAO,G1_FILIAL,G1_COD, "
CqUERY += " G1_COMP,G1_TRT,G1_QUANT,G1_PERDA,G1_INI,G1_FIM,G1_GROPC,G1_OPC,G1_REVINI,G1_REVFIM,G1_NIV"
cQuery += " FROM INTEGRACAO.dbo.SG1010 WHERE G1_STLEIT='0' ORDER BY G1_FILIAL,G1_COD,G1_COMP"
 
If Select("MURO")>0
	MURO->(dbCloseArea())
EndIf

TcQuery cQuery NEW Alias "MURO"

	
PREPARE ENVIRONMENT EMPRESA "01" FILIAL MURO->G1_FILIAL MODULO "PCP" TABLES "SB1","SG1","SG5"
/*
01-G1_IDINCL,       02-G1_IDINTE,         03-G1_DTCRIA,          04-G1_DTLEIT,         05-G1_STLEIT,
06-G1_MENSAG,       07-G1_ACAO,           08-G1_FILIAL,          09-G1_COD,            10-G1_COMP,
11-G1_TRT,          12-G1_QUANT,          13-G1_PERDA,           14-G1_INI,            15-G1_FIM,
16-G1_GROPC,        17-G1_OPC,            18-G1_REVINI,          19-G1_REVFIM,         20-G1_NIV
*/
While !(MURO->(EOF()))
		
    AADD(aDados,{   MURO->G1_IDINCL,;	
                    fCvDT(MURO->G1_DTCRIA),; 
                    MURO->G1_STLEIT,; 
                    MURO->G1_ACAO,;	
                    MURO->G1_FILIAL,;
                    MURO->G1_COD,;
                    MURO->G1_COMP,;
                    MURO->G1_TRT,;
                    MURO->G1_QUANT,;
                    MURO->G1_PERDA,;
                    fCvDT(MURO->G1_INI),;
                    fCvDT(MURO->G1_FIM),;
                    MURO->G1_GROPC,;
                    MURO->G1_OPC,;
                    MURO->G1_REVINI,;
                    MURO->G1_REVFIM,;	
                    MURO->G1_NIV})

    MURO->(dbSkip())
End

If Len(aDados) > 0
    For nX := 1 to Len(aDados)
        CONOUT(OemToAnsi("Inicio das valida��es..."))
        If fValida(aDados[nX])
            lContAct := .T.
        Else
            lContAct := .F.    
        EndIf
    Next nX    

    // se validou tudo ent�o processa os dados
    If lContAct
        fAcao(aDados)
    EndIf
EndIf

 
RESET ENVIRONMENT
 
Return Nil

/*/{Protheus.doc} fValida
    Fun��o para valida��o dos dados
    @type  Static Function
    @author Eduardo Pesssoa
    @since 20/05/2019
    @version 1.0
    @param aDados, array, dados da Integra��o
    @return lRet, boolean, Quando passar por todas as valida��es retorna True
    @example
    N�o se aplica
    @see Documentos da Integra��o Seng�s
/*/
Static Function fValida(aArray)
Local lRet       := .T.
Local cMensError := ""
Local cQuery     := ""
Local nStatus    := 0

/*
01-G1_IDINCL,       02-G1_IDINTE,         03-G1_DTCRIA,          04-G1_DTLEIT,         05-G1_STLEIT,
06-G1_MENSAG,       07-G1_ACAO,           08-G1_FILIAL,          09-G1_COD,            10-G1_COMP,
11-G1_TRT,          12-G1_QUANT,          13-G1_PERDA,           14-G1_INI,            15-G1_FIM,
16-G1_GROPC,        17-G1_OPC,            18-G1_REVINI,          19-G1_REVFIM,         20-G1_NIV
*/
// Valida Filial
If aArray[8] <> xFilial("SG1")
    cMensError += "Erro na origem, filial da Integra��o difere da filial do Protheus. "+Chr(10)+Chr(13)
    lRet := .F.
EndIf

// Valida se existe a Estrutura
If aArray[7] == '1' // Incluir, n�o pode existir a Estrutura
    dbSelectArea("SG1")
    dbSetOrder(1)
    //ORDEM 1 -> G1_FILIAL+G1_COD+G1_COMP+G1_TRT   
    If SG1->(dbSeek(xFilial("SG1")+AllTrim(aArray[9])+Alltrim(aArray[10])+Alltrim(aArray[11])))
        cMensError += "Erro na origem, esta estrutura j� existe no Protheus, n�o permite inclus�o"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf
ElseIf aArray[7]  == '2'  // Alterar, tem que existir a estrutura
    dbSelectArea("SG1")
    dbSetOrder(1)
    If !SG1->(dbSeek(xFilial("SG1")+AllTrim(aArray[9])+Alltrim(aArray[10])+Alltrim(aArray[11])))
        cMensError += "Erro na origem, esta estrutura n�o existe no Protheus, n�o permite Altera��o"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf
ElseIf aArray[7] == '3'  // Excluir, tem que existir a PV
    dbSelectArea("SG1")
    dbSetOrder(1)
    If !SG1->(dbSeek(xFilial("SG1")+AllTrim(aArray[9])+Alltrim(aArray[10])+Alltrim(aArray[11])))
        cMensError += "Erro na origem, esta estrutura n�o existe no Protheus, n�o permite Exclus�o"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf    
ElseIf aArray[7] <> '1' .AND. aArray[7] <> '2' .AND. aArray[7] <> '3'
    cMensError += "Erro na origem, a��o inv�lida para opera��es com cadastro de estruturas"+Chr(10)+Chr(13)   
    lRet := .F.
EndIf

// Valida o Produto - Verifica se existe no cadastro de Produtos e se n�o est� bloqueado
dbSelectArea("SB1")
dbSetOrder(1)
//ORDEM 1 -> B1_FILIAL+B1_COD   
If dbSeek(xFilial("SB1")+Alltrim(aArray[9]))
    If SB1->B1_MSBLQL == '1'
        cMensError += "Erro na origem, este produto encontra-se bloquado no sistema Protheus, n�o ser� permitido opera��o com cadastro de estrutura"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf
Else
    cMensError += "Erro na origem, este produto n�o existe no cadastro do Protheus"+Chr(10)+Chr(13)        
    lRet := .F.
EndIf

// Valida o componente - Verifica se existe no cadastro de Produtos e se n�o est� bloqueado
dbSelectArea("SB1")
dbSetOrder(1)
//ORDEM 1 -> B1_FILIAL+B1_COD   
If dbSeek(xFilial("SB1")+Alltrim(aArray[10]))
    If SB1->B1_MSBLQL == '1'
        cMensError += "Erro na origem, este componente encontra-se bloquado no sistema Protheus, n�o ser� permitido opera��o com cadastro de estrutura"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf
Else
    cMensError += "Erro na origem, este componente n�o existe no cadastro do Protheus"+Chr(10)+Chr(13)        
    lRet := .F.
EndIf


// Grava o status de leitura e a mensagem do erro
If !lRet
    cQuery := " UPDATE INTEGRACAO.dbo.SG1010 SET G1_STLEIT='2',G1_MENSAG='"+cMensError+"',G1_DTLEIT='"+DTOS(DATE())+"' WHERE G1_IDINCL='"+aArray[1]+"' "
    nStatus := TcSQLExec(cQuery)
    If nStatus < 0
        CONOUT(OemToAnsi("Erro ao atualizar banco INTEGRACAO: ")+TCSqlError())
    EndIf
EndIf

Return(lRet)

/*/{Protheus.doc} fAcao
    Executa a a��o no cadastro de Estrutura (Inclus�o, Altera��o ou Exclus�o)
    @type  Static Function
    @author Eduardo Pessoa
    @since 20/05/2019
    @version 1.0
    @param aDados, Array, Array com dados da tabela muro para integra��o
    @return lRet, boolean, Indica se a integra��o ocorreu com sucesso
    @example
    N�o se aplica
    @see Documentos de integra��o
/*/
Static Function fAcao(aArray)
Local lRet := .T.
Local aCabec  := {} 
Local aItens  := {}
Local aLinha  := {}
Local nRecno := 0


//������������������Ŀ
//� 3 - Inclusao �
//� 4 - Alteracao �
//� 5 - Exclusao �
//��������������������
Local nOpc := 0
Local aLog := {}
Local cMensError := ""
Private lMsErroAuto := .F. // vari�vel que define que o help deve ser gravado no arquivo de log e que as informa��es est�o vindo � partir da rotina autom�tica.
Private lMsHelpAuto	:= .T. // for�a a grava��o das informa��es de erro em array para manipula��o da grava��o ao inv�s de gravar direto no arquivo tempor�rio 
Private lAutoErrNoFile := .T.


If aArray[4]=='1'
	nOpc := 3
ElseIf aArray[4]=='2'
	nOpc := 4
ElseIf aArray[4]=='3'
	nOpc := 5
EndIf	

/*
01-G1_IDINCL,       02-G1_IDINTE,         03-G1_DTCRIA,          04-G1_DTLEIT,         05-G1_STLEIT,
06-G1_MENSAG,       07-G1_ACAO,           08-G1_FILIAL,          09-G1_COD,            10-G1_COMP,
11-G1_TRT,          12-G1_QUANT,          13-G1_PERDA,           14-G1_INI,            15-G1_FIM,
16-G1_GROPC,        17-G1_OPC,            18-G1_REVINI,          19-G1_REVFIM,         20-G1_NIV
*/
For nI := 1 to Len(aArray)

    If cProduto <> aArray[nI,9]
        If Len(aCabec) > 0 .and. Len(aItens) > 0 .and. nI < Len(aArray) // Mudou de pedido
            fGeraG1(aCabec, aItens, nOpc)
            aCabec := {}
            aItens := {}
            aLinha := {}

            aCabec := { {'G1_FILIAL',   aArray[nI,8],  Nil},;
                        {'G1_COD',      aArray[nI,9],  Nil},;
                        {'G1_QUANT',    aArray[nI,12], Nil},;
                        {'G1_NICALT',   "S",           Nil}}
        Else
            aCabec := { {'G1_FILIAL',   aArray[nI,8],  Nil},;
                        {'G1_COD',      aArray[nI,9],  Nil},;
                        {'G1_QUANT',    aArray[nI,12], Nil},;
                        {'G1_NICALT',   "S",           Nil}}
        EndIf                
        cProduto := aArray[nI,9]
    EndIf    

    If cPedido == aArray[nI,9]
        aLinha := {}
        aLinha := { {'G1_COD',      aArray[nI,9],   Nil},;
                    {'G1_COMP',     aArray[nI,10],  Nil},;
                    {'G1_TRT',      aArray[nI,11],  Nil},;
                    {'G1_QUANT',    aArray[nI,12],  Nil},;
                    {'G1_PERDA',    aArray[nI,13],  Nil},;
                    {'G1_INI',      aArray[nI,14],  Nil},;
                    {'G1_FIM',      aArray[nI,15],  Nil}}
        aadd(aItens, aLinha)
    EndIf

    
Next nI 
fGeraG1(aCabec, aItens, nOpc)

Return(Nil)


Static Function fGeraG1(PARAMIXB1,PARAMIXB2,PARAMIXB3)
ConOut("Inicio : "+Time())
 
//��������������������������������������������������������������Ŀ
//� Se alteracao ou exclusao, deve-se posicionar no registro �
//� da SG1 antes de executar a rotina automatica �
//����������������������������������������������������������������
If PARAMIXB3 == 4 .Or. PARAMIXB3 == 5
    SG1->(DbSetOrder(1))//G1_FILIAL+G1_COD+G1_COMP+G1_TRT
    SG1->(DbSeek(xFilial("SG1")+aArray[9]+aArray[10]+aArray[11]))
    nRecno := Recno()
EndIf

MSExecAuto({|x,y,z| mata200(x,y,z)},PARAMIXB1,PARAMIXB2,PARAMIXB3)

If !lMsErroAuto
 	ConOut("Sucesso! ")
	// Grava o status de leitura
	If lRet
	    cQuery := " UPDATE INTEGRACAO.dbo.SG1010 SET G1_STLEIT='4',G1_DTLEIT='"+DtoS(Date())+"',G1_IDINTE=G1_IDINCL "
	    cQuery += " WHERE G1_IDINCL='"+aArray[1]+"' "
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
    	cMensError := "Erro no destino, n�o consegui identificar o erro."+" | "+aLog[1]	
    EndIf
    
    cQuery := " UPDATE INTEGRACAO.dbo.SG1010 SET G1_STLEIT='3',G1_MENSAG='"+cMensError+"',G1_DTLEIT='"+DTOS(DATE())+"',G1_IDINTE='"+aArray[1]+"' WHERE G1_IDINCL='"+aArray[1]+"' "
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