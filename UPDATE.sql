DROP FUNCTION IF EXISTS get_device_detail(bigint,int,text,text);

CREATE OR REPLACE FUNCTION get_device_detail(
  user_mobile_number bigint DEFAULT NULL,
  device_type int DEFAULT 0,
  serialr_no text DEFAULT NULL,
  form_name text DEFAULT NULL

)
RETURNS JSON
LANGUAGE plpgsql
AS $$
BEGIN
  
----IF HAVING MOBILE NUMBER----

  IF user_mobile_number IS NOT NULL THEN
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
        WHERE u.mobile_number = user_mobile_number
      )
    );
	
--------IF DEVICE TYPE IS AIR S_NO OR FORM_NAME ----------
	
ELSIF user_mobile_number IS NULL AND (serialr_no IS NOT NULL OR form_name IS NOT NULL) AND device_type=0 THEN
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
        WHERE (d.s_no = serialr_no OR d.name = form_name )
		 AND m.status NOT IN (7,0,3, 4) 
		 LIMIT 1
      ),
      'weather', (
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
        WHERE (d.s_no =serialr_no OR d.name = form_name and s.type=8)
		AND s.status NOT IN (7,0,3,4,2)
		LIMIT 1
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
        WHERE (d.s_no = serialr_no OR d.name = form_name)
		 AND s.status NOT IN (7)
		 AND s.type IN (6,7)
		 LIMIT 1
      ),
      'water_level', (
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
        WHERE (d.s_no = serialr_no OR d.name = form_name and s.type=5)
		LIMIT 1
      )
    )
	FROM public.device AS d
WHERE d.s_no =serialr_no OR d.name = form_name
LIMIT 1;
 

------------- IF DEVICE TYPE IS MOTOR, S_NO ---------------

ELSIF user_mobile_number IS NULL AND (serialr_no IS NOT NULL OR form_name IS NULL) AND device_type=1 THEN
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
        WHERE (m.s_no =serialr_no)
		LIMIT 1
		 
      )
	  )
	  FROM public.device AS d 
	  JOIN public.motor AS m ON m.device_id = d.id
WHERE m.s_no = serialr_no
LIMIT 1;


------------- IF DEVICE TYPE IS SENSOR,TYPE,S_NO ---------------

ELSIF user_mobile_number IS NULL AND (serialr_no IS NOT NULL OR form_name IS NULL) AND device_type=2 THEN
    RETURN jsonb_build_object(    
          'id', d.id,
          'name', d.name,
          's_no', d.s_no,
          'type', d.type,
      'sensors', (
        SELECT jsonb_build_object(
            'id', s.id::text,
            'name', s.name,
            's_no', s.s_no,
            'type', s.type,
            'status', s.status,
            'communication_state', s.communication_state
          )
        
        FROM public.sensor AS s
        -- JOIN public.device AS d ON m.device_id = d.id
        WHERE (s.s_no =serialr_no)
		and s.type=6
		LIMIT 1
		 
      )
	  )
	  FROM public.device AS d 
	  JOIN public.sensor AS s ON s.device_id = d.id
WHERE s.s_no = serialr_no
LIMIT 1;

------------- IF DEVICE TYPE IS WATER LEVEL,TYPE,S_NO ---------------

ELSIF user_mobile_number IS NULL AND (serialr_no IS NOT NULL OR form_name IS NULL) AND device_type=3 THEN
    RETURN jsonb_build_object(    
          'id', d.id,
          'name', d.name,
          's_no', d.s_no,
          'type', d.type,
      'water_level', (
        SELECT jsonb_build_object(
            'id', s.id::text,
            'name', s.name,
            's_no', s.s_no,
            'type', s.type,
            'status', s.status,
            'communication_state', s.communication_state
          )
        
        FROM public.sensor AS s
        -- JOIN public.device AS d ON m.device_id = d.id
        WHERE (s.s_no = serialr_no)
		and s.type=5
		LIMIT 1
		 
      )
	  )
	  FROM public.device AS d 
	  JOIN public.sensor AS s ON s.device_id = d.id
WHERE s.s_no = serialr_no
LIMIT 1;

------------- IF DEVICE TYPE IS WEATHER,TYPE,S_NO ---------------

ELSIF user_mobile_number IS NULL AND (serialr_no IS NOT NULL OR form_name IS NULL) AND device_type=4 THEN

    RETURN jsonb_build_object(    
          'id', d.id,
          'name', d.name,
          's_no', d.s_no,
          'type', d.type,
      'weather', (
        SELECT jsonb_build_object(
            'id', s.id::text,
            'name', s.name,
            's_no', s.s_no,
            'type', s.type,
            'status', s.status,
            'communication_state', s.communication_state
          )
        
        FROM public.sensor AS s
        -- JOIN public.device AS d ON m.device_id = d.id
        WHERE (s.s_no = serialr_no)
		and s.type=8
		LIMIT 1
		 
      )
	  )
	  FROM public.device AS d 
	  JOIN public.sensor AS s ON s.device_id = d.id
WHERE s.s_no = serialr_no
LIMIT 1;

------------- IF DEVICE TYPE IS IRRIGATION,TYPE,S_NO ---------------
ELSIF user_mobile_number IS NULL AND (serialr_no IS NOT NULL OR form_name IS NULL) AND device_type=5 THEN
RETURN jsonb_build_object(
    'id', d.id,
    'name', d.name,
    's_no', d.s_no,
    'type', d.type,
    'irrigation', (
        SELECT jsonb_build_object(
            'id', n.id::text,
            'name', n.name,
            's_no', n.s_no,
            'type', n.type,
            'status', n.status,
            'communication_state', n.communication_state,
            'order_number', n.order_number,
            'power_type', n.power_type,
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
                WHERE n.s_no = serialr_no
                AND v.status NOT IN (7)
            
            )
        )
        FROM public.node AS n
        WHERE n.s_no = serialr_no
        AND n.type = 3
        LIMIT 1
    )
)
FROM public.device AS d 
JOIN public.node AS n ON n.device_id = d.id 
WHERE n.s_no = serialr_no
LIMIT 1;


------------- IF DEVICE TYPE IS BACKWASH TYPE,S_NO ---------------

ELSIF user_mobile_number IS NULL AND (serialr_no IS NOT NULL OR form_name IS NULL) AND device_type=6 THEN
RETURN jsonb_build_object(
    'id', d.id,
    'name', d.name,
    's_no', d.s_no,
    'type', d.type,
    'backwash_node',(
        SELECT jsonb_build_object(
            'id', n.id::text,
            'name', n.name,
            's_no', n.s_no,
            'type', n.type,
            'status', n.status,
            'order_number', n.order_number,
            'node_limit', n.node_limit,
            'communication_state', n.communication_state
        )
        FROM public.node AS n
        WHERE n.device_id = d.id
        AND n.type = 9
        LIMIT 1 
    )
)
FROM public.device AS d
WHERE EXISTS (
    SELECT 1
    FROM public.node AS n
    WHERE n.device_id = d.id
    AND n.s_no = serialr_no
    AND n.type = 9
);




ELSE
RETURN NULL;
END IF;
END;
$$;


SELECT * FROM get_device_detail(9566675107::bigint,null::int,null::text,null::text);