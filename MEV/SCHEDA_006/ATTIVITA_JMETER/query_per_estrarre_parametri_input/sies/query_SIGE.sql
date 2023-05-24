(SELECT 'userid,password,ChiaveSiepAnno,ChiaveSiepProgressivo,TipoUfficio,SedeUfficio' AS A  FROM DUAL ) 
UNION
(
SELECT '' || COD_OPERATORE_INSERIMENTO || ',' ||
 'password' || ',' ||
 chiave_anno || ',' || 
 chiave_progr || ',' || 
 cod_tipo_ufficio|| ',' || 
 DESCR_COMUNE
  from (
SELECT F.COD_OPERATORE_INSERIMENTO, --OPERATORE INSERIMENTO DEL FASCICOLO SIGE
       siep.CHIAVE_ANNO, -- ANNO FASCICOLO SIEP
       siep.chiave_progr ,   -- NUMERO FASCICOLO SIEP
       uu.cod_tipo_ufficio,  -- tipo ufficio che ha iscritto il siep
       UD.DESCR_COMUNE,       -- SEDE ufficio che ha iscritto il siep
       RANK()  over (partition by f.cod_operatore_inserimento  order by f.id_fascicolo_sige) as rnk
  FROM FASCICOLO_SIGE F,
       SOGGETTO       S,
       RICHIESTA_SIGE R,
       CG_REF_CODES   TRS,
       UFFICIO        U,
       COMUNE         C,
       fascicolo_siep siep,
       ufficio   UU,
       UFFICIO_DESCR UD
 WHERE f.SOG_ID_SOGGETTO = ID_SOGGETTO
   AND U.COD_UFFICIO = F.CHIAVE_UFFICIO
   AND U.COD_COMUNE = C.COD_COMUNE
   AND F.RIC_ID_RICHIESTA_SIGE = R.ID_RICHIESTA_SIGE
   AND TRS.RV_LOW_VALUE = R.COD_TIPO_ATTO
   AND TRS.RV_DOMAIN = 'TIPO_ATTO_SIGE'  
   AND TO_CHAR(f.DATA_ISCRIZIONE, 'YYYYMMDD') >= '20000101'
   AND TO_CHAR(f.DATA_ISCRIZIONE, 'YYYYMMDD') <= '20200531'
   AND TO_CHAR(f.DATA_ISCRIZIONE, 'YYYYMMDD') <= 'null'
   and r.fas_sie_id_fascicolo_siep is not null
   and r.fas_sie_id_fascicolo_siep=siep.id_fascicolo_siep
    AND f.COD_OPERATORE_INSERIMENTO IN
                (SELECT U.COD_UTENTE
                   FROM UTENTE_UFFICIO UF,
                        UTENTE U,
                        (SELECT *
                           FROM UTENTE_PROFILO PR
                          WHERE PR.PRF_COD_PROFILO <> '90'
                            AND PR.PRF_COD_PROFILO <> '99') P
                  WHERE U.DATA_FINE_VALIDITA IS NULL
                    AND P.UTE_COD_UTENTE = U.COD_UTENTE
                    AND UF.UTE_COD_UTENTE = U.COD_UTENTE)    
          AND F.COD_OPERATORE_INSERIMENTO  LIKE 'T%'
          AND UU.COD_UFFICIO = siep.chiave_ufficio
          AND UD.COD_UFFICIO = siep.chiave_ufficio
              -- CONDIZIONE SU DISTRETTO       
          AND UU.cod_distretto = '00127200602' -- TORINO
          AND ((SIEP.CHIAVE_PROGR BETWEEN 1 AND 19999))        
)
  WHERE RNK = 1  )
  order by A desc
