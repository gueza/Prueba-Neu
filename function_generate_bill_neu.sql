CREATE OR REPLACE FUNCTION calculate_bill( 
	IN service_id INT, 
	OUT EA FLOAT, 
	OUT EC FLOAT,
	OUT EE1 FLOAT,
	OUT EE2 FLOAT) AS $$
DECLARE
    total_consumption FLOAT;
    total_injection FLOAT;
	voltage_level_number INT;
    tariff_CU FLOAT;
	tariff_amount_EE2 FLOAT;
    tariff_C FLOAT;
	market_id INT;
    cdi_number INT;
BEGIN
    -- calcular cantidad total_consumption
    SELECT SUM(value) INTO total_consumption 
    FROM consumption AS c
	INNER JOIN records r ON r.id_record = c.id_record
    WHERE r.id_service = service_id;

  	-- calcular cantidad total_injection
   	SELECT SUM(value) INTO total_injection 
    FROM injection AS i
	INNER JOIN records r ON r.id_record = i.id_record
    WHERE r.id_service = service_id;

  	SELECT s.voltage_level, s.id_market, s.cdi 
		INTO voltage_level_number, market_id, cdi_number 
    FROM services s
    WHERE s.id_service = service_id;

	IF voltage_level_number = 2 OR voltage_level_number = 3 
		THEN
			SELECT CU INTO tariff_CU
			FROM tariffs t
			WHERE t.id_market = market_id
			AND t.voltage_level IN (2, 3)
			LIMIT 1;
		ELSE
			SELECT CU INTO tariff_CU
	        FROM tariffs t
	        WHERE t.id_market = market_id
	        AND t.cdi = cdi_number
	        AND t.voltage_level = voltage_level_number;
	END IF;

	SELECT C 
		INTO tariff_C
    FROM tariffs
    WHERE id_market = market_id
    AND voltage_level = voltage_level_number;

	EC := total_injection * tariff_C;
	EA := total_consumption * tariff_CU;

	-- EE1
	IF total_injection <= total_consumption
		THEN
			EE1 := total_injection * (-tariff_CU);
		ELSE
			EE1 := total_consumption * (-tariff_CU);
	END IF;

	-- EE2
	IF total_injection <= total_consumption
		THEN 
			EE2 := 0;
		ELSE
			SELECT SUM((c.value - i.value) * b.value)
			INTO tariff_amount_EE2
			FROM consumption c
			INNER JOIN injection i ON i.id_record = c.id_record
			INNER JOIN records r ON r.id_record = c.id_record
			INNER JOIN xm_data_hourly_per_agent b ON b.record_timestamp = r.record_timestamp
			WHERE r.id_service = service_id;
	
	        EE2 := tariff_amount_EE2;
	END IF;

    RETURN;
END;
$$ LANGUAGE plpgsql;

