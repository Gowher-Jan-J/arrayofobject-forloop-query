DROP FUNCTION IF EXISTS get_device_detail(bigint,int,text,text);

CREATE OR REPLACE FUNCTION get_device_detail(
  mobile_number bigint DEFAULT NULL,
  d_type int DEFAULT 0,
  sr_no text DEFAULT NULL,
  form_name text DEFAULT NULL

)
RETURNS JSON
LANGUAGE plpgsql
AS $$
BEGIN
  
----IF HAVING MOBILE NUMBER----

  IF mobile_number IS NOT NULL THEN
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
        WHERE u.mobile_number = mobile_number
      )
    );
	
--------IF DEVICE TYPE IS AIR ,TYPE,S_NO OR FORM_NAME ----------
	
ELSIF mobile_number IS NULL AND (sr_no IS NOT NULL OR form_name IS NOT NULL) AND d_type =0 THEN
    RETURN jsonb_build_object(    
          'id', d.id,
          'name', d.name,
          's_no', d.s_no,
          'type', d.type,
      'motors', (
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
        JOIN public.device AS d ON m.device_id = d.id
        WHERE (d.s_no = sr_no OR d.name = form_name )
		 AND m.status NOT IN (7,0,3, 4) 
      ),
      'weather', (
        SELECT jsonb_agg(
          jsonb_build_object(
            'id', w.id::text,
            'name', w.name,
            's_no', w.s_no,
            'type', w.type,
            'status', w.status,
            'communication_state', w.communication_state
          )
        )
        FROM public.sensor AS w
        JOIN public.device AS d ON w.device_id = d.id
        WHERE (d.s_no = s_no OR d.name = form_name and w.type=8)
		AND w.status NOT IN (7,0,3,4,2)
      ),
      'sensors', (
        SELECT jsonb_agg(
          jsonb_build_object(
            'id', s.id::text,
            'name', s.name,
            's_no', s.s_no,
            'type', s.type,
            'status', s.status,
            'communication_state', s.communication_state
          )
        )
        FROM public.sensor AS s
        JOIN public.device AS d ON s.device_id = d.id
        WHERE (d.s_no = sr_no OR d.name = form_name)
		 AND s.status NOT IN (7)
		 AND s.type IN (6,7)
      ),
      'water_level', (
        SELECT jsonb_agg(
          jsonb_build_object(
            'id', w.id::text,
            'name', w.name,
            's_no', w.s_no,
            'type', w.type,
            'status', w.status,
            'communication_state', w.communication_state
          )
        )
        FROM public.sensor AS w
        JOIN public.device AS d ON w.device_id = d.id 
        WHERE (d.s_no = sr_no OR d.name = form_name and w.type=5)
      )
    )
	FROM public.device AS d
WHERE d.s_no = s_no OR d.name = form_name;
 

------------- IF DEVICE TYPE IS MOTOR,TYPE,S_NO ---------------

ELSIF mobile_number IS NULL AND (sr_no IS NOT NULL OR form_name IS NULL) AND d_type  =1 THEN
    RETURN jsonb_build_object(    
          'id', d.id,
          'name', d.name,
          's_no', d.s_no,
          'type', d.type,
      'motors', (
        SELECT jsonb_build_object(
            'id', m.id::text,
            'name', m.name,
            's_no', m.s_no,
            'type', m.type,
            'status', m.status,
            'communication_state', m.communication_state
          )
        
        FROM public.motor AS m
        -- JOIN public.device AS d ON m.device_id = d.id
        WHERE (m.s_no =sr_no)
		 
      )
	  )
	  FROM public.device AS d 
	  JOIN public.motor AS m ON m.device_id = d.id
WHERE m.s_no = sr_no;


------------- IF DEVICE TYPE IS SENSOR,TYPE,S_NO ---------------

ELSIF mobile_number IS NULL AND (sr_no IS NOT NULL OR form_name IS NULL) AND d_type  =2 THEN
    RETURN jsonb_build_object(    
          'id', d.id,
          'name', d.name,
          's_no', d.s_no,
          'type', d.type,
      'sensors', (
        SELECT jsonb_build_object(
            'id', m.id::text,
            'name', m.name,
            's_no', m.s_no,
            'type', m.type,
            'status', m.status,
            'communication_state', m.communication_state
          )
        
        FROM public.sensor AS m
        -- JOIN public.device AS d ON m.device_id = d.id
        WHERE (m.s_no =sr_no)
		and m.type=6
		 
      )
	  )
	  FROM public.device AS d 
	  JOIN public.sensor AS m ON m.device_id = d.id
