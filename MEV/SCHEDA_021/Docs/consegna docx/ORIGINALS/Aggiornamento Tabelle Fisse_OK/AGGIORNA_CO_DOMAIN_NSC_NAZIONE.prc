CREATE OR REPLACE PROCEDURE AGGIORNA_CO_DOMAIN_NSC_NAZIONE  IS

--  Aggiorna i records della tabella CODICI_SIES_NSC con CO_DOMAIN = 'NAZIONE' in base ai corrispondenti records presenti nella tabella CG_REF_CODES con RV_DOMAIN = 'NAZIONE'
--
   
   -- DEFINIZIONE VARIABILI
   V_COD_NAZIONE                           CG_REF_CODES.RV_LOW_VALUE%TYPE;
   V_DESCRIZIONE                    CG_REF_CODES.RV_MEANING%TYPE;

   W_CODICE                          varchar2(6);
   W_FLAG_VALIDITA              varchar2(1);


   letti                  NUMBER;
   inseriti                 NUMBER;
   aggiornati             NUMBER;

   cursore_found          BOOLEAN;

   SUCCESSIVO             EXCEPTION;

   -- Dichiarazione del cursore
   CURSOR CUR_NAZIONE  IS
     SELECT RV_LOW_VALUE,
        RV_MEANING
       FROM CG_REF_CODES  WHERE RV_DOMAIN = 'NAZIONE' ;

BEGIN

   -- Caricamento tabella W_LOG_CARICAMENTI
   BEGIN
      INSERT
        INTO W_LOG_CARICAMENTI
      VALUES('Inizio Aggiornamento NAZIONE_SIES_NSC',
              NULL,
              NULL,
              NULL,
              SYSDATE);
   END;

   BEGIN
      INSERT
        INTO W_SCARTI
      VALUES(W_SCA_SEQ.NEXTVAL,
             'AGGIORNA CO_DOMAIN  NAZIONE',
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
   OPEN CUR_NAZIONE;

   -- LETTURA FUORI CICLO DEI DATI DEL COMUNE_TF
   FETCH CUR_NAZIONE INTO V_COD_NAZIONE,
        V_DESCRIZIONE;

   cursore_found := CUR_NAZIONE%FOUND;

   -- INIZIO CICLO DI ESTRAZIONE DATI PER OGNI RECORD RILASCIATO DALLA FETCH
   WHILE cursore_found
    LOOP
     BEGIN -- inizio loop
          DBMS_OUTPUT.PUT_LINE ('fetch fuori ciclo'  || V_COD_NAZIONE || V_DESCRIZIONE);
       letti := letti + 1;


           BEGIN
         SELECT CO_SIES
           INTO W_CODICE
           FROM CODICI_SIES_NSC
          WHERE CO_SIES = V_COD_NAZIONE AND CO_DOMAIN = 'NAZIONE';
               BEGIN
                      UPDATE CODICI_SIES_NSC
               SET CO_SIES_DES    = V_DESCRIZIONE,
                    CO_VAL1 = 'AGG-30032021'
                   WHERE CO_SIES = V_COD_NAZIONE  AND CO_DOMAIN = 'NAZIONE';
              aggiornati := aggiornati + 1;
          DBMS_OUTPUT.PUT_LINE ('UPDATE CO_NAZIONE'  || V_COD_NAZIONE || V_DESCRIZIONE);
              END;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
        INSERT INTO CODICI_SIES_NSC  VALUES 
               ('NAZIONE',
                 V_COD_NAZIONE,
                 '-',
                 V_DESCRIZIONE, 
                 V_COD_NAZIONE,
                 V_DESCRIZIONE,
                 'INS-30032021', NULL,NULL);


     DBMS_OUTPUT.PUT_LINE ('INSERT CO-NAZIONE'  || V_COD_NAZIONE || V_DESCRIZIONE);
           inseriti := inseriti + 1;
           --   RAISE SUCCESSIVO;
           --  WHEN OTHERS THEN
           --   RAISE SUCCESSIVO;
            END;

           END;


          aggiornati := aggiornati + 1;
          BEGIN
            INSERT
              INTO W_SCARTI
            VALUES(W_SCA_SEQ.NEXTVAL,
                   'AGGIORNA CO-NAZIONE',
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



      FETCH CUR_NAZIONE  INTO V_COD_NAZIONE,
        V_DESCRIZIONE;

     cursore_found := CUR_NAZIONE%FOUND;

   -- CHIUSURA DEL WHILE
   END LOOP;
   
      BEGIN
      INSERT
        INTO W_LOG_CARICAMENTI
      VALUES('Fine Aggiornamento CO_NAZIONE  - letti, inseriti, aggiornati ',
              letti,
              inseriti,
              aggiornati,
              SYSDATE);
   END;
end;
   -- CHIUSURA CURSORE
/