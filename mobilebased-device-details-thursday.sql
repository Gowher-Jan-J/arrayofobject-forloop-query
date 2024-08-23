-- DROP FUNCTION IF EXISTS get_device_detail(bigint);
-- CREATE OR REPLACE FUNCTION get_device_detail(p_mobile_number bigint)
-- RETURNS JSON
-- LANGUAGE plpgsql
-- AS
-- $$
-- BEGIN
--   RETURN jsonb_build_object(
--     'devices', (
--       SELECT jsonb_agg(
--         jsonb_build_object(
--           'id', d.id::text,
--           'name', d.name,
--           's_no', d.s_no
--         )
--       )
--       FROM public.device AS d
--       JOIN public.deviceuser AS du ON d.id = du.device_id AND du.deleted = 'false'
--       JOIN public.user AS u ON du.user_id = u.id 
--       WHERE u.mobile_number = p_mobile_number
--     )
--   );
-- END;
-- $$;

-- -- Execute the function
-- SELECT * FROM get_device_detail(9566675107);

-- USING CONDITIONS FOR DEVICE TYPE AND MOBILE NUMBER

DROP FUNCTION IF EXISTS get_device_detail(bigint, text, text);
CREATE OR REPLACE FUNCTION get_device_detail(
    p_mobile_number bigint DEFAULT NULL,
    p_s_no text DEFAULT NULL,
    p_form_name text DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS
$$
DECLARE
    device_type text;
BEGIN
    -- Determine device type based on provided serial number or form name
    IF p_s_no IS NOT NULL THEN
        SELECT type INTO device_type 
        FROM public.device
        WHERE s_no = p_s_no;
    ELSIF p_form_name IS NOT NULL THEN
        SELECT type INTO device_type 
        FROM public.device
        WHERE name = p_form_name;
    END IF;

    -- Condition 1: Return devices based on mobile number
    IF p_mobile_number IS NOT NULL AND (p_s_no IS NULL AND p_form_name IS NULL) THEN
        RETURN jsonb_build_object(
            'devices', (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', d.id::text,
                        'name', d.name,
                        's_no', d.s_no
                    )
                )
                FROM public.device AS d
                JOIN public.deviceuser AS du ON d.id = du.device_id AND du.deleted = 'false'
                JOIN public.user AS u ON du.user_id = u.id 
                WHERE u.mobile_number = p_mobile_number
            )
        );

    -- Condition 2: Device type is 'air'
    ELSIF device_type = 'air' THEN
        RETURN jsonb_build_object(
            'device', (
                SELECT jsonb_build_object(
                    'id', d.id::text,
                    'name', d.name,
                    's_no', d.s_no,
                    'type', d.type
                )
                FROM public.device AS d
                WHERE d.s_no = p_s_no OR d.name = p_form_name
            )
        );

    -- Condition 3: Device type is 'motor'
    ELSIF device_type = 'motor' THEN
        RETURN jsonb_build_object(
            'device_info', (
                SELECT jsonb_build_object(
                    'id', d.id::text,
                    'name', d.name,
                    's_no', d.s_no,
                    'type', d.type
                )
                FROM public.device AS d
                WHERE d.s_no = p_s_no
            ),
            'motor_info', (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', m.id::text,
                        'name', m.name,
                        's_no', m.s_no,
                        'type', m.type,
                        'status', m.status,
                        'communication_state', m.communication_state
                    )
                )
                FROM public.motor AS m
                WHERE m.device_id = (
                    SELECT id FROM public.device WHERE s_no = p_s_no
                )
            )
        );

    -- Default: Return null if no conditions match
    ELSE
        RETURN NULL;
    END IF;
END;
$$;

-- Execute the function
SELECT * FROM get_device_detail(9566675107);


----LAST UPDATED CODE FOR AIR 

DROP FUNCTION IF EXISTS get_device_detail(bigint, text, text);
CREATE OR REPLACE FUNCTION get_device_detail(
    p_mobile_number bigint DEFAULT NULL,
    p_s_no text DEFAULT NULL,
    p_form_name text DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
AS
$$
DECLARE
    device_type text;
BEGIN
   
    IF p_s_no IS NOT NULL THEN
        SELECT type INTO device_type 
        FROM public.device
        WHERE s_no = p_s_no;
    ELSIF p_form_name IS NOT NULL THEN
        SELECT type INTO device_type 
        FROM public.device
        WHERE name = p_form_name;
    END IF;


    IF p_mobile_number IS NOT NULL AND (p_s_no IS NULL AND p_form_name IS NULL) THEN
        RETURN jsonb_build_object(
            'devices', (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', d.id::text,
                        'name', d.name,
                        's_no', d.s_no
                    )
                )
                FROM public.device AS d
                JOIN public.deviceuser AS du ON d.id = du.device_id AND du.deleted = 'false'
                JOIN public.user AS u ON du.user_id = u.id 
                WHERE u.mobile_number = p_mobile_number
            )
        );

  
  ELSIF p_mobile_number IS NULL AND (p_s_no IS NOT NULL AND p_form_name IS NULL) THEN
        RETURN jsonb_build_object(
            'devices', (
                SELECT jsonb_build_object(
                    'id', d.id::text,
                    'name', d.name,
                    's_no', d.s_no
                )
                FROM public.device AS d
                WHERE d.s_no = p_s_no OR d.name = p_form_name
            ),
			'motors',(
           SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', m.id::text,
                        'name', m.name,
                        's_no', m.s_no,
                        'type', m.type,
                        'status', m.status,
                        'communication_state', m.communication_state
                    )
					)
                
			
			  FROM public.motor as m
			  )
        );

   
    
    ELSE
        RETURN NULL;
    END IF;
END;
$$;


SELECT * FROM get_device_detail(NULL,'AIRX000777');