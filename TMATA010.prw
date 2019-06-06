#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"


User Function TMata010()
Local aDados := {}
Local cQuery := {}
private lMsErroAuto := .F.
 
CONOUT(OemToAnsi("Acesso ao banco de dados INTEGRACAO..."))
cQuery := " SELECT B1_IDINCL,B1_IDINTE,B1_DTCRIA,B1_DTLEIT,B1_STLEIT,B1_MENSAG,B1_ACAO,B1_FILIAL,B1_COD,B1_DESC, "
cQuery += " B1_TIPO,B1_UM,B1_LOCPAD,B1_GRUPO,B1_IPI,B1_POSIPI,B1_PESO,B1_QB,B1_ORIGEM,B1_RASTRO,B1_GRTRIB,B1_ATIVO, "
cQuery += " B1_GARANT,B1_XCTCUST,B1_XCTDESP,B1_XCTRECE,B1_XRECEST,B1_XRECINT,B1_XESTRUR "
cQuery += " FROM INTEGRACAO.dbo.SB1010 WHERE B1_STLEIT='0' "
 
If Select("MURO")>0
	MURO->(dbCloseArea())
EndIf

TcQuery cQuery NEW Alias "MURO"

	
PREPARE ENVIRONMENT EMPRESA "01" FILIAL MURO->B1_FILIAL

While !(MURO->(EOF()))

/*
B1_IDINCL,B1_IDINTE,B1_DTCRIA,B1_DTLEIT,B1_STLEIT,B1_MENSAG,B1_ACAO,B1_FILIAL,B1_COD,B1_DESC,B1_TIPO,B1_UM,
B1_LOCPAD,B1_GRUPO,B1_IPI,B1_POSIPI,B1_PESO,B1_QB,B1_ORIGEM,B1_RASTRO,B1_GRTRIB,B1_ATIVO,B1_GARANT,B1_XCTCUST,
B1_XCTDESP,B1_XCTRECE,B1_XRECEST,B1_XRECINT,B1_XESTRUR
*/
		
    AADD(aDados,{   MURO->B1_IDINCL,;	
                    fCvDT(MURO->B1_DTCRIA),; 
                    MURO->B1_STLEIT,; 
                    MURO->B1_ACAO,;	
                    MURO->B1_FILIAL,;
                    MURO->B1_COD,;
                    MURO->B1_DESC,;
                    MURO->B1_TIPO,;
                    MURO->B1_UM,;
                    MURO->B1_LOCPAD,;
                    MURO->B1_GRUPO,;
                    MURO->B1_IPI,;
                    MURO->B1_POSIPI,;
                    MURO->B1_PESO,;
                    MURO->B1_QB,;
                    MURO->B1_ORIGEM,;	
                    MURO->B1_RASTRO,; 
                    MURO->B1_GRTRIB,;	
                    MURO->B1_ATIVO,; 
                    MURO->B1_GARANT,;
                    MURO->B1_XCTCUST,;
                    MURO->B1_XCTDESP,;
                    MURO->B1_XCTRECE,;
                    MURO->B1_XRECEST,;
                    MURO->B1_XRECINT,;
                    MURO->B1_XESTRUR})

    MURO->(dbSkip())
End

If Len(aDados) > 0
    For nX := 1 to Len(aDados)
        CONOUT(OemToAnsi("Inicio das validações..."))
        If fValida(aDados[nX])
            fAcao(aDados)
        EndIf
    Next nX    

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
01-B1_IDINCL,       02-B1_IDINTE,          03-B1_DTCRIA,            04-B1_DTLEIT,        05-B1_STLEIT,
06-B1_MENSAG,       07-B1_ACAO,            08-B1_FILIAL,            09-B1_COD,           10-B1_DESC,
11-B1_TIPO,         12-B1_UM,              13-B1_LOCPAD,            14-B1_GRUPO,         15-B1_IPI,
16-B1_POSIPI,       17-B1_PESO,            18-B1_QB,                19-B1_ORIGEM,        20-B1_RASTRO,
21-B1_GRTRIB,       22-B1_ATIVO,           23-B1_GARANT,            24-B1_XCTCUST,       25-B1_XCTDESP,
26-B1_XCTRECE,      27-B1_XRECEST,         28-B1_XRECINT,           29-B1_XESTRUR       
*/
// Valida Filial
If aArray[8] <> xFilial("SB1")
    cMensError += "Erro na origem, filial da Integração difere da filial do Protheus. "+Chr(10)+Chr(13)
    lRet := .F.
EndIf

// Valida se existe o Produto
If aArray[7] == '1' // Incluir, não pode existir o código do produto
    dbSelectArea("SB1")
    dbSetOrder(1)
    //ORDEM 1 -> B1_FILIAL+B1_COD 
    If SB1->(dbSeek(xFilial("SB1")+AllTrim(aArray[9])))
        cMensError += "Erro na origem, este código de produto já existe no Protheus, não permite inclusão"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf
ElseIf aArray[7]  == '2'  // Alterar, tem que existir o produto
    dbSelectArea("SB1")
    dbSetOrder(1)
    If !SB1->(dbSeek(xFilial("SB1")+AllTrim(aArray[9])))
        cMensError += "Erro na origem, este código de produto não existe no Protheus, não permite Alteração"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf
