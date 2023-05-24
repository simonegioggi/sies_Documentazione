CREATE OR REPLACE PROCEDURE AGGIORNA_COMUNI_AVVOCATURA IS

  -----      Aggiornamento Tabella COMUNI (di SIES-AVVOCATURA) in base al contenuto della Tabella COMUNE_TF (import della tabella fornita da DGSIA)
  -----      Le colonne dei  records della tabella già esistenti, cioè con COD_COMUNE = a quello presente nella tabella COMUNE_TF, vengono aggiornate con il contenuto di quest'ultima
  -----      I records della tabella COMUNE_TF, non presenti in COMUNE, vengono inseriti in quest'ultima
  -----

  -- DEFINIZIONE VARIABILI
  V_COD_COMUNE_TF COMUNE_TF.COD_COMUNE_TF%TYPE;
  --V_COD_PROVINCIA_TF               COMUNE_TF.COD_PROVINCIA_TF%TYPE;
  V_COD_SEDE_GIUDIZIARIA_TF COMUNE_TF.COD_SEDE_GIUDIZIARIA_TF%TYPE;
  V_DESCRIZIONE_TF          COMUNE_TF.DESCRIZIONE_TF%TYPE;
  V_DATA_FINE_VALIDITA_TF   COMUNE_TF.DATA_FINE_VALIDITA_TF%TYPE;
  V_CAP_TF                  COMUNE_TF.CAP_TF%TYPE;
  V_COD_CATASTALE_TF        COMUNE_TF.COD_CATASTALE_TF%TYPE;

  W_CODICE             varchar2(6);
  W_FLAG_VALIDITA      varchar2(1);
  W_TIPO_AGGIORNAMENTO varchar2(20);

  letti      NUMBER;
  inseriti   NUMBER;
  aggiornati NUMBER;

  cursore_found BOOLEAN;

  SUCCESSIVO EXCEPTION;

  -- Dichiarazione del cursore
  CURSOR CUR_COMUNE_TF IS
SELECT COMUNE.COD_COMUNE,
       COMUNE.COD_SEDE_GIUDIZIARIA,
       COMUNE.DESCRIZIONE,
       COMUNE.DATA_FINE_VALIDITA_COMUNE,
       COMUNE.CAP,
       COMUNE.COD_CATASTALE_COMUNE
  FROM COMUNE;

