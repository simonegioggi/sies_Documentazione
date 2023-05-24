CREATE OR REPLACE PROCEDURE VERIFICA_LN_AVVOCATO_3  IS

   -----  Valorizzazione cod_catastale sulla tabella AVVOCATO_REGINDE per i nati all'estero, recuperandolo dal valore di RV_ALT2_VALUE per il dominio NAZIONE
   -----      procedura da eseguire dopo l'aggiornamento del dominio in base al contenuto della tabella STATO_NAZIONE arricchita dei codici catastali degli stati esteri
   -------
   
   -- DEFINIZIONE VARIABILI

   V_COD_FISCALE                    AVVOCATO_REGINDE_18112020.CODFISC%TYPE;
   V_NOME                    AVVOCATO_REGINDE_18112020.NOME%TYPE;
   V_COGNOME                    AVVOCATO_REGINDE_18112020.COGNOME%TYPE;
   V_DT_NASCITA                    AVVOCATO_REGINDE_18112020.DT_NASCITA%TYPE;
   V_LUOGO_NASCITA                    AVVOCATO_REGINDE_18112020.LUOGO_NASCITA%TYPE;
   V_COD_CATASTALE               COMUNE.COD_CATASTALE_COMUNE%TYPE;

   W_COD_CATASTALE                   varchar2(4);
   W_CODICE_CAT                          varchar2(4);  
   W_COD_COMUNE                        varchar2(6);
   W_CODICE_STATO                      varchar2(3);    
   W_FLAG_VALIDITA                      varchar2(1);
   lunghezza                                   varchar2(1);
   N_COD_CATASTALE                     varchar2(4);


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
       FROM AVVOCATO_REGINDE_18112020 where COD_CATASTO is null AND SUBSTR(CODFISC,12,1) = 'Z';
  --     and ( CODFISC = 'PVNFNZ76H12Z112P' or CODFISC = 'BNDSMN88L50Z133L' or CODFISC = 'PNGMLE75E23Z133W' or CODFISC = 'LRSCLD74A29Z133S');

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
--   DBMS_OUTPUT.PUT_LINE ('CODICE FISCALE  '  || '  ' || V_COD_FISCALE || '    ' || W_COD_CATASTALE);
   SELECT LENGTH(TRIM(TRANSLATE(W_COD_CATASTALE, ' +-.0123456789',' '))) into lunghezza FROM dual;