ElseIf aArray[7] == '3'  // Excluir, tem que existir o produto
    dbSelectArea("SB1")
    dbSetOrder(1)
    If !SB1->(dbSeek(xFilial("SB1")+AllTrim(aArray[9])))
        cMensError += "Erro na origem, este código de produto não existe no Protheus, não permite Exclusão"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf    
ElseIf aArray[7] <> '1' .AND. aArray[7] <> '2' .AND. aArray[7] <> '3'
    cMensError += "Erro na origem, ação inválida para operações com cadastro de produtos"+Chr(10)+Chr(13)   
    lRet := .F.
EndIf

// Grava o status de leitura e a mensagem do erro
If !lRet
    cQuery := " UPDATE INTEGRACAO.dbo.SB1010 SET B1_STLEIT='2',B1_MENSAG='"+cMensError+"',B1_DTLEIT='"+DTOS(DATE())+"' WHERE B1_IDINCL='"+aArray[1]+"' "
    nStatus := TcSQLExec(cQuery)
    If nStatus < 0
        CONOUT(OemToAnsi("Erro ao atualizar banco INTEGRACAO: ")+TCSqlError())
    EndIf
EndIf

Return(lRet)


/*/{Protheus.doc} fAcao
    Executa a ação no cadastro de Produto (Inclusão, Alteração ou Exclusão)
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
Local aDados  := {} 
Local nRecno := 0

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


If aArray[7]=='1'
	nOpc := 3
ElseIf aArray[7]=='2'
	nOpc := 4
ElseIf aArray[7]=='3'
	nOpc := 5
EndIf	

/*
01-B1_IDINCL,       02-B1_IDINTE,          03-B1_DTCRIA,            04-B1_DTLEIT,        05-B1_STLEIT,
06-B1_MENSAG,       07-B1_ACAO,            08-B1_FILIAL,            09-B1_COD,           10-B1_DESC,
11-B1_TIPO,         12-B1_UM,              13-B1_LOCPAD,            14-B1_GRUPO,         15-B1_IPI,
16-B1_POSIPI,       17-B1_PESO,            18-B1_QB,                19-B1_ORIGEM,        20-B1_RASTRO,
21-B1_GRTRIB,       22-B1_ATIVO,           23-B1_GARANT,            24-B1_XCTCUST,       25-B1_XCTDESP,
26-B1_XCTRECE,      27-B1_XRECEST,         28-B1_XRECINT,           29-B1_XESTRUR       
*/

    aDados:=    {   {"B1_FILIAL",   aArray[8],      NIL},;
                    {"B1_COD",      aArray[9],      NIL},;
                    {"B1_DESC",     aArray[10],     NIL},;
                    {"B1_TIPO",     aArray[11],     Nil},;
                    {"B1_UM",       aArray[12],     Nil},;
                    {"B1_LOCPAD",   aArray[13],     Nil},;
                    {"B1_GRUPO",    aArray[14],     Nil},;
                    {"B1_IPI",      aArray[15],     Nil},;
                    {"B1_POSIPI",   aArray[16],     Nil},;
                    {"B1_PESO",     aArray[17],     Nil},;
                    {"B1_QB",       aArray[18],     Nil},;
                    {"B1_ORIGEM",   aArray[19],     Nil},;
                    {"B1_RASTRO",   aArray[20],     Nil},;
                    {"B1_GRTRIB",   aArray[21],     Nil},;
                    {"B1_ATIVO",    aArray[22],     Nil},;
                    {"B1_GARANT",   aArray[23],     Nil},;
                    {"B1_XCTCUST",  aArray[24],     Nil},;
                    {"B1_XCTDESP",  aArray[25],     Nil},;
                    {"B1_XCTRECE",  aArray[26],     Nil},;
                    {"B1_XRECEST",  aArray[27],     Nil},;
                    {"B1_XRECINT",  aArray[28],     Nil},;
                    {"B1_XESTRUR",  aArray[29],     Nil}}
  
ConOut("Inicio : "+Time())
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se alteracao ou exclusao, deve-se posicionar no registro ³
//³ da SC2 antes de executar a rotina automatica ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 4 .Or. nOpc == 5
    SB1->(DbSetOrder(1))//B1_FILIAL+B1_COD
    SB1->(DbSeek(xFilial("SB1")+aArray[9]
    nRecno := Recno() 
EndIf

MSExecAuto({|x,y| Mata010(x,y)},aDados,nOpc)

If !lMsErroAuto
 	ConOut("Sucesso! ")
	// Grava o status de leitura
	If lRet
	    cQuery := " UPDATE INTEGRACAO.dbo.SB1010 SET B1_STLEIT='4',B1_DTLEIT='"+DtoS(Date())+"',B1_IDINTE=B1_IDINCL "
	    cQuery += " WHERE B1_IDINCL='"+aArray[1]+"' "
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
    
    cQuery := " UPDATE INTEGRACAO.dbo.SB1010 SET B1_STLEIT='3',B1_MENSAG='"+cMensError+"',B1_DTLEIT='"+DTOS(DATE())+"',B1_IDINTE='"+aArray[1]+"' WHERE B1_IDINCL='"+aArray[1]+"' "
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