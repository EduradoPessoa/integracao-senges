#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"


User Function TMata250()
Local aDados := {}
Local cQuery := {}
private lMsErroAuto := .F.
 
CONOUT(OemToAnsi("Acesso ao banco de dados INTEGRACAO..."))
cQuery := " SELECT D3_IDINCL,D3_IDINTE,D3_DTCRIA,D3_DTLEIT,D3_STLEIT,D3_MENSAG,D3_ACAO,D3_FILIAL,D3_TM, "
cQuery += " D3_COD,D3_UM,D3_QUANT,D3_OP,D3_LOCAL,D3_DOC,D3_EMISSAO,D3_GRUPO,D3_CC,D3_PARCTOT,D3_TIPO, "
cQuery += " D3_USUARIO,D3_DESCRI,D3_LOTECTL,D3_DTVALID,D3_ITEMCTA "
cQuery += " FROM INTEGRACAO.dbo.SD3010 WHERE D3_STLEIT='0' "
 
If Select("MURO")>0
	MURO->(dbCloseArea())
EndIf

TcQuery cQuery NEW Alias "MURO"

	
PREPARE ENVIRONMENT EMPRESA "01" FILIAL MURO->B1_FILIAL

While !(MURO->(EOF()))

/*
D3_IDINCL,D3_IDINTE,D3_DTCRIA,D3_DTLEIT,D3_STLEIT,D3_MENSAG,D3_ACAO,D3_FILIAL,D3_TM,D3_COD,D3_UM,D3_QUANT,
D3_OP,D3_LOCAL,D3_DOC,D3_EMISSAO,D3_GRUPO,D3_CC,D3_PARCTOT,D3_TIPO,D3_USUARIO,D3_DESCRI,D3_LOTECTL,D3_DTVALID,
D3_ITEMCTA
*/
	
    AADD(aDados,{   MURO->D3_IDINCL,;	
                    fCvDT(MURO->B1_DTCRIA),; 
                    MURO->D3_STLEIT,; 
                    MURO->D3_ACAO,;	
                    MURO->D3_FILIAL,;
                    MURO->D3_TM,;
                    MURO->D3_COD,;
                    MURO->D3_UM,;
                    MURO->D3_QUANT,;
                    MURO->D3_OP,;
                    MURO->D3_LOCAL,;
                    MURO->D3_DOC,;
                    fCvDT(MURO->D3_EMISSAO),;
                    MURO->D3_GRUPO,;
                    MURO->D3_CC,;
                    MURO->D3_PARCTOT,;	
                    MURO->D3_TIPO,; 
                    MURO->D3_USUARIO,;	
                    MURO->D3_DESCRI,; 
                    MURO->D3_LOTECTL,;
                    fCvDT(MURO->D3_DTVALID),;
                    MURO->D3_ITEMCTA})

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
01-D3_IDINCL,         02-D3_IDINTE,          03-D3_DTCRIA,          04-D3_DTLEIT,          05-D3_STLEIT,
06-D3_MENSAG,         07-D3_ACAO,            08-D3_FILIAL,          09-D3_TM,              10-D3_COD,
11-D3_UM,             12-D3_QUANT,           13-D3_OP,              14-D3_LOCAL,           15-D3_DOC,
16-D3_EMISSAO,        17-D3_GRUPO,           18-D3_CC,              19-D3_PARCTOT,         20-D3_TIPO,
21-D3_USUARIO,        22-D3_DESCRI,          23-D3_LOTECTL,         24-D3_DTVALID,         25-D3_ITEMCTA
*/
// Valida Filial
If aArray[8] <> xFilial("SD3")
    cMensError += "Erro na origem, filial da Integração difere da filial do Protheus. "+Chr(10)+Chr(13)
    lRet := .F.
EndIf

// Valida se existe o movimento de Produção
If aArray[7] == '1' // Incluir, não pode existir o movimento de produção
    dbSelectArea("SD3")
    dbSetOrder(1)
    //ORDEM 1 -> D3_FILIAL+D3_OP+D3_COD+D3_LOCAL   
    If SD3->(dbSeek(xFilial("SD3")+AllTrim(aArray[13])+AllTrim(aArray[10])+AllTrim(aArray[14])))
        cMensError += "Erro na origem, este movimento de produção já existe no Protheus, não permite inclusão"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf
ElseIf aArray[7]  == '2'  // Alterar, tem que existir o movimento de Produção
    dbSelectArea("SD3")
    dbSetOrder(1) //D3_FILIAL+D3_OP+D3_COD+D3_LOCAL
    If !SD3->(dbSeek(xFilial("SD3")+AllTrim(aArray[13])+AllTrim(aArray[10])+AllTrim(aArray[14])))
        cMensError += "Erro na origem, este movimento de Produção não existe no Protheus, não permite Alteração"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf
ElseIf aArray[7] == '3'  // Excluir, tem que existir o movimento de Produção
    dbSelectArea("SD3")
    dbSetOrder(1)  //D3_FILIAL+D3_OP+D3_COD+D3_LOCAL
    If !SB1->(dbSeek(xFilial("SD3")+AllTrim(aArray[13])+AllTrim(aArray[10])+AllTrim(aArray[14])))
        cMensError += "Erro na origem, este movimento de Produção não existe no Protheus, não permite Exclusão"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf    
