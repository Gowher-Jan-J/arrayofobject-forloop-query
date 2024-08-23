DROP FUNCTION IF EXISTS get_device_detail(bigint, text, text, int);

CREATE OR REPLACE FUNCTION get_device_detail(
  p_mobile_number bigint DEFAULT NULL,
  p_s_no text DEFAULT NULL,
  p_form_name text DEFAULT NULL,
  P_type int DEFAULT 0
)
RETURNS JSON
LANGUAGE plpgsql
AS $$
BEGIN
  
----IF HAVING MOBILE NUMBER----

  IF p_mobile_number IS NOT NULL THEN
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
	
--------IF DEVICE TYPE IS AIR ,TYPE,S_NO OR FORM_NAME ----------
	
ELSIF p_mobile_number IS NULL AND (p_s_no IS NOT NULL OR p_form_name IS NOT NULL) AND P_TYPE =0 THEN
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
        WHERE (d.s_no = p_s_no OR d.name = p_form_name )
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
        WHERE (d.s_no = p_s_no OR d.name = p_form_name and w.type=8)
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
        WHERE (d.s_no = p_s_no OR d.name = p_form_name)
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
        WHERE (d.s_no = p_s_no OR d.name = p_form_name and w.type=5)
      )
    )
	FROM public.device AS d
WHERE d.s_no = p_s_no OR d.name = p_form_name;
 

------------- IF DEVICE TYPE IS MOTOR,TYPE,S_NO ---------------

ELSIF p_mobile_number IS NULL AND (p_s_no IS NOT NULL OR p_form_name IS NULL) AND P_TYPE =1 THEN
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
        WHERE (m.s_no = p_s_no )
		 
      )
	  )
	  FROM public.device AS d 
	  JOIN public.motor AS m ON m.device_id = d.id
WHERE m.s_no = p_s_no;


------------- IF DEVICE TYPE IS SENSOR,TYPE,S_NO ---------------

ELSIF p_mobile_number IS NULL AND (p_s_no IS NOT NULL OR p_form_name IS NULL) AND P_TYPE =2 THEN
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
        WHERE (m.s_no = p_s_no)
		and m.type=6
		 
      )
	  )
	  FROM public.device AS d 
	  JOIN public.sensor AS m ON m.device_id = d.id
WHERE m.s_no = p_s_no;

------------- IF DEVICE TYPE IS WATER LEVEL,TYPE,S_NO ---------------

ELSIF p_mobile_number IS NULL AND (p_s_no IS NOT NULL OR p_form_name IS NULL) AND P_TYPE =3 THEN
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
        WHERE (m.s_no = p_s_no)
		and m.type=5
		 
      )
	  )
	  FROM public.device AS d 
	  JOIN public.sensor AS m ON m.device_id = d.id
WHERE m.s_no = p_s_no;

------------- IF DEVICE TYPE IS WEATHER,TYPE,S_NO ---------------

ELSIF p_mobile_number IS NULL AND (p_s_no IS NOT NULL OR p_form_name IS NULL) AND P_TYPE =4 THEN
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
        WHERE (m.s_no = p_s_no)
		and m.type=8
		 
      )
	  )
	  FROM public.device AS d 
	  JOIN public.sensor AS m ON m.device_id = d.id
WHERE m.s_no = p_s_no;


ELSE
RETURN NULL;
END IF;
END;
$$;

SELECT * FROM get_device_detail(null,'CYUBFFJIHVBKKB',null,4);

