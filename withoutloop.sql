SELECT jsonb_agg(
    jsonb_build_object(
        'category_name', c.category_name,
        'status', c.status,
        'products', (
            SELECT jsonb_agg(
                jsonb_build_object(
                    'product_name', p.product_name,
                    'product_image', p.product_image
                )
            )
            FROM public.product p
            WHERE p.categoryid = c.id
        )
    )
) AS categories
FROM category c;
