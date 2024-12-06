WITH Faturas AS (
    SELECT
        F.MesAno,
		F.RazaoSocial,   -- Cliente
        F.Banco,
        F.Agencia,
        F.Conta,
        F.CNPJ,            
        F.VlrFatura,
        F.VlrFolha,
        E.valor AS valor_deposito,   -- Valor do Depósito
        E.data_processamento AS data_Deposito,     -- Data do Depósito
        F.Status,
        COUNT(DISTINCT E.id_log_extrato_conta) AS qtd_faturas_log,
        COUNT(DISTINCT F.MesAno) AS qtd_faturas_vw
    FROM 
        vw_contrato_faturamento_robo F
    LEFT JOIN 
        log_extrato_conta E ON E.AGENCIA = F.Agencia 
                             AND E.CONTA = F.CONTA 
                             AND E.valor = F.VlrFatura
    GROUP BY 
        F.MesAno, F.Banco, F.Agencia, F.Conta, F.CNPJ, F.RazaoSocial, F.VlrFatura, F.VlrFolha, E.valor, E.data_processamento, F.Status
)
SELECT DISTINCT
	data_Deposito,  -- Data do Depósito
    --MesAno,
	RazaoSocial AS Cliente,
	CNPJ,
    Banco,
    Agencia,
    Conta,
    valor_deposito AS Valor_Deposito, -- Valor do Depósito
    VlrFatura AS Valor_Fatura,
    VlrFolha AS Valor_Folha,
    --Status,
    qtd_faturas_log,
    qtd_faturas_vw,
    CASE
        WHEN qtd_faturas_vw > 1 AND qtd_faturas_log = 1 THEN 'Existência de mais de uma fatura'
        WHEN qtd_faturas_vw = qtd_faturas_log AND valor_deposito = VlrFatura THEN 'Depósito realizado'
        WHEN qtd_faturas_vw = 1 AND qtd_faturas_log = 1 AND valor_deposito <> VlrFatura THEN 'Depósito c/ valor divergente'
        WHEN qtd_faturas_vw = 1 AND qtd_faturas_log = 0 THEN 'Depósito não realizado'
		WHEN qtd_faturas_log > qtd_faturas_vw THEN 'Pagamento em duplicidade'
        ELSE 'Status desconhecido'
    END AS STATUS
FROM 
    Faturas