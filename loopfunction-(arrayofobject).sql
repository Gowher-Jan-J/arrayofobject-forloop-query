
CREATE OR REPLACE FUNCTION get_all_categories_with_products()
RETURNS jsonb AS $$
DECLARE
    category_row RECORD;
    product_row RECORD;
    result jsonb = '[]';
    products jsonb;
BEGIN
    FOR category_row IN 
        SELECT c.category_name, c.status
        FROM category c
    LOOP
        products = '[]';
        
        FOR product_row IN
            SELECT p.product_name, p.product_image
            FROM product p
            WHERE p.categoryid = (SELECT id FROM category WHERE category_name = category_row.category_name)
        LOOP
            products = products || jsonb_build_object(
                'product_name', product_row.product_name,
                'product_image', product_row.product_image
            );
        END LOOP;
        
        result = result || jsonb_build_object(
            'category_name', category_row.category_name,
            'status', category_row.status,
            'products', products
        );
    END LOOP;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

SELECT *from get_all_categories_with_products();

drop function if exists getobjectallarray();
