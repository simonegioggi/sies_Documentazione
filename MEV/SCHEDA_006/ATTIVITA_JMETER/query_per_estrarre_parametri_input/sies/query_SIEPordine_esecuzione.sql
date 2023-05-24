--SIEPesecuzione_pena.csv
--userid,password,ChiaveSiepAnno,ChiaveSiepProgressivo
(SELECT 'userid,password,ChiaveSiepAnno,ChiaveSiepProgressivo' AS A  FROM DUAL ) 
UNION
SELECT '' || COD_OPERATORE_INSERIMENTO || ',' ||
 'password' || ',' ||
 chiave_anno || ',' || 
 chiave_progr
FROM (
SELECT DISTINCT FF.COD_OPERATORE_INSERIMENTO,
       'password',
       F.chiave_anno,
       F.chiave_progr,
       RANK()  over (partition by FF.cod_operatore_inserimento  order by FF.ID_FASCICOLO_SIEP) as rnk
  FROM V_FASCICOLO_SIEP F, POSIZIONE_GIURIDICA PG, UTENTE UTE,
  fascicolo_siep FF  , EVENTO EV
    WHERE FF.ID_FASCICOLO_SIEP=F.id_fascicolo_siep
    AND F.FLAG_VALIDATO = 'S'      
   AND ((F.CHIAVE_ANNO > 2000) OR (F.CHIAVE_ANNO = 2000 AND F.CHIAVE_PROGR >= 1))
   AND ((F.CHIAVE_ANNO < 2020) OR
       (F.CHIAVE_ANNO = 2020 AND F.CHIAVE_PROGR <= 500))
   AND (F.FLAG_VALIDATO = 'S' OR F.FLAG_VALIDATO IS NULL)
   AND ((F.CHIAVE_PROGR BETWEEN 1 AND 19999))
      -- STATO FASCICOLO VALIDATO
   AND F.cod_stato_fascicolo = '03'
      -- FILTRO SU POSIZIONE GIURIDICA
   AND F.id_fascicolo_siep = PG.FAS_SIE_ID_FASCICOLO_SIEP
   AND PG.COD_POSIZIONE_GIURIDICA =
       (SELECT PG.COD_POSIZIONE_GIURIDICA
          FROM POSIZIONE_GIURIDICA PG
         WHERE PG.FAS_SIE_ID_FASCICOLO_SIEP = F.id_fascicolo_siep
           AND PG.ID_POSIZIONE_GIURIDICA =
               (SELECT MAX(A.ID_POSIZIONE_GIURIDICA)
                  FROM POSIZIONE_GIURIDICA A
                 WHERE A.FAS_SIE_ID_FASCICOLO_SIEP = F.id_fascicolo_siep))
   AND PG.COD_POSIZIONE_GIURIDICA = '03'
      -- CONDIZIONE SU DISTRETTO       
   AND F.cod_distretto = '00127200602' -- TORINO
      ---- NON DEVE ESTRARRE I MIGRATI
   AND FF.COD_OPERATORE_INSERIMENTO NOT LIKE 'res%'
      -- NON DEVE ESTRARRE I provenienti da nsc
   AND FF.COD_OPERATORE_INSERIMENTO NOT LIKE 'nsc%'
      -- utenti senza data fine validita
   AND (UTE.DATA_FINE_VALIDITA IS NULL OR UTE.DATA_FINE_VALIDITA >= SYSDATE)
   AND FF.COD_OPERATORE_INSERIMENTO = UTE.COD_UTENTE
  --AND F.chiave_anno='2013' AND F.chiave_progr='40'
   AND EV.FAS_SIE_ID_FASCICOLO_SIEP=F.ID_FASCICOLO_SIEP
   AND EV.FLAG_DOCUMENTO_REGISTRATO='S' -- eventi validati    
   )
where rnk =1
order by A desc  
