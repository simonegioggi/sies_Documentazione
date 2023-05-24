/*(SELECT 'username,password,codiceFiscale,codDistretto,tipoUfficio,annoSius,numeroSius' AS A FROM DUAL) 
UNION*/
select 'test' || ',' || 'test' || ',' || o.cod_fiscale || ',' ||
       u.cod_ufficio || ',' || u.cod_tipo_ufficio || ',' || f.chiave_anno || ',' ||
       f.chiave_progr as input
  from fascicolo_sius f, avvocato_fascicolo_sius a, avvocato o, ufficio u
 where f.id_fascicolo_sius = a.fas_siu_id_fascicolo_sius
   and o.id_avvocato = a.avv_id_avvocato
   and a.avv_id_avvocato in
       (select x.avv_id_avvocato from avvocato_fascicolo_sius x)
   and o.cod_fiscale is not null
   and f.chiave_ufficio = u.cod_ufficio
   and u.cod_tipo_ufficio in ('UDS'); -- TDS
