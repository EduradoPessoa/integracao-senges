#include "protheus.ch"

User Function MT410TOK()
Local lRet := .T.

If U_GRAVAPV()
    lRet := .T.
EndIf

Return(lRet)