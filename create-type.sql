CREATE TYPE product_type AS (
    product_name text,
    product_image text,
    status boolean,
    created_at bigint -- Storing milliseconds as bigint
);

-- Define a type for categories
CREATE TYPE category_type AS (
    category_name text,
    status boolean,
    products product_type[]
);

-- Function to retrieve all categories with products
CREATE OR REPLACE FUNCTION get_all_categories_with_products()
RETURNS jsonb AS $$
DECLARE
    category_row category_type;
    product_row product_type;
    result jsonb = '[]';
    products jsonb;
BEGIN
    FOR category_row IN 
        SELECT c.category_name, 
               CASE WHEN c.status = 'Active' THEN true ELSE false END AS status,
               ARRAY(
                   SELECT ROW(
                       p.product_name,
                       p.product_image,
                       true, -- Assuming status for products is always true in this context
                       EXTRACT(EPOCH FROM p.created_at) * 1000 -- Convert to milliseconds
                   )::product_type
                   FROM product p
                   WHERE p.categoryid = c.id
               ) AS products
        FROM category c
    LOOP
        -- Build JSON object for products
        products = '[]';
        FOREACH product_row IN ARRAY category_row.products LOOP
            products = products || jsonb_build_object(
                'product_name', product_row.product_name,
                'product_image', product_row.product_image,
                'status', product_row.status,
                'created_at', product_row.created_at
            );
        END LOOP;

        -- Append category details with status and products
        result = result || jsonb_build_object(
            'category_name', category_row.category_name,
            'status', category_row.status,
            'products', products
        );
    END LOOP;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Example usage:
SELECT * FROM get_all_categories_with_products();

-- Drop the types if no longer needed
DROP TYPE product_type;
DROP TYPE category_type;