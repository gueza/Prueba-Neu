CREATE OR REPLACE FUNCTION calculate_bill( IN service_id INT, OUT EA FLOAT, OUT EC FLOAT) AS $$
DECLARE
    total_consumption FLOAT;
    total_injection FLOAT;
    tariff_CU FLOAT;
    tariff_C FLOAT;
    excess_consumption FLOAT;
    hourly_value FLOAT;
    excess_injection FLOAT;
BEGIN
    -- EA
    SELECT SUM(value) INTO total_consumption 
    FROM consumption AS c
	INNER JOIN records r ON r.id_record = c.id_record
    WHERE r.id_service = service_id;

	-- EC
   	SELECT SUM(value) INTO total_injection 
    FROM injection AS i
	INNER JOIN records r ON r.id_record = i.id_record
    WHERE r.id_service = service_id;

	EA = total_consumption;
	EC = total_injection;

    RETURN;
END;
$$ LANGUAGE plpgsql;

