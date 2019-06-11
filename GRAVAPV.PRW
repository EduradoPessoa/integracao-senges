#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

User Function GravaPV()
Local lRet    := .F.
Local aHeader := {}
Local cHeader := ""
Local cDados  := ""

// Campos da INTEGRACAO
Aadd(aHeader,{'C6_IDINCL'})
Aadd(aHeader,{'C6_IDINTE'})
Aadd(aHeader,{'C6_DTCRIA'})
Aadd(aHeader,{'C6_DTLEIT'})
Aadd(aHeader,{'C6_STLEIT'})
Aadd(aHeader,{'C6_MENSAG'})
Aadd(aHeader,{'C6_ACAO'})
Aadd(aHeader,{'C6_FILIAL'})
Aadd(aHeader,{'C6_ITEM'})	
Aadd(aHeader,{'C6_PRODUTO'})
Aadd(aHeader,{'C6_QTDVEN'})
Aadd(aHeader,{'C6_SALPROD'})
Aadd(aHeader,{'C6_CLI'})	
Aadd(aHeader,{'C6_ENTREG'})
Aadd(aHeader,{'C6_LOJA'})	
Aadd(aHeader,{'A1_NOME'})	
Aadd(aHeader,{'A1_NREDUZ'})
Aadd(aHeader,{'C5_TPFRETE'})
Aadd(aHeader,{'C5_LOJAENT'})
Aadd(aHeader,{'C6_PEDCLI'})
Aadd(aHeader,{'C6_XSTATUS'})
Aadd(aHeader,{'C5_NUM'})	
Aadd(aHeader,{'C5_TRANSP'})
Aadd(aHeader,{'C5_PESOL'})
Aadd(aHeader,{'C5_PBRUTO'})
Aadd(aHeader,{'C5_VOLUME1'})
Aadd(aHeader,{'C5_ESPECI1'})

For Ix := 8 to Len aHeader
    If !Empty(&("M->"+aHeader[Ix]))
        cHeader += ','+aHeader[Ix]
        cDados += ','+&("M->"+aHeader[Ix])
    EndIf
Next Ix
Alert(cHeader+CLRF+cDados)
Return()

