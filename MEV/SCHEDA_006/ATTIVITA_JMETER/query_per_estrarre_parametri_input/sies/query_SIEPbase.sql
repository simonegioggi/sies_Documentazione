(SELECT 'userid,password,distretto,ChiaveSiepAnno,ChiaveSiepProgressivo,TipoUfficio,SedeUfficio,distrettoUffcio' AS A  FROM DUAL ) 
UNION
select  ''|| cod_operatore_inserimento ||','||
             'password'||','||
             COD_DISTRETTO ||','||
             chiave_anno ||','||
             chiave_progr ||','||
             COD_TIPO_UFFICIO ||','||
             DESCR_COMUNE ||','||
             distretto 
from (
      select  f.cod_operatore_inserimento ,
             'password' ,
             U.COD_DISTRETTO ,
             f.chiave_anno ,
             f.chiave_progr ,
             U.COD_TIPO_UFFICIO ,
             UF.DESCR_COMUNE ,
             U.COD_DISTRETTO distretto,
           RANK()  over (partition by f.cod_operatore_inserimento  order by f.ID_FASCICOLO_SIEP) as rnk
        from fascicolo_siep f,
             UFFICIO U,
             UFFICIO_DESCR UF,
             UTENTE UTE,
             EVENTO EV 
       where U.COD_UFFICIO = F.CHIAVE_UFFICIO
         AND UF.COD_UFFICIO = F.CHIAVE_UFFICIO
         AND UF.COD_UFFICIO = U.COD_UFFICIO
         ---- NON DEVE ESTRARRE I MIGRATI
         AND F.COD_OPERATORE_INSERIMENTO NOT LIKE 'res%'
         -- NON DEVE ESTRARRE I provenienti da nsc
         AND F.COD_OPERATORE_INSERIMENTO NOT LIKE 'nsc%'
         and f.cod_operatore_inserimento = UTE.COD_UTENTE
         -- utenti senza data fine validita
         AND (UTE.DATA_FINE_VALIDITA IS NULL OR
             UTE.DATA_FINE_VALIDITA >= SYSDATE)            
         AND f.cod_operatore_inserimento in (SELECT u.COD_UTENTE
            FROM UTENTE_UFFICIO uf, UTENTE u, (SELECT * FROM
            UTENTE_PROFILO pr WHERE pr.PRF_COD_PROFILO <> '90' AND pr.PRF_COD_PROFILO <>
            '99') p WHERE  u.DATA_FINE_VALIDITA is NULL AND
            p.UTE_COD_UTENTE=u.COD_UTENTE AND uf.UTE_COD_UTENTE=u.COD_UTENTE )         
          AND U.COD_DISTRETTO = '00127200602' -- TORINO
          -- fascicoli di classe I    
          AND F.CHIAVE_PROGR BETWEEN 1 AND 19999     
          --
          AND EV.FAS_SIE_ID_FASCICOLO_SIEP=F.ID_FASCICOLO_SIEP
          AND EV.FLAG_DOCUMENTO_REGISTRATO='S' -- eventi validati          
)
 where rnk =1
 order by A desc
