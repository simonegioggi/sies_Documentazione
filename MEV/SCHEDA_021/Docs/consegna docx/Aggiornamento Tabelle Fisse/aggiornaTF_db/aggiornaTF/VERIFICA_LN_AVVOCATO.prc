CREATE OR REPLACE PROCEDURE VERIFICA_LN_AVVOCATO IS

   -- DEFINIZIONE VARIABILI

   V_COD_FISCALE                    AVVOCATO_REGINDE_18112020.CODFISC%TYPE;
   V_NOME                    AVVOCATO_REGINDE_18112020.NOME%TYPE;
   V_COGNOME                    AVVOCATO_REGINDE_18112020.COGNOME%TYPE;
   V_DT_NASCITA                    AVVOCATO_REGINDE_18112020.DT_NASCITA%TYPE;
   V_LUOGO_NASCITA                    AVVOCATO_REGINDE_18112020.LUOGO_NASCITA%TYPE;
   V_COD_CATASTALE               COMUNE.COD_CATASTALE_COMUNE%TYPE;

   W_COD_CATASTALE                          varchar2(4);
   W_CODICE_CAT                          varchar2(4);  
   W_COD_COMUNE                          varchar2(6);  
   W_FLAG_VALIDITA              varchar2(1);


   letti                  NUMBER;
   inseriti                 NUMBER;
   aggiornati             NUMBER;

   cursore_found          BOOLEAN;

   SUCCESSIVO             EXCEPTION;

   -- Dichiarazione del cursore
   CURSOR CUR_AVVOCATO IS
     SELECT NOME,
            COGNOME,
            CODFISC,
        DT_NASCITA,
        LUOGO_NASCITA
       FROM AVVOCATO_REGINDE_18112020 where cod_catasto is null;

BEGIN

   -- Caricamento tabella W_LOG_CARICAMENTI
   BEGIN
      INSERT
        INTO W_LOG_CARICAMENTI
      VALUES('Inizio VERIFICA LUOGO NASCITA AVVOCATO REGINDE ',
              NULL,
              NULL,
              NULL,
              SYSDATE);
   END;

   BEGIN
      INSERT
        INTO W_SCARTI
      VALUES(W_SCA_SEQ.NEXTVAL,
             'VERIFICA LN AVVOCATO REGINDE',
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
   OPEN CUR_AVVOCATO;

   -- LETTURA FUORI CICLO DEI DATI DEL AVVOCATO
   FETCH CUR_AVVOCATO INTO V_NOME,
            V_COGNOME,
            V_COD_FISCALE,
        V_DT_NASCITA,
        V_LUOGO_NASCITA;

   cursore_found := CUR_AVVOCATO%FOUND;

   -- INIZIO CICLO DI ESTRAZIONE DATI PER OGNI RECORD RILASCIATO DALLA FETCH
   WHILE cursore_found
    LOOP
     BEGIN -- inizio loop
--          DBMS_OUTPUT.PUT_LINE ('fetch fuori ciclo'  || V_COD_FISCALE || V_LUOGO_NASCITA);
       letti := letti + 1;

          IF ( V_COD_FISCALE IS NOT NULL )
              THEN
              W_COD_CATASTALE := SUBSTR(V_COD_FISCALE,12,4);
              ELSE
          W_COD_CATASTALE := '    ';
              END IF;
   -- DBMS_OUTPUT.PUT_LINE ('CODICE FISCALE  '  || '  ' || V_COD_FISCALE || '    ' || W_COD_CATASTALE);

           BEGIN
           SELECT COD_CATASTALE_COMUNE, COD_COMUNE
           INTO W_CODICE_CAT, W_COD_COMUNE
           FROM COMUNE
           WHERE COD_CATASTALE_COMUNE = W_COD_CATASTALE AND rownum = 1;
               BEGIN
                      UPDATE AVVOCATO_REGINDE_18112020
               SET COD_CATASTO    = W_CODICE_CAT,
                    COD_COMUNE = W_COD_COMUNE
                   WHERE CODFISC   = V_COD_FISCALE;
              aggiornati := aggiornati + 1;
    --      DBMS_OUTPUT.PUT_LINE ('UPDATE AVVOCATO  '  || V_NOME || '  ' || V_COGNOME || '   ' || V_COD_FISCALE);
              END;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN

     DBMS_OUTPUT.PUT_LINE ('CODICE CATASTALE NON TROVATO   '  || V_COGNOME || '  ' || V_COD_FISCALE || '     '  || W_COD_CATASTALE);
           inseriti := inseriti + 1;
          BEGIN
            INSERT
              INTO W_SCARTI
            VALUES(W_SCA_SEQ.NEXTVAL,
                   'AGGIORNA AVVOCATO',
                    letti,
                    NULL,
                    NULL,
                   'RECORD NON AGGIORNATO',
      --             '  - CODICE: '||COD_COMUNE       ||                     'OLD - DESCRIZIONE: '||DESCRIZIONE      || ' - COD_PROVINCIA: '||COD_PROVINCIA,
      --              'NEW - DESCRIZIONE: '||V_DESCRIZIONE_TF      ||  ' - COD_PROVINCIA: '||V_COD_PROVINCIA_TF,
                    V_COD_FISCALE,
                    W_COD_CATASTALE,
                    NULL,
                    NULL,
                    NULL);
          END;
            END;

           END;



     --     aggiornati := aggiornati + 1;

          COMMIT;



   FETCH CUR_AVVOCATO INTO V_NOME,
            V_COGNOME,
            V_COD_FISCALE,
        V_DT_NASCITA,
        V_LUOGO_NASCITA;

     cursore_found := CUR_AVVOCATO%FOUND;

   -- CHIUSURA DEL WHILE
   END LOOP;
   
      BEGIN
      INSERT
        INTO W_LOG_CARICAMENTI
      VALUES('Fine Aggiornamento AVVOCATO  - letti, inseriti, aggiornati ',
              letti,
              inseriti,
              aggiornati,
              SYSDATE);
   END;
END VERIFICA_LN_AVVOCATO;
