
CREATE OR REPLACE FUNCTION get_product_name(product_id product.id%TYPE)
RETURNS product.product_name%TYPE AS $$
DECLARE
 
    productname product.product_name%TYPE;
BEGIN

    SELECT product_name INTO productname
    FROM product
    WHERE id = product_id;

    RETURN productname;
END;
$$ LANGUAGE plpgsql;

select *from get_product_name('0a99ef33-3313-41a1-89a4-7496acc904dd')
drop function if exists get_product_name();
