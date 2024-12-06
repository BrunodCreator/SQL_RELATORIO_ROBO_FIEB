WITH Faturas AS (
    SELECT
        F.[Mês/ANO],
		F.[Razão Social],   -- Cliente
        F.Banco,
        F.Agência,
        F.Conta,
        F.CNPJ,            
        F.[Vlr Fatura],
        F.[vlr Folha],
        E.valor AS valor_deposito,   -- Valor do Depósito
        E.data AS data_Deposito,     -- Data do Depósito
        F.Status,
        COUNT(E.id_log_extrato_conta) AS qtd_faturas_log,
        COUNT(F.[Mês/ANO]) AS qtd_faturas_vw
    FROM 
        vw_contrato_faturamento_robo F
    LEFT JOIN 
        log_extrato_conta E ON E.AGENCIA = F.Agência 
                             AND E.CONTA = F.CONTA 
                             AND E.valor = F.[Vlr Fatura]
    GROUP BY 
        F.[Mês/ANO], F.Banco, F.Agência, F.Conta, F.CNPJ, F.[Razão Social], F.[Vlr Fatura], F.[vlr Folha], E.valor, E.data, F.Status
)
SELECT DISTINCT
	data_Deposito,  -- Data do Depósito
    --MesAno,
	[Razão Social] AS Cliente,
	CNPJ,
    Banco,
    Agência,
    Conta,
    valor_deposito AS Valor_Deposito, -- Valor do Depósito
    [Vlr Fatura] AS Valor_Fatura,
    [vlr Folha] AS Valor_Folha,
    --Status,
    --qtd_faturas_log,
    --qtd_faturas_vw,
    CASE
        WHEN qtd_faturas_vw > 1 AND qtd_faturas_log = 1 THEN 'Existência de mais de uma fatura'
        WHEN qtd_faturas_vw = qtd_faturas_log AND valor_deposito = [Vlr Fatura] THEN 'Depósito realizado'
        WHEN qtd_faturas_vw = 1 AND qtd_faturas_log = 1 AND valor_deposito <> [Vlr Fatura] THEN 'Depósito c/ valor divergente'
        WHEN qtd_faturas_vw = 1 AND qtd_faturas_log = 0 THEN 'Depósito não realizado'
        ELSE 'Status desconhecido'
    END AS STATUS
FROM 
    Faturas
	where [vlr Folha] IS NOT NULL 
	 AND MONTH(data_Deposito) = (MONTH(GETDATE()));
	
--AND [Mês/ANO] = 'OUT/24';
	

--SELECT MONTH(GETDATE())
