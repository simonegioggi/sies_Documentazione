CREATE OR REPLACE PROCEDURE VALORIZZA_CO_DOMAIN_NSC_COMUNE IS

   -- VALORIZZA I CAMPI CO_CODCENTR, CO_NSC, CO_DES_NSC PER I RECORDS INSERITI EX-NOVO 
   --
   -- DEFINIZIONE VARIABILI
   V_CO_SIES                           CODICI_SIES_NSC.CO_SIES%TYPE;
   V_CO_CODCENTR                          CODICI_SIES_NSC.CO_CODCENTR%TYPE;
   V_CO_NSC                           CODICI_SIES_NSC.CO_NSC%TYPE;
   V_CO_NSC_DES                           CODICI_SIES_NSC.CO_NSC_DES%TYPE;
    V_CO_SIES_DES                           CODICI_SIES_NSC.CO_SIES_DES%TYPE;


   W_CODICE                          varchar2(6);
   W_FLAG_VALIDITA              varchar2(1);


   letti                  NUMBER;
   inseriti                 NUMBER;
   aggiornati             NUMBER;

   cursore_found          BOOLEAN;

   SUCCESSIVO             EXCEPTION;

   -- Dichiarazione del cursore
   CURSOR CUR_CODICI_SN  IS
     SELECT CO_SIES,
       CO_SIES_DES
       FROM CODICI_SIES_NSC  WHERE CO_DOMAIN = 'COMUNE' AND CO_NSC = '-' ;

BEGIN 
   -- Caricamento tabella W_LOG_CARICAMENTI
   BEGIN
      INSERT
        INTO W_LOG_CARICAMENTI
      VALUES('Inizio Aggiornamento COMUNE_SIES_NSC',
              NULL,
              NULL,
              NULL,
              SYSDATE);
   END;

   BEGIN
      INSERT
        INTO W_SCARTI
      VALUES(W_SCA_SEQ.NEXTVAL,
             'AGGIORNA CO_DOMAIN  COMUNE',
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
   OPEN CUR_CODICI_SN;

   -- LETTURA FUORI CICLO DEI DATI DEL COMUNE_TF
   FETCH CUR_CODICI_SN INTO V_CO_SIES,
        V_CO_SIES_DES;

   cursore_found := CUR_CODICI_SN%FOUND;

   -- INIZIO CICLO DI ESTRAZIONE DATI PER OGNI RECORD RILASCIATO DALLA FETCH
   WHILE cursore_found
    LOOP
     BEGIN -- inizio loop
          DBMS_OUTPUT.PUT_LINE ('fetch fuori ciclo'  || V_CO_SIES || V_CO_SIES_DES);
       letti := letti + 1;

           BEGIN
         SELECT CO_CODCENTR, CO_NSC, CO_NSC_DES
           INTO  V_CO_CODCENTR, V_CO_NSC, V_CO_NSC_DES
           FROM CODICI_SIES_NSC
          WHERE CO_SIES_DES = V_CO_SIES_DES  AND CO_DOMAIN = 'COMUNE' AND CO_NSC <> '-' AND CO_VAL1 = 'AGG-30032021';

               BEGIN
                      UPDATE CODICI_SIES_NSC
               SET CO_CODCENTR    = V_CO_CODCENTR,
                    CO_NSC = V_CO_NSC, CO_NSC_DES = V_CO_NSC_DES
                   WHERE CO_NSC ='-' AND CO_CODCENTR = V_CO_SIES  AND CO_DOMAIN = 'COMUNE';
              aggiornati := aggiornati + 1;
          DBMS_OUTPUT.PUT_LINE ('UPDATE CO-COMUNE'  || V_CO_SIES || V_CO_SIES_DES || V_CO_CODCENTR || V_CO_NSC || V_CO_NSC_DES);
              END;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
                       aggiornati := aggiornati + 1;



     -- DBMS_OUTPUT.PUT_LINE ('INSERT CO-COMUNE'  || V_COD_COMUNE || V_DESCRIZIONE);
           inseriti := inseriti + 1;

            END;

           END;



          aggiornati := aggiornati + 1;
          BEGIN
            INSERT
              INTO W_SCARTI
            VALUES(W_SCA_SEQ.NEXTVAL,
                   'AGGIORNA CO-COMUNE',
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

   FETCH CUR_CODICI_SN INTO V_CO_SIES,
        V_CO_SIES_DES;

     cursore_found := CUR_CODICI_SN%FOUND;

   -- CHIUSURA DEL WHILE
   END LOOP;
   
      BEGIN
      INSERT
        INTO W_LOG_CARICAMENTI
      VALUES('Fine Aggiornamento CO_OMUNE  - letti, inseriti, aggiornati ',
              letti,
              inseriti,
              aggiornati,
              SYSDATE);
   END;
end;
   -- CHIUSURA CURSORE
/