BEGIN

  -- Caricamento tabella W_LOG_CARICAMENTI
  BEGIN
    INSERT INTO W_LOG_CARICAMENTI
    VALUES
      ('Inizio Aggiornamento COMUNI ', NULL, NULL, NULL, CURRENT_DATE);
  END;

  BEGIN
    INSERT INTO W_SCARTI
    VALUES
      (W_SCA_SEQ.NEXTVAL,
       'AGGIORNA COMUNI',
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
  --COMMIT;

  -- Inizializzo contatori
  letti                := 0;
  inseriti             := 0;
  aggiornati           := 0;
  w_tipo_aggiornamento := '   ';

  -- APERTURA CURSORE
  OPEN CUR_COMUNE_TF;

  -- LETTURA FUORI CICLO DEI DATI DEL COMUNE_TF
  FETCH CUR_COMUNE_TF
    INTO V_COD_COMUNE_TF,
         V_COD_SEDE_GIUDIZIARIA_TF,
         V_DESCRIZIONE_TF,
         V_DATA_FINE_VALIDITA_TF,
         V_CAP_TF,
         V_COD_CATASTALE_TF;

  cursore_found := CUR_COMUNE_TF%FOUND;

  -- INIZIO CICLO DI ESTRAZIONE DATI PER OGNI RECORD RILASCIATO DALLA FETCH
  WHILE cursore_found LOOP
    BEGIN
      -- inizio loop
      DBMS_OUTPUT.PUT_LINE('fetch fuori ciclo' || V_COD_COMUNE_TF ||
                           V_DESCRIZIONE_TF);
      letti := letti + 1;
    
      IF (V_DATA_FINE_VALIDITA_TF IS NOT NULL) THEN
        W_FLAG_VALIDITA := 'N';
      ELSE
        W_FLAG_VALIDITA := 'S';
      END IF;
    
      BEGIN
        SELECT COMUNI.COD_COMUNE
          INTO W_CODICE
          FROM AVVSIES.COMUNI
         WHERE COMUNI.COD_COMUNE = V_COD_COMUNE_TF;
        BEGIN
          UPDATE AVVSIES.COMUNI
             SET COMUNI.DESCRIZIONE          = V_DESCRIZIONE_TF,
                 COMUNI.CAP                  = V_CAP_TF,
                 COMUNI.COD_SEDE_GIUDIZIARIA = V_COD_SEDE_GIUDIZIARIA_TF,
                 --DATA_CARICAMENTO_REGE = SYSDATE,
                 COMUNI.FLAG_VALIDITA             = W_FLAG_VALIDITA,
                 COMUNI.COD_CATASTALE_COMUNE      = V_COD_CATASTALE_TF,
                 COMUNI.DATA_AGGIORNAMENTO_COMUNE = SYSDATE,
                 COMUNI.DATA_FINE_VALIDITA_COMUNE = V_DATA_FINE_VALIDITA_TF
           WHERE COMUNI.COD_COMUNE = V_COD_COMUNE_TF;
          aggiornati           := aggiornati + 1;
          w_tipo_aggiornamento := 'AGGIORNA_COMUNI';
          --         DBMS_OUTPUT.PUT_LINE ('UPDATE COMUNI'  || V_COD_COMUNE_TF || V_DESCRIZIONE_TF);
        END;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO AVVSIES.COMUNI
          VALUES
            (V_COD_COMUNE_TF,
             V_DESCRIZIONE_TF,
             V_CAP_TF,
             SYSDATE,
             V_COD_SEDE_GIUDIZIARIA_TF,
             W_FLAG_VALIDITA,
             V_COD_CATASTALE_TF,
             SYSDATE,
             V_DATA_FINE_VALIDITA_TF);
        
          --    DBMS_OUTPUT.PUT_LINE ('INSERT COMUNI'  || V_COD_COMUNE_TF || V_DESCRIZIONE_TF);
          inseriti             := inseriti + 1;
          w_tipo_aggiornamento := 'INSERISCE_COMUNI';
          --   RAISE SUCCESSIVO;
        --  WHEN OTHERS THEN
        --   RAISE SUCCESSIVO;
      END;
      --    WHEN OTHERS THEN
    
    END;
  
    BEGIN
      INSERT INTO W_SCARTI
      VALUES
        (W_SCA_SEQ.NEXTVAL,
         'AGGIORNA COMUNI',
         NULL,
         NULL,
         NULL,
         W_TIPO_AGGIORNAMENTO,
         --             '  - CODICE: '||COD_COMUNE       ||                     'OLD - DESCRIZIONE: '||DESCRIZIONE      || ' - COD_PROVINCIA: '||COD_PROVINCIA,
         --              'NEW - DESCRIZIONE: '||V_DESCRIZIONE_TF      ||  ' - COD_PROVINCIA: '||V_COD_PROVINCIA_TF,
         V_COD_COMUNE_TF,
         V_DESCRIZIONE_TF,
         CURRENT_DATE,
         NULL,
         NULL);
    END;
    --COMMIT;
  
    -- END IF;
  
    /*EXCEPTION
      WHEN SUCCESSIVO THEN
           NULL;
      WHEN OTHERS THEN
          NULL;
    END; ----fine loop*/
  
    FETCH CUR_COMUNE_TF
      INTO V_COD_COMUNE_TF,
           V_COD_SEDE_GIUDIZIARIA_TF,
           V_DESCRIZIONE_TF,
           V_DATA_FINE_VALIDITA_TF,
           V_CAP_TF,
           V_COD_CATASTALE_TF;
  
    cursore_found := CUR_COMUNE_TF%FOUND;
  
  -- CHIUSURA DEL WHILE
  END LOOP;

  BEGIN
    INSERT INTO W_LOG_CARICAMENTI
    VALUES
      ('Fine Aggiornamento COMUNI - letti, inseriti, aggiornati ',
       letti,
       inseriti,
       aggiornati,
       CURRENT_DATE);
  END;
END AGGIORNA_COMUNI_AVVOCATURA;