WHERE m.s_no = sr_no;

------------- IF DEVICE TYPE IS WATER LEVEL,TYPE,S_NO ---------------

ELSIF mobile_number IS NULL AND (sr_no IS NOT NULL OR form_name IS NULL) AND d_type=3 THEN
    RETURN jsonb_build_object(    
          'id', d.id,
          'name', d.name,
          's_no', d.s_no,
          'type', d.type,
      'water_level', (
        SELECT jsonb_build_object(
            'id', m.id::text,
            'name', m.name,
            's_no', m.s_no,
            'type', m.type,
            'status', m.status,
            'communication_state', m.communication_state
          )
        
        FROM public.sensor AS m
        -- JOIN public.device AS d ON m.device_id = d.id
        WHERE (m.s_no = sr_no)
		and m.type=5
		 
      )
	  )
	  FROM public.device AS d 
	  JOIN public.sensor AS m ON m.device_id = d.id
WHERE m.s_no = sr_no;

------------- IF DEVICE TYPE IS WEATHER,TYPE,S_NO ---------------

ELSIF mobile_number IS NULL AND (sr_no IS NOT NULL OR form_name IS NULL) AND d_type=4 THEN
    RETURN jsonb_build_object(    
          'id', d.id,
          'name', d.name,
          's_no', d.s_no,
          'type', d.type,
      'weather', (
        SELECT jsonb_build_object(
            'id', m.id::text,
            'name', m.name,
            's_no', m.s_no,
            'type', m.type,
            'status', m.status,
            'communication_state', m.communication_state
          )
        
        FROM public.sensor AS m
        -- JOIN public.device AS d ON m.device_id = d.id
        WHERE (m.s_no = sr_no)
		and m.type=8
		 
      )
	  )
	  FROM public.device AS d 
	  JOIN public.sensor AS m ON m.device_id = d.id
WHERE m.s_no = sr_no;

------------- IF DEVICE TYPE IS IRRIGATION,TYPE,S_NO ---------------


ELSIF mobile_number IS NULL AND (sr_no IS NOT NULL OR form_name IS NULL) AND d_type=5 THEN
 -- RAISE NOTICE 'Variable1: %, Variable2: %', p_s_no , P_TYPE;
    RETURN jsonb_build_object(
    'id', d.id,
    'name', d.name,
    's_no', d.s_no,
    'type', d.type,
    'irrigation', (
        SELECT jsonb_build_object(
            'id', m.id::text,
            'name', m.name,
            's_no', m.s_no,
            'type', m.type,
            'status', m.status,
            'communication_state', m.communication_state,
            'order_number', m.order_number,
            'power_type', m.power_type,
            'valves', (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', v.id::text,
                        'name', v.name,
                        'order_number', v.order_number,
                        'status', v.status
                    )
                )
                FROM public.valve AS v
                JOIN public.node AS n ON v.device_id = n.device_id
                WHERE n.s_no = sr_no
                AND v.status NOT IN (7)
            )
        )
        FROM public.node AS m
        WHERE m.s_no =sr_no
        AND m.type = 3
    )
)
FROM public.device AS d 
JOIN public.node AS m ON m.device_id = d.id 
WHERE m.s_no =sr_no;

------------- IF DEVICE TYPE IS BACKWASH TYPE,S_NO ---------------

ELSIF mobile_number IS NULL AND (sr_no IS NOT NULL OR form_name IS NULL) AND d_type=6 THEN
RETURN jsonb_build_object(
    'id', d.id,
    'name', d.name,
    's_no', d.s_no,
    'type', d.type,
    'backwash_node', (
        SELECT jsonb_build_object(
            'id', m.id::text,
            'name', m.name,
            's_no', m.s_no,
            'type', m.type,
            'status', m.status,
            'order_number', m.order_number,
            'node_limit', m.node_limit,
            'communication_state', m.communication_state
        )
        FROM public.node AS m
        WHERE m.device_id = d.id
        AND m.type = 9
        LIMIT 1  -- Ensures only one row is returned to avoid multiple row errors
    )
)
FROM public.device AS d
WHERE EXISTS (
    SELECT 1
    FROM public.node AS m
    WHERE m.device_id = d.id
    AND m.s_no = sr_no
    AND m.type = 9
);




ELSE
RETURN NULL;
END IF;
END;
$$;

SELECT * FROM get_device_detail(null,6,'ABWXDEV085',null);
