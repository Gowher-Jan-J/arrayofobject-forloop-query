DROP FUNCTION get_device_detail(bigint,int,text)
select*from get_device_detail(null::bigint,0::int,'c1d67757-f793-4993-adb4-2399e8ed91ea'::text)
select*from public.motor where device_id='c1d67757-f793-4993-adb4-2399e8ed91ea'
select*from public.sensor where device_id='c1d67757-f793-4993-adb4-2399e8ed91ea' and status not in(0,7,4,3)
select*from public.node where device_id='c1d67757-f793-4993-adb4-2399e8ed91ea' and status not in(0,7,4,3)
select*from public.device where id='c1d67757-f793-4993-adb4-2399e8ed91ea'
select*from public.sensor where id='NsqViaGPgc'