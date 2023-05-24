-- SIES: 
select c.rv_low_value, c.rv_meaning, c.rv_alt2_value
  from cg_ref_codes c
 where c.rv_domain = 'NAZIONE'
   and (c.rv_alt2_value in ('Z135','Z518','Z500','Z501','Z400','Z113','Z508','Z706','Z221','Z108','Z513','Z403','Z324','Z122','Z714','Z703',	'Z722','Z609','Z525','Z231','Z729','Z339','Z520','Z710','Z340','Z725','Z530','Z529','Z160','Z907')
    or c.rv_low_value in ('925','940'))
   and c.rv_low_value NOT in ('926')
 order by 1;

-- NSC
select *
  from dc_tab_stato_estero e
 where e.codice_univoco is null
   and (e.data_fine >= sysdate or e.data_fine is null)
   and e.codi_stato not in (09600000,09640064,09600002)
   and e.codi_iso is not null
 order by 1;