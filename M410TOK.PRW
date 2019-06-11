#include "protheus.ch"

User Function M410TOK()
Local lRet := .F.

If U_GRAVAPV()
    lRet := .T.
EndIf

Return(lRet)