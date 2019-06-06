# Integração Sengés
**Principais Objetivos:** 
Fazer com que o ERP Totvs Protheus receba, processe e armazene todas as informações necessárias para atender aos departamentos contábeis e fiscais afim de que seus usuários possam analisar, processar e gerencias essas informações.
Para isso será necessário o controle das entradas e saídas de mercadoria/produtos no estoque entre os sistemas Protheus e Trimpaper por meio da integração das seguintes operações:
•	Pedidos de venda: Necessidades para serem atendidas via PCP/Estoque;
•	Entradas fiscais: Nota fiscal de entrada de mercadoria/produto em estoque;
•	Entradas e saídas internas: movimentação interna de estoque (ajustes de quantidades em estoque, ajustes de empenhos, apontamentos e estornos de horas improdutivas);
•	Processos produtivos: abertura de ordem de produção, apontamento de produção e encerramento de OP;
•	Saídas fiscais: Liberação de pedidos de venda para identificar e atualizar as saídas de mercadoria/produto em estoque.

**Origens dos Dados:** 
Cadastros e lançamentos nos Sistemas Protheus e Trimpaper, seguindo pelas integrações entre os sistemas.

**Fatores Críticos de Sucesso:** 
Execução diária e constante das atualizações por parte dos usuários nos sistemas de origem da informação a fim de que a mesma possa ser transmitida via integração ao outro sistema;
Rotinas de origem e destino devem estar devidamente integradas para sempre manter todas as informações atualizadas;
Constante acompanhamento das interfaces de integração para intervenção dos usuários quando necessário;
Havendo necessidade de alteração de alguma regra de negócio/parâmetro do sistema, a mesma deve ser registrada na MIT006 e comunicada aos responsáveis do projeto no cliente e na Totvs para avaliação dos impactos sobre as customizações aqui detalhadas.

**Restrições:** 
Todos os códigos dos cadastros deverão ser mantidos idênticos entre sistemas para o correto funcionamento das integrações já que serão campo-chave para garantia da integridade;
As operações integradas não devem ser manipuladas sem a correta orientação/acompanhamento da equipe responsável da Totvs sob risco de perda da integridade dos dados para os processos automatizados via integração;
Manter as parametrizações definidas nas MIT041 e MIT043 de cada módulo implementado conforme validação entre usuários e equipe da Totvs, sob risco de perda da integridade das informações.
