CREATE OR REPLACE PROCEDURE AGGIORNA_DOMINIO_PROVINCIA IS

   
   -- DEFINIZIONE VARIABILI
   V_COD_PROVINCIA                   PROVINCIA_TF.COD_PROVINCIA_TF%TYPE;
   V_COD_REGIONE                      PROVINCIA_TF.COD_REGIONE_TF%TYPE;
   V_DESCRIZIONE                       PROVINCIA_TF.DESC_PROVINCIA_TF%TYPE;
   V_FINE_VALIDITA                     PROVINCIA_TF.FINE_VALIDITA_TF%TYPE;


   W_CODICE                          varchar2(6);
   W_FLAG_VALIDITA              varchar2(2);


   letti                  NUMBER;
   inseriti                 NUMBER;
   aggiornati             NUMBER;

   cursore_found          BOOLEAN;

   SUCCESSIVO             EXCEPTION;

   -- Dichiarazione del cursore
   CURSOR CUR_PROVINCIA IS
     SELECT COD_PROVINCIA_TF,
                COD_REGIONE_TF,
                DESC_PROVINCIA_TF,
                FINE_VALIDITA_TF
                FROM PROVINCIA_TF;

BEGIN

   -- Caricamento tabella W_LOG_CARICAMENTI
   BEGIN
      INSERT
        INTO W_LOG_CARICAMENTI
      VALUES('Inizio Aggiornamento DOMINIO PROVINCIA',
              NULL,
              NULL,
              NULL,
              SYSDATE);
   END;

   BEGIN
      INSERT
        INTO W_SCARTI
      VALUES(W_SCA_SEQ.NEXTVAL,
             'AGGIORNA DOMINIO PROVINCIA',
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
   OPEN CUR_PROVINCIA;

   -- LETTURA FUORI CICLO DEI DATI DEL COMUNE_TF
   FETCH CUR_PROVINCIA INTO V_COD_PROVINCIA,
            V_COD_REGIONE,
            V_DESCRIZIONE,
            V_FINE_VALIDITA;

   cursore_found := CUR_PROVINCIA%FOUND;

   -- INIZIO CICLO DI ESTRAZIONE DATI PER OGNI RECORD RILASCIATO DALLA FETCH
   WHILE cursore_found
    LOOP
     BEGIN -- inizio loop
          DBMS_OUTPUT.PUT_LINE ('fetch fuori ciclo'  || V_COD_PROVINCIA || V_DESCRIZIONE);
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
          WHERE RV_LOW_VALUE = V_COD_PROVINCIA AND RV_DOMAIN = 'PROVINCIA';
               BEGIN
                      UPDATE CG_REF_CODES
               SET RV_HIGH_VALUE    = V_COD_REGIONE,
                   RV_MEANING      = V_DESCRIZIONE,
                    RV_ABBREVIATION  = V_FINE_VALIDITA,
                    RV_ALT2_VALUE = 'AGG-30032021'
                   WHERE RV_LOW_VALUE   = V_COD_PROVINCIA AND RV_DOMAIN = 'PROVINCIA';
              aggiornati := aggiornati + 1;
          DBMS_OUTPUT.PUT_LINE ('UPDATE PROVINCIA'  || V_COD_PROVINCIA || V_DESCRIZIONE);
              END;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
        INSERT INTO CG_REF_CODES  VALUES 
               ('PROVINCIA',
                 V_COD_PROVINCIA,
                 V_COD_REGIONE,
                 V_FINE_VALIDITA,
                 V_DESCRIZIONE,
                 'INS-30032021', NULL, NULL, NULL);


     DBMS_OUTPUT.PUT_LINE ('INSERT PROVINCIA'  || V_COD_PROVINCIA || V_DESCRIZIONE);
           inseriti := inseriti + 1;
           --   RAISE SUCCESSIVO;
           --  WHEN OTHERS THEN
           --   RAISE SUCCESSIVO;
            END;
 --    WHEN OTHERS THEN


           END;



          aggiornati := aggiornati + 1;
          BEGIN
            INSERT
              INTO W_SCARTI
            VALUES(W_SCA_SEQ.NEXTVAL,
                   'AGGIORNA PROVINCIA',
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

      FETCH CUR_PROVINCIA INTO V_COD_PROVINCIA,
            V_COD_REGIONE,
            V_DESCRIZIONE,
            V_FINE_VALIDITA;

     cursore_found := CUR_PROVINCIA%FOUND;

   -- CHIUSURA DEL WHILE
   END LOOP;
   
      BEGIN
      INSERT
        INTO W_LOG_CARICAMENTI
      VALUES('Fine Aggiornamento PROVINCIA  - letti, inseriti, aggiornati ',
              letti,
              inseriti,
              aggiornati,
              SYSDATE);
   END;
END AGGIORNA_DOMINIO_PROVINCIA;
