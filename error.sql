import { CommunicationStatus, SerialCategory, SensorType, NodeType } from "../../models";
export const GET_DEVICE_STATUS_DETAIL = 
DROP FUNCTION IF EXISTS get_device_detail(bigint,int,text);
CREATE OR REPLACE FUNCTION get_device_detail(
	user_mobile_number bigint DEFAULT NULL::bigint,
	device_type integer DEFAULT ${SerialCategory.AIR},
	serial_no text DEFAULT NULL::text
	)
    RETURNS json
    LANGUAGE 'plpgsql'
AS $$
BEGIN
  
----  IF HAVING MOBILE NUMBER  ----

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

ELSIF user_mobile_number IS NULL AND device_type=${SerialCategory.AIR} THEN
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
            WHERE m.device_id = d.id
            AND m.status NOT IN (${CommunicationStatus.DELETED}, ${CommunicationStatus.IN_ACTIVE}, ${CommunicationStatus.SEND_RETRY}, ${CommunicationStatus.SEND_FAILED})
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
            WHERE s.device_id = d.id
              AND s.type = ${SensorType.WEATHER_STATION}
              AND s.status NOT IN (${CommunicationStatus.DELETED}, ${CommunicationStatus.IN_ACTIVE}, ${CommunicationStatus.SEND_RETRY}, ${CommunicationStatus.SEND_FAILED}, ${CommunicationStatus.SEND_SCHEDULE})
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
            WHERE s.device_id = d.id 
              AND s.type IN (${SensorType.SINGLE_PLANT_MULTI_SENSOR})
              AND s.status NOT IN (${CommunicationStatus.DELETED}, ${CommunicationStatus.IN_ACTIVE}, ${CommunicationStatus.SEND_RETRY}, ${CommunicationStatus.SEND_FAILED})
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
            WHERE s.device_id = d.id 
              AND s.type = ${SensorType.WATER_LEVEL}
               AND s.status NOT IN (${CommunicationStatus.DELETED}, ${CommunicationStatus.IN_ACTIVE}, ${CommunicationStatus.SEND_RETRY}, ${CommunicationStatus.SEND_FAILED})
            LIMIT 1
          )
    )
  FROM public.device AS d
  WHERE d.s_no = serial_no OR  d.name ILIKE serial_no || '%' OR d.id=serial_no
  LIMIT 1;

 

------------- IF DEVICE TYPE IS MOTOR, S_NO ---------------

ELSIF user_mobile_number IS NULL AND (serial_no IS NOT NULL) AND device_type=${SerialCategory.MOTOR} THEN
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
        WHERE (m.s_no =serial_no OR m.id=serial_no)
        AND m.status NOT IN (${CommunicationStatus.DELETED}, ${CommunicationStatus.IN_ACTIVE}, ${CommunicationStatus.SEND_RETRY}, ${CommunicationStatus.SEND_FAILED})
		LIMIT 1
		 
      )
	  )
	  FROM public.device AS d 
	  JOIN public.motor AS m ON m.device_id = d.id
WHERE m.s_no = serial_no OR m.id=serial_no
LIMIT 1;

------------- IF DEVICE TYPE IS SENSOR,TYPE,S_NO ---------------

ELSIF user_mobile_number IS NULL AND (serial_no IS NOT NULL) AND device_type=${SerialCategory.SOIL_MOISTURE} THEN
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
        WHERE (s.s_no =serial_no OR s.id=serial_no)
		and s.type=${SensorType.SINGLE_PLANT_MULTI_SENSOR}
    AND s.status NOT IN (${CommunicationStatus.DELETED}, ${CommunicationStatus.IN_ACTIVE}, ${CommunicationStatus.SEND_RETRY}, ${CommunicationStatus.SEND_FAILED})
		LIMIT 1
		 
      )
	  )
	  FROM public.device AS d 
	  JOIN public.sensor AS s ON s.device_id = d.id
WHERE s.s_no = serial_no OR s.id=serial_no
LIMIT 1;

------------- IF DEVICE TYPE IS WATER LEVEL,TYPE,S_NO ---------------

ELSIF user_mobile_number IS NULL AND (serial_no IS NOT NULL ) AND device_type=${SerialCategory.WATER_LEVEL} THEN
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
        WHERE (s.s_no = serial_no OR s.id=serial_no)
		and s.type=${SensorType.WATER_LEVEL}
    AND s.status NOT IN (${CommunicationStatus.DELETED}, ${CommunicationStatus.IN_ACTIVE}, ${CommunicationStatus.SEND_RETRY}, ${CommunicationStatus.SEND_FAILED})
		LIMIT 1
		 
      )
	  )
	  FROM public.device AS d 
	  JOIN public.sensor AS s ON s.device_id = d.id
WHERE s.s_no = serial_no OR s.id=serial_no
LIMIT 1;

------------- IF DEVICE TYPE IS WEATHER,TYPE,S_NO ---------------

ELSIF user_mobile_number IS NULL AND (serial_no IS NOT NULL) AND device_type=${SerialCategory.WEATHER_STATION} THEN

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
        WHERE (s.s_no = serial_no OR s.id=serial_no)
		and s.type=${SensorType.WEATHER_STATION}
    AND s.status NOT IN (${CommunicationStatus.DELETED}, ${CommunicationStatus.IN_ACTIVE}, ${CommunicationStatus.SEND_RETRY}, ${CommunicationStatus.SEND_FAILED})
		LIMIT 1
		 
      )
	  )
	  FROM public.device AS d 
	  JOIN public.sensor AS s ON s.device_id = d.id
WHERE s.s_no = serial_no OR s.id=serial_no
LIMIT 1;

------------- IF DEVICE TYPE IS IRRIGATION,TYPE,S_NO ---------------
ELSIF user_mobile_number IS NULL AND (serial_no IS NOT NULL) AND device_type=${SerialCategory.IRRIGATION_NODE} THEN
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
                WHERE v.node_id = n.id
                AND v.status NOT IN (${CommunicationStatus.DELETED}, ${CommunicationStatus.IN_ACTIVE}, ${CommunicationStatus.SEND_RETRY}, ${CommunicationStatus.SEND_FAILED})
            
            )
        )
        FROM public.node AS n
        AND n.type =${NodeType.IRRIGATION_NODE}
        AND n.status NOT IN (${CommunicationStatus.DELETED}, ${CommunicationStatus.IN_ACTIVE}, ${CommunicationStatus.SEND_RETRY}, ${CommunicationStatus.SEND_FAILED})
          WHERE (n.s_no = serial_no OR n.id = serial_no)
        LIMIT 1
    )
)
FROM public.device AS d 
JOIN public.node AS n ON n.device_id = d.id 
WHERE n.s_no = serial_no OR n.id = serial_no
LIMIT 1;
------------- IF DEVICE TYPE IS BACKWASH TYPE,S_NO ---------------

ELSIF user_mobile_number IS NULL AND (serial_no IS NOT NULL) AND device_type=${SerialCategory.AUTO_BACKWASH} THEN
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
        WHERE (n.s_no = serial_no OR n.id=serial_no)
        n.type=${NodeType.BACKWASH_NODE}
        n.status NOT IN (${CommunicationStatus.DELETED}, ${CommunicationStatus.IN_ACTIVE}, ${CommunicationStatus.SEND_RETRY}, ${CommunicationStatus.SEND_FAILED})
        LIMIT 1
        )
)
	  FROM public.device AS d 
	  JOIN public.node AS n ON n.device_id = d.id
WHERE n.s_no = serial_no OR n.id=serial_no
LIMIT 1;
 
ELSE
RETURN NULL;
END IF;
END;
$$`;
