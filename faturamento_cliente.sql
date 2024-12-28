DROP PROCEDURE `sistema_clientes`.`gerar_relatorio_clientes`;
DELIMITER $$
	CREATE PROCEDURE gerar_relatorio_clientes(IN consultation_year INT, IN min_turnover DECIMAL(10,2))
	BEGIN
		DECLARE done BOOLEAN DEFAULT FALSE;
        DECLARE id_client INT DEFAULT 0;
        DECLARE total_turnover DECIMAL(10,2) DEFAULT 0;
		DECLARE id_list CURSOR FOR SELECT id FROM clientes;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
        TRUNCATE `sistema_clientes`.`log_relatorios`;
        TRUNCATE `sistema_clientes`.`relatorio_anual_clientes`;
        
        OPEN id_list;
			id_loop:LOOP
				FETCH id_list INTO id_client;
                IF done THEN
					LEAVE id_loop;
                END IF;
                
                SELECT SUM(valor) INTO total_turnover FROM vendas WHERE cliente_id = id_client AND YEAR(CONCAT(consultation_year, "-12-01")) = YEAR(data_venda);
                IF total_turnover IS NOT NULL THEN
					IF total_turnover < min_turnover THEN
						INSERT INTO log_relatorios(cliente_id, ano, mensagem) VALUES (id_client, consultation_year, 'Cliente abaixo do limite');
					ELSE
						INSERT INTO relatorio_anual_clientes(cliente_id, ano, faturamento_total) VALUES (id_client, consultation_year, total_turnover);
					END IF;
				END IF;
            END LOOP;
        CLOSE id_list;
	END $$
DELIMITER ;