select * from CG_REF_CODES t
where t.rv_domain = 'OGGETTO_PROCEDIMENTO'
and t.rv_low_value in ('C029', 'C036', 'U023', 'U077', 'U082', 'U088', 'U089')

/*'U024','U064','U065','U066','U112'*/ -- Eliminati perché non sono di interesse per il SIEP.
--**************

select * from CG_REF_CODES t
where t.rv_domain = 'MOTIVO_PROVVEDIMENTO'
AND t.rv_high_value in ('C029', 'C036', 'U023', 'U077', 'U082', 'U088', 'U089')

/*'U024','U064','U065','U066','U112'*/ -- Eliminati perché non sono di interesse per il SIEP.
--**************
select * from EVENTO t
where t.cod_tipo_provvedimento in ('02','03')
and t.cod_motivo in ('0258','0259','0260','0428','0429','0430','0431','0432','0433','2110',
'2111','2112','2113','2114','2550','2551','2552','2553','2554','2555','2660','2670','2404',
'2405','2406','2407','2409','2408','2422','2416','2610','2611','2612','2613','2614','2615',
'2415','2413','2414','2401')
/*'2348','2349','2350','2351','2352','2353','2354','2355','2356','2357','2358','2359'*/ -- Cod. legati al contenuto U024
/*'2410','2411','2412'*/ -- Cod. legati al contenuto U064
/*'2420','2421'*/ -- Cod. legati al contenuto U065
/*'2430'*/ -- Cod. legati al contenuto U066
/*'9055','9066'*/ -- Cod. legati al contenuto U112
--**************

select * from CG_REF_CODES t
where t.rv_domain = 'ESITO_PROVVEDIMENTO'
and (upper(t.rv_meaning) like upper('%misur%')
or upper(t.rv_meaning) like upper('%m.s%'))
and t.rv_low_value not in ('0017','0018','0009','0077','0076')
