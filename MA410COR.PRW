User Function MA410COR()
Local aCores := PARAMIXB

aAdd(aCores,{"Empty(C5_LIBEROK).And.Empty(C5_NOTA) .And. Empty(C5_BLQ) .And. C5_X_CONF = 'S' .AND. C5_XSTATUS=='I'",'ENABLE','Pedido em Aberto' })		//Pedido em Aberto
aAdd(aCores,{"!Empty(C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ) .AND. C5_XSTATUS=='E'" ,'DISABLE','Pedido Encerrado'})		   	//Pedido Encerrado
aAdd(aCores,{"!Empty(C5_LIBEROK).And.C5_XSTATUS=='T'",'BR_AMARELO','Integrado TRIM'})
aAdd(aCores,{"C5_BLQ == '1'",'BR_AZUL','Pedido Bloquedo por regra'}) //Pedido Bloquedo por regra
aAdd(aCores,{"C5_BLQ == '2'",'BR_LARANJA','Pedido Bloquedo por verba'})	//Pedido Bloquedo por verba
aAdd(aCores,{"C5_XSTATUS=='F'",'BR_MARRON_OCEAN','Pedido Lib. Financeira'})	//Pedido Lib. Financeira
aAdd(aCores,{"C5_XSTATUS=='O'",'BR_CINZA','OP Programada'})	//Pedido OP PROGRAMADA
aAdd(aCores,{'C5_XSTATUS=="R"','BR_PINK','Romaneio'})     // Pedido "Novo STATUS"
aAdd(aCores,{"C5_XSTATUS == 'C'",'BR_BRANCO','Pedido Aprovado pelo Cliente'})	//Pedido Bloquedo por verba

return( aCores )

User Function MA410LEG()

Local aLegNew := ParamIXB

AADD( aLegNew, {"BR_PINK","Romaneio"} )
AADD( aLegNew, {"BR_MARRON_OCEAN","Lib. Financeira"} )
AADD( aLegNew, {"BR_CINZA","OP Programada"} )
AADD( aLegNew, {"BR_BRANCO","Aprovado pelo Cliente"} )
Return( aLegNew )