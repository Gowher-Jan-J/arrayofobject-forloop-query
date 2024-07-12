CREATE OR REPLACE FUNCTION get_all_categories_with_products()
RETURNS jsonb AS $$
DECLARE
    category_row RECORD;
    product_row RECORD;
    result jsonb = '[]';
    products jsonb;
BEGIN
    FOR category_row IN 
        SELECT c.category_name, c.status, c.id
        FROM category c
    LOOP
        products = '[]';

        -- Check if category status is active
        IF category_row.status = 'Active' THEN
            -- Fetch products for the current category
            FOR product_row IN
                SELECT p.product_name, p.status, p.product_image, EXTRACT(EPOCH FROM p.created_at) * 1000 AS created_at_unixms
                FROM product p
                WHERE p.categoryid = category_row.id
            LOOP
                products = products || jsonb_build_object(
                    'product_name', product_row.product_name,
                    'product_image', product_row.product_image,
					'status', true,
                    'created_at', product_row.created_at_unixms
                );
            END LOOP;

            -- Append category details with status set to true and products
            result = result || jsonb_build_object(
                'category_name', category_row.category_name,
                'status', true,
                'products', products
            );
        ELSE
            -- Append category details with status from database but no products
            result = result || jsonb_build_object(
                'category_name', category_row.category_name,
                'status', category_row.status,
                'products', products -- Empty array since no products for inactive categories
            );
        END IF;
    END LOOP;

    RETURN result;
END;
$$ LANGUAGE plpgsql;


select *from get_all_categories_with_products();
drop function if exists get_all_categories_with_products();

CREATE OR REPLACE FUNCTION getall()
returns jsonb AS $$
DECLARE 
result jsonb='[]' ;
BEGIN
result=result||(SELECT * FROM get_all_categories_with_products());
return result;
 END;
$$ LANGUAGE plpgsql;

 select *from getall();
 