ElseIf aArray[7] <> '1' .AND. aArray[7] <> '2' .AND. aArray[7] <> '3'
    cMensError += "Erro na origem, ação inválida para operações com movimento de Produção"+Chr(10)+Chr(13)   
    lRet := .F.
EndIf

// Valida o Produto - Verifica se existe no cadastro de Produtos e se não está bloqueado
dbSelectArea("SB1")
dbSetOrder(1)
//ORDEM 1 -> B1_FILIAL+B1_COD   
If dbSeek(xFilial("SB1")+Alltrim(aArray[10]))
    If SB1->B1_MSBLQL == '1'
        cMensError += "Erro na origem, este produto encontra-se bloquado no sistema Protheus, não será permitido apontamento de Produção"+Chr(10)+Chr(13)
        lRet := .F.
    EndIf
Else
    cMensError += "Erro na origem, este produto não existe no cadastro do Protheus"+Chr(10)+Chr(13)        
    lRet := .F.
EndIf

// Grava o status de leitura e a mensagem do erro
If !lRet
    cQuery := " UPDATE INTEGRACAO.dbo.SD3010 SET D3_STLEIT='2',D3_MENSAG='"+cMensError+"',D3_DTLEIT='"+DTOS(DATE())+"' WHERE D3_IDINCL='"+aArray[1]+"' "
    nStatus := TcSQLExec(cQuery)
    If nStatus < 0
        CONOUT(OemToAnsi("Erro ao atualizar banco INTEGRACAO: ")+TCSqlError())
    EndIf
EndIf

Return(lRet)


/*/{Protheus.doc} fAcao
    Executa a ação no apontamento de Produção (Inclusão, Alteração ou Exclusão)
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
01-D3_IDINCL,         02-D3_IDINTE,          03-D3_DTCRIA,          04-D3_DTLEIT,          05-D3_STLEIT,
06-D3_MENSAG,         07-D3_ACAO,            08-D3_FILIAL,          09-D3_TM,              10-D3_COD,
11-D3_UM,             12-D3_QUANT,           13-D3_OP,              14-D3_LOCAL,           15-D3_DOC,
16-D3_EMISSAO,        17-D3_GRUPO,           18-D3_CC,              19-D3_PARCTOT,         20-D3_TIPO,
21-D3_USUARIO,        22-D3_DESCRI,          23-D3_LOTECTL,         24-D3_DTVALID,         25-D3_ITEMCTA
*/

    aDados:=    {   {"D3_FILIAL",   aArray[8],      NIL},;
                    {"D3_TM",       aArray[9],      NIL},;
                    {"D3_COD",      aArray[10],     NIL},;
                    {"D3_UM",       aArray[11],     Nil},;
                    {"D3_QUANT",    aArray[12],     Nil},;
                    {"D3_OP",       aArray[13],     Nil},;
                    {"D3_LOCAL",    aArray[14],     Nil},;
                    {"D3_DOC",      aArray[15],     Nil},;
                    {"D3_EMISSAO",  aArray[16],     Nil},;
                    {"D3_GRUPO",    aArray[17],     Nil},;
                    {"D3_CC",       aArray[18],     Nil},;
                    {"D3_PARCTOT",  "P",            Nil},;
                    {"D3_TIPO",     aArray[20],     Nil},;
                    {"D3_USUARIO",  aArray[21],     Nil},;
                    {"D3_DESCRI",   aArray[22],     Nil},;
                    {"D3_LOTECTL",  aArray[23],     Nil},;
                    {"D3_DTVALID",  aArray[24],     Nil},;
                    {"D3_ITEMCTA",  aArray[25],     Nil}}
  
ConOut("Inicio : "+Time())
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se alteracao ou exclusao, deve-se posicionar no registro ³
//³ da SD3 antes de executar a rotina automatica ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 4 .Or. nOpc == 5
    SD3->(DbSetOrder(1))//D3_FILIAL+D3_OP+D3_COD+D3_LOCAL
    SD3->(DbSeek(xFilial("SD3")+AllTrim(aArray[13])+AllTrim(aArray[10])+AllTrim(aArray[14])))
    nRecno := Recno() 
EndIf

MSExecAuto({|x, y| mata250(x, y)},aDados, nOpc ) 

If !lMsErroAuto
 	ConOut("Sucesso! ")
	// Grava o status de leitura
	If lRet
	    cQuery := " UPDATE INTEGRACAO.dbo.SD3010 SET D3_STLEIT='4',D3_DTLEIT='"+DtoS(Date())+"',D3_IDINTE=D3_IDINCL "
	    cQuery += " WHERE D3_IDINCL='"+aArray[1]+"' "
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
    
    cQuery := " UPDATE INTEGRACAO.dbo.SD3010 SET D3_STLEIT='3',D3_MENSAG='"+cMensError+"',D3_DTLEIT='"+DTOS(DATE())+"',D3_IDINTE='"+aArray[1]+"' WHERE D3_IDINCL='"+aArray[1]+"' "
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