--      DBMS_OUTPUT.PUT_LINE ('LENGTH  '  || '  ' || lunghezza);
      IF ( lunghezza > 1) AND substr(W_COD_CATASTALE, 1, 1)  IN ( 'Z')
         THEN
  -- sostituire gli ultimi 3 caratteri del codice catastele con    0 = L   |   1 = M   |   2 = N   |   3 = P   |   4 = Q
  --                                                                              5 = R  |    6 = S   |   7 = T   |   8 = U   |   9 = V
    --- sostituisco secondo carattere del codice catastale estratto dal codice fiscale
  select Substr(W_COD_CATASTALE, 1, 1) ||Replace(Substr(W_COD_CATASTALE, 2, 1), 'L', '0') ||Substr(W_COD_CATASTALE, 3)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE,1, 1) ||Replace(Substr(W_COD_CATASTALE, 2, 1), 'M', '1') ||Substr(W_COD_CATASTALE, 3)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE,1, 1) ||Replace(Substr(W_COD_CATASTALE, 2, 1), 'N', '2') ||Substr(W_COD_CATASTALE, 3)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 1) ||Replace(Substr(W_COD_CATASTALE, 2, 1), 'P', '3') ||Substr(W_COD_CATASTALE,3)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE,1, 1) ||Replace(Substr(W_COD_CATASTALE, 2, 1), 'Q', '4') ||Substr(W_COD_CATASTALE, 3)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE,1, 1) ||Replace(Substr(W_COD_CATASTALE, 2, 1), 'R', '5') ||Substr(W_COD_CATASTALE, 3)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE,1, 1) ||Replace(Substr(W_COD_CATASTALE, 2, 1), 'S', '6') ||Substr(W_COD_CATASTALE, 3)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE,1, 1) ||Replace(Substr(W_COD_CATASTALE, 2, 1), 'T', '7') ||Substr(W_COD_CATASTALE, 3)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE,1, 1) ||Replace(Substr(W_COD_CATASTALE, 2, 1), 'U', '8') ||Substr(W_COD_CATASTALE, 3)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 1) ||Replace(Substr(W_COD_CATASTALE, 2, 1), 'V', '9') ||Substr(W_COD_CATASTALE,3)  into W_COD_CATASTALE from dual;
   DBMS_OUTPUT.PUT_LINE ('N_COD_CATASTALE - 2 '  || '  ' ||W_COD_CATASTALE);
    --- sostituisco terzo carattere del codice catastale estratto dal codice fiscale
  select Substr(W_COD_CATASTALE, 1, 2) ||Replace(Substr(W_COD_CATASTALE, 3, 1), 'L', '0') ||Substr(W_COD_CATASTALE, 4)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 2) ||Replace(Substr(W_COD_CATASTALE, 3, 1), 'M', '1') ||Substr(W_COD_CATASTALE, 4)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 2) ||Replace(Substr(W_COD_CATASTALE, 3, 1), 'N', '2') ||Substr(W_COD_CATASTALE, 4)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 2) ||Replace(Substr(W_COD_CATASTALE, 3, 1), 'P', '3') ||Substr(W_COD_CATASTALE, 4)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 2) ||Replace(Substr(W_COD_CATASTALE, 3, 1), 'Q', '4') ||Substr(W_COD_CATASTALE, 4)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 2) ||Replace(Substr(W_COD_CATASTALE, 3, 1), 'R', '5') ||Substr(W_COD_CATASTALE, 4)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 2) ||Replace(Substr(W_COD_CATASTALE, 3, 1), 'S', '6') ||Substr(W_COD_CATASTALE, 4)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 2) ||Replace(Substr(W_COD_CATASTALE, 3, 1), 'T', '7') ||Substr(W_COD_CATASTALE, 4)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 2) ||Replace(Substr(W_COD_CATASTALE, 3, 1), 'U', '8') ||Substr(W_COD_CATASTALE, 4)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 2) ||Replace(Substr(W_COD_CATASTALE, 3, 1), 'V', '9') ||Substr(W_COD_CATASTALE, 4)  into W_COD_CATASTALE from dual;
     DBMS_OUTPUT.PUT_LINE ('N_COD_CATASTALE - 3 '  || '  ' ||W_COD_CATASTALE);
  --- sostituisco quarto carattere del codice catastale estratto dal codice fiscale
  select Substr(W_COD_CATASTALE, 1, 3) ||Replace(Substr(W_COD_CATASTALE, 4, 1), 'L', '0') ||Substr(W_COD_CATASTALE, 5)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 3) ||Replace(Substr(W_COD_CATASTALE, 4, 1), 'M', '1') ||Substr(W_COD_CATASTALE, 5)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 3) ||Replace(Substr(W_COD_CATASTALE, 4, 1), 'N', '2') ||Substr(W_COD_CATASTALE, 5)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 3) ||Replace(Substr(W_COD_CATASTALE, 4, 1), 'P', '3') ||Substr(W_COD_CATASTALE, 5)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 3) ||Replace(Substr(W_COD_CATASTALE, 4, 1), 'Q', '4') ||Substr(W_COD_CATASTALE, 5)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 3) ||Replace(Substr(W_COD_CATASTALE, 4, 1), 'R', '5') ||Substr(W_COD_CATASTALE, 5)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 3) ||Replace(Substr(W_COD_CATASTALE, 4, 1), 'S', '6') ||Substr(W_COD_CATASTALE, 5)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 3) ||Replace(Substr(W_COD_CATASTALE, 4, 1), 'T', '7') ||Substr(W_COD_CATASTALE, 5)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 3) ||Replace(Substr(W_COD_CATASTALE, 4, 1), 'U', '8') ||Substr(W_COD_CATASTALE, 5)  into W_COD_CATASTALE from dual;
  select Substr(W_COD_CATASTALE, 1, 3) ||Replace(Substr(W_COD_CATASTALE, 4, 1), 'V', '9') ||Substr(W_COD_CATASTALE, 5)  into W_COD_CATASTALE from dual;
      DBMS_OUTPUT.PUT_LINE ('N_COD_CATASTALE -  4'  || '  ' ||W_COD_CATASTALE);
      ELSE 
      DBMS_OUTPUT.PUT_LINE ('W_COD_CATASTALE - 5 '  || '  ' ||W_COD_CATASTALE);
          N_COD_CATASTALE := W_COD_CATASTALE;
      END IF;
          BEGIN
          SELECT COD_STATO_TF
           INTO W_CODICE_STATO
           FROM STATO_NAZIONE_TF
           WHERE COD_CATASTALE_TF = W_COD_CATASTALE AND rownum = 1;
               BEGIN
                      UPDATE AVVOCATO_REGINDE_18112020
               SET COD_CATASTO    = W_COD_CATASTALE,
                    COD_NAZIONE = W_CODICE_STATO
                   WHERE CODFISC   = V_COD_FISCALE;
              aggiornati := aggiornati + 1;
          DBMS_OUTPUT.PUT_LINE ('UPDATE AVVOCATO  '  || V_NOME || '  ' || V_COGNOME || '   ' || V_COD_FISCALE);
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
END VERIFICA_LN_AVVOCATO_3;


