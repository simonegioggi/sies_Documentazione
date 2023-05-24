CREATE OR REPLACE PROCEDURE AGGIORNA_DOMINIO_NAZIONE IS

   
   -- DEFINIZIONE VARIABILI
   V_COD_STATO_TF                   STATO_NAZIONE_TF.COD_STATO_TF%TYPE;
   V_COD_STATO_ISO_TF               STATO_NAZIONE_TF.COD_STATO_ISO_TF%TYPE;
   V_COD_SEDE_GIUDIZIARIA_TF    STATO_NAZIONE_TF.COD_SEDE_GIUDIZIARIA_TF%TYPE;
   V_DESCRIZIONE_TF                    STATO_NAZIONE_TF.DESC_STATO_TF%TYPE;
   V_DATA_FINE_VALIDITA_TF         STATO_NAZIONE_TF.DATA_FINE_VALIDITA_TF%TYPE;
   V_COD_STATO_ISTAT_TF                 STATO_NAZIONE_TF.COD_STATO_ISTAT_TF%TYPE;
   V_COD_CATASTALE_TF               STATO_NAZIONE_TF.COD_CATASTALE_TF%TYPE;

   W_CODICE                          varchar2(6);
   W_FLAG_VALIDITA              varchar2(1);


   letti                  NUMBER;
   inseriti                 NUMBER;
   aggiornati             NUMBER;

   cursore_found          BOOLEAN;

   SUCCESSIVO             EXCEPTION;

   -- Dichiarazione del cursore
   CURSOR CUR_STATO_NAZIONE IS
     SELECT COD_STATO_TF,
            COD_STATO_ISO_TF,
            COD_SEDE_GIUDIZIARIA_TF,
        DESC_STATO_TF,
        DATA_FINE_VALIDITA_TF,
        COD_STATO_ISTAT_TF,
        COD_CATASTALE_TF
       FROM STATO_NAZIONE_TF;

BEGIN

   -- Caricamento tabella W_LOG_CARICAMENTI
   BEGIN
      INSERT
        INTO W_LOG_CARICAMENTI
      VALUES('Inizio Aggiornamento DOMINIO NAZIONE',
              NULL,
              NULL,
              NULL,
              SYSDATE);
   END;

   BEGIN
      INSERT
        INTO W_SCARTI
      VALUES(W_SCA_SEQ.NEXTVAL,
             'AGGIORNA DOMINIO NAZIONE',
              NULL,
              NULL,
              NULL,
             'INIZIO ELABORAZIONE',
              NULL,
              NULL,
              NULL,
              NULL,
              NULL);
   END;
   COMMIT;

   -- Inizializzo contatori
   letti        := 0;
   inseriti       := 0;
   aggiornati   := 0;

   -- APERTURA CURSORE
   OPEN CUR_STATO_NAZIONE;

   -- LETTURA FUORI CICLO DEI DATI DEL COMUNE_TF
   FETCH CUR_STATO_NAZIONE INTO V_COD_STATO_TF,
            V_COD_STATO_ISO_TF,
            V_COD_SEDE_GIUDIZIARIA_TF,
        V_DESCRIZIONE_TF,
        V_DATA_FINE_VALIDITA_TF,
        V_COD_STATO_ISTAT_TF,
        V_COD_CATASTALE_TF;

   cursore_found := CUR_STATO_NAZIONE%FOUND;

   -- INIZIO CICLO DI ESTRAZIONE DATI PER OGNI RECORD RILASCIATO DALLA FETCH
   WHILE cursore_found
    LOOP
     BEGIN -- inizio loop
          DBMS_OUTPUT.PUT_LINE ('fetch fuori ciclo'  || V_COD_STATO_TF || V_DESCRIZIONE_TF);
       letti := letti + 1;
/*--------
          IF ( V_DATA_FINE_VALIDITA_TF  IS NOT NULL )
              THEN
              W_FLAG_VALIDITA := 'N';
              ELSE
          W_FLAG_VALIDITA := 'S';
              END IF;
*/
           BEGIN
         SELECT RV_LOW_VALUE
           INTO W_CODICE
           FROM CG_REF_CODES
          WHERE RV_LOW_VALUE = V_COD_STATO_TF AND RV_DOMAIN = 'NAZIONE';
               BEGIN
                      UPDATE CG_REF_CODES
               SET RV_HIGH_VALUE    = V_COD_STATO_ISO_TF,
                   RV_MEANING      = V_DESCRIZIONE_TF,
                    RV_ABBREVIATION  = V_COD_STATO_ISTAT_TF,
                   RV_ALT2_VALUE = V_COD_CATASTALE_TF,
                    RV_ALT4_VALUE = 'AGG-30032021',
                    RV_ALT3_VALUE = V_DATA_FINE_VALIDITA_TF
                   WHERE RV_LOW_VALUE   = V_COD_STATO_TF AND RV_DOMAIN = 'NAZIONE';
              aggiornati := aggiornati + 1;
          DBMS_OUTPUT.PUT_LINE ('UPDATE NAZIONE'  || V_COD_STATO_TF || V_DESCRIZIONE_TF);
              END;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
        INSERT INTO CG_REF_CODES  VALUES 
               ('NAZIONE',
                 V_COD_STATO_TF,
                 V_COD_STATO_ISO_TF,
                 V_COD_STATO_ISTAT_TF,
                 V_DESCRIZIONE_TF,
                 V_COD_CATASTALE_TF,
                 V_DATA_FINE_VALIDITA_TF,
              'INS-30032021', NULL);


     DBMS_OUTPUT.PUT_LINE ('INSERT NAZIONE'  || V_COD_STATO_TF || V_DESCRIZIONE_TF);
           inseriti := inseriti + 1;

            END;



           END;


          aggiornati := aggiornati + 1;
          BEGIN
            INSERT
              INTO W_SCARTI
            VALUES(W_SCA_SEQ.NEXTVAL,
                   'AGGIORNA NAZIONE',
                    NULL,
                    NULL,
                    NULL,
                   'AGGIORNATO RECORD',
      --             '  - CODICE: '||COD_COMUNE       ||                     'OLD - DESCRIZIONE: '||DESCRIZIONE      || ' - COD_PROVINCIA: '||COD_PROVINCIA,
      --              'NEW - DESCRIZIONE: '||V_DESCRIZIONE_TF      ||  ' - COD_PROVINCIA: '||V_COD_PROVINCIA_TF,
                    'AAAAAAAAA',
                    'BBBBBBBBBB',
                    NULL,
                    NULL,
                    NULL);
          END;
          COMMIT;


      FETCH CUR_STATO_NAZIONE INTO V_COD_STATO_TF,
            V_COD_STATO_ISO_TF,
            V_COD_SEDE_GIUDIZIARIA_TF,
        V_DESCRIZIONE_TF,
        V_DATA_FINE_VALIDITA_TF,
        V_COD_STATO_ISTAT_TF,
        V_COD_CATASTALE_TF;

     cursore_found := CUR_STATO_NAZIONE%FOUND;

   -- CHIUSURA DEL WHILE
   END LOOP;
   
      BEGIN
      INSERT
        INTO W_LOG_CARICAMENTI
      VALUES('Fine Aggiornamento NAZIONE  - letti, inseriti, aggiornati ',
              letti,
              inseriti,
              aggiornati,
              SYSDATE);
   END;
END AGGIORNA_DOMINIO_NAZIONE;


