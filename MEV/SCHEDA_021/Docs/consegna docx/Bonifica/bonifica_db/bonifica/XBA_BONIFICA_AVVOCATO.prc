CREATE OR REPLACE PROCEDURE XBA_BONIFICA_AVVOCATO IS

    -- variabili per la FETCH del CURSORE di XBA_AVVOCATI_CON_PENDENZE.
    V_ID_AVVOCATO                    XBA_AVVOCATI_CON_PENDENZE.ID_AVVOCATO%TYPE;
    V_PEC                            XBA_AVVOCATI_CON_PENDENZE.PEC%TYPE;
    V_FLAG_REGINDE                    XBA_AVVOCATI_CON_PENDENZE.FLAG_REGINDE%TYPE;
    V_ID_AVV_CERT_REGINDE            XBA_AVVOCATI_CON_PENDENZE.ID_AVV_CERT_REGINDE%TYPE;
    V_AMBIENTE                        XBA_AVVOCATI_CON_PENDENZE.AMBIENTE%TYPE;
    V_DESCR_COMUNE_STUDIO            XBA_AVVOCATI_CON_PENDENZE.DESCR_COMUNE_STUDIO%TYPE; 
    V_COD_STATO_NASCITA_AVV         XBA_AVVOCATI_CON_PENDENZE.COD_STATO_NASCITA_AVV%TYPE;
    V_DESC_LUOGO_NAS_REGINDE        XBA_AVVOCATI_CON_PENDENZE.DESC_LUOGO_NAS_REGINDE%TYPE;

    -- variabili per la SELECT puntuale di AVVOCATO
    V_A_ID_AVVOCATO                    AVVOCATO.ID_AVVOCATO%TYPE;
    V_A_COD_UFFICIO_APPARTENENZA    AVVOCATO.COD_UFFICIO_APPARTENENZA%TYPE;

    V_A_FLAG_CANCELLATO                AVVOCATO.FLAG_CANCELLATO%TYPE;
    V_A_ID_AVVOCATO_BONIFICATO        AVVOCATO.ID_AVVOCATO_BONIFICATO%TYPE;

    -- variabile generali
    AVV_CON_PENDENZE_letti            NUMBER:=0;
    AVVOCATI_aggiornati                NUMBER:=0;
    AVV_SIEP_aggiornati                NUMBER:=0;
    AVV_SIUS_aggiornati                NUMBER:=0;
    AVV_SIGE_aggiornati                NUMBER:=0;
    PAR_UDI_DIF_aggiornati            NUMBER:=0;
    STORICO_AVV_aggiornati            NUMBER:=0;
    AVVISI_AVV_aggiornati            NUMBER:=0;
    NUOVA_ISTANZA_aggiornati        NUMBER:=0;

    tot_AVV_SIEP_aggiornati            NUMBER:=0;
    tot_AVV_SIUS_aggiornati            NUMBER:=0;
    tot_AVV_SIGE_aggiornati            NUMBER:=0;
    tot_PAR_UDI_DIF_aggiornati        NUMBER:=0;
    tot_STORICO_AVV_aggiornati        NUMBER:=0;
    tot_AVVISI_AVV_aggiornati        NUMBER:=0;
    tot_NUOVA_ISTANZA_aggiornati    NUMBER:=0;

    AVV_CERTIFICATI                NUMBER:=0;
    AVV_COLLEGATI                NUMBER:=0;
	W_CODICE_DISTRETTO           NUMBER:=0; 

    ID_AVVOCATO_attuale            XBA_AVVOCATI_CON_PENDENZE.ID_AVVOCATO%TYPE;
    ID_AVV_CERT_REGINDE_attuale    XBA_AVVOCATI_CON_PENDENZE.ID_AVV_CERT_REGINDE%TYPE;
    FLAG_REGINDE_attuale        XBA_AVVOCATI_CON_PENDENZE.FLAG_REGINDE%TYPE;
    AMBIENTE_attuale            XBA_AVVOCATI_CON_PENDENZE.AMBIENTE%TYPE;

    -- Cursore di XBA_AVVOCATI_CON_PENDENZE (solo occorrenze da bonificare : ID_AVV_CERT_REGINDE <> NULL )
    CURSOR cur_avv_con_pendenze IS
        SELECT acp.ID_AVVOCATO, acp.PEC, acp.FLAG_REGINDE, acp.ID_AVV_CERT_REGINDE, acp.AMBIENTE,
               acp.DESCR_COMUNE_STUDIO, acp.COD_STATO_NASCITA_AVV, acp.DESC_LUOGO_NAS_REGINDE
          FROM XBA_AVVOCATI_CON_PENDENZE acp
         WHERE acp.ID_AVV_CERT_REGINDE IS NOT NULL
         ORDER BY acp.ID_AVV_CERT_REGINDE , acp.DATA_INSERIMENTO DESC;

    -- Cursore di AVVOCATO
    CURSOR cur_avvocato(V_ID_AVVOCATO IN NUMBER ) IS
        SELECT a.ID_AVVOCATO, a.COD_UFFICIO_APPARTENENZA
          FROM AVVOCATO a
         WHERE a.ID_AVVOCATO = V_ID_AVVOCATO;

BEGIN
----------------------------------------------------------
-------------------INIZIO PROCEDURA-----------------------
----------------------------------------------------------

  -- Caricamento tabella XBA_LOG_BONIFICA_AVVOCATI
   BEGIN
     --  Recupero codice distretto
	  SELECT SUBSTR(FASCICOLO_SIUS.ID_FASCICOLO_SIUS,-6, 2) INTO W_CODICE_DISTRETTO FROM FASCICOLO_SIUS
        GROUP BY SUBSTR(FASCICOLO_SIUS.ID_FASCICOLO_SIUS,-6, 2)
        ORDER BY count(SUBSTR(FASCICOLO_SIUS.ID_FASCICOLO_SIUS,-6, 2)) DESC
        FETCH FIRST 1 ROWS ONLY;
		dbms_output.put_line('= Codice Distretto : '||W_CODICE_DISTRETTO);
      INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
      VALUES('Inizio XBA_BONIFICA_AVVOCATO. Individuazione degli avvocati SIES deputati a divenire certificati REGINDE.',
              W_CODICE_DISTRETTO,
              CURRENT_DATE);
  --  Setto le colonne FLAG_REGINDE = 'NO' e COD_STATO_NASCITA_AVV = '-' per tutti gli avvocati
      UPDATE AVVOCATO SET FLAG_REGINDE = 'NO', COD_STATO_NASCITA_AVV = '-';
   END;
    
    
  -- Cursore di XBA_AVVOCATI_CON_PENDENZE già collegati con REGINDE, 
  -- ordinati per ID_AVV_CERT_REGINDE e DATA_INSERIMENTO decrescenti.
  -- Il cursore così individua prima le occorrenza di AVVOCATO che saranno certificati REGINDE 
  -- e subito dopo le occorrenze collegate allo stesso AVVOCATO ( aventi lo stesso ID_AVV_CERT_REGINDE ). 
  -- Per gli avvocati certificati REGINDE saranno valorizzati anche i paesi e luoghi ni nascita esteri.
  OPEN cur_avv_con_pendenze;
    LOOP
        FETCH cur_avv_con_pendenze INTO
            V_ID_AVVOCATO, V_PEC, V_FLAG_REGINDE, V_ID_AVV_CERT_REGINDE, V_AMBIENTE,
            V_DESCR_COMUNE_STUDIO, V_COD_STATO_NASCITA_AVV, V_DESC_LUOGO_NAS_REGINDE;

        EXIT WHEN cur_avv_con_pendenze%NOTFOUND;
         BEGIN
            AVV_CON_PENDENZE_letti := AVV_CON_PENDENZE_letti + 1 ;
        
            ID_AVVOCATO_attuale             := V_ID_AVVOCATO ;
            FLAG_REGINDE_attuale             := V_FLAG_REGINDE ;
            ID_AVV_CERT_REGINDE_attuale        := V_ID_AVV_CERT_REGINDE ;
            AMBIENTE_attuale                := V_AMBIENTE ;

            -- Loop Avvocato
            OPEN cur_avvocato(V_ID_AVVOCATO);
             LOOP
                FETCH cur_avvocato INTO
                        V_A_ID_AVVOCATO,
                        V_A_COD_UFFICIO_APPARTENENZA;

                EXIT WHEN cur_avvocato%NOTFOUND;
                BEGIN

                    IF (FLAG_REGINDE_attuale = 'SI') THEN
                        V_A_FLAG_CANCELLATO := 'N';
                        V_A_COD_UFFICIO_APPARTENENZA := '00000';
                        V_A_ID_AVVOCATO_BONIFICATO := NULL;
                        AVV_CERTIFICATI := AVV_CERTIFICATI + 1;
                    ELSE     
                        V_A_FLAG_CANCELLATO := 'S';
                        V_A_ID_AVVOCATO_BONIFICATO := ID_AVV_CERT_REGINDE_attuale;
                        AVV_COLLEGATI := AVV_COLLEGATI + 1;
                    END IF;
                    
                    UPDATE AVVOCATO
                    SET
                        ID_AVVOCATO_BONIFICATO = V_A_ID_AVVOCATO_BONIFICATO,
                        FLAG_CANCELLATO = V_A_FLAG_CANCELLATO,
                        PEC = V_PEC,
                        FLAG_REGINDE = FLAG_REGINDE_attuale,
                        COD_NON_ATTIVITA = 'A',
                        COD_UFFICIO_APPARTENENZA = V_A_COD_UFFICIO_APPARTENENZA,
                        DESCR_COMUNE_STUDIO  = V_DESCR_COMUNE_STUDIO,
                        COD_STATO_NASCITA_AVV = V_COD_STATO_NASCITA_AVV,
                        DESC_LUOGO_NAS_REGINDE = V_DESC_LUOGO_NAS_REGINDE,
                        COD_OPERATORE_AGGIORNAMENTO = 'Update Bonifica ReGIndE',
                        DATA_AGGIORNAMENTO = CURRENT_DATE
                    WHERE
                        ID_AVVOCATO = V_A_ID_AVVOCATO;
                    UPDATE AVVOCATO_BONIF
                    SET
                        AVV_ID_AVVOCATO_NEW = V_ID_AVV_CERT_REGINDE
                    WHERE
                        AVVOCATO_BONIF.ID_AVVOCATO = V_A_ID_AVVOCATO;

                    IF(SQL%ROWCOUNT=0) THEN
                        dbms_output.put_line('===========================================================');
                        dbms_output.put_line('ERRORE UPDATE AVVOCATO - AVV_ID_AVVOCATO = '||V_A_ID_AVVOCATO);
                        INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
                             VALUES('ERRORE UPDATE AVVOCATO con Id : '||V_A_ID_AVVOCATO ,
                                     V_A_ID_AVVOCATO,
                                     CURRENT_DATE);
                    ELSE
                        AVVOCATI_aggiornati := AVVOCATI_aggiornati + 1;
                    END IF;

                    -- Dopo l'aggiornamento di AVVOCATO con FLAG_REGINDE = 'NO' occorre aggiornare le tabelle:
                    --    AVVOCATO_FASCICOLO_SIEP, AVVOCATO_FASCICOLO_SIUS, AVVOCATO_FASCICOLO_SIGE, 
                    --    PARTI_UDIENZA_DIFENSORE, STORICO_AVVOCATO, AVVISI_AVVOCATO, NUOVA_ISTANZA,
                    --    per consentire il puntamento all'avvocato certificato REGINDE.

                    -- AVVOCATO_FASCICOLO_SIEP
                    IF (FLAG_REGINDE_attuale = 'NO' AND 
                        AMBIENTE_attuale = 'SIEP') THEN

                        SELECT COUNT(*)INTO AVV_SIEP_aggiornati
                             FROM AVVOCATO_FASCICOLO_SIEP afs, FASCICOLO_SIEP fs  
                            WHERE afs.FAS_SIE_ID_FASCICOLO_SIEP = fs.ID_FASCICOLO_SIEP 
                              AND afs.AVV_ID_AVVOCATO = V_A_ID_AVVOCATO
							  AND SUBSTR(afs.FAS_SIE_ID_FASCICOLO_SIEP,-6, 2) = W_CODICE_DISTRETTO                              AND fs.COD_STATO_FASCICOLO <> '01';
                        
                        IF (AVV_SIEP_aggiornati > 0 ) THEN 
                            UPDATE AVVOCATO_FASCICOLO_SIEP 
                            SET
                                AVV_ID_AVVOCATO = ID_AVV_CERT_REGINDE_attuale
                            WHERE
                                (AVV_ID_AVVOCATO, FAS_SIE_ID_FASCICOLO_SIEP) 
                               IN (SELECT afs.AVV_ID_AVVOCATO, afs.FAS_SIE_ID_FASCICOLO_SIEP 
                                     FROM AVVOCATO_FASCICOLO_SIEP afs, FASCICOLO_SIEP fs 
                                    WHERE fs.ID_FASCICOLO_SIEP = afs.FAS_SIE_ID_FASCICOLO_SIEP 
                                      AND afs.AVV_ID_AVVOCATO = V_A_ID_AVVOCATO
									  AND SUBSTR(afs.FAS_SIE_ID_FASCICOLO_SIEP,-6, 2) = W_CODICE_DISTRETTO
                                      AND fs.COD_STATO_FASCICOLO <> '01');

                            IF(SQL%ROWCOUNT=0) THEN
                                dbms_output.put_line('===========================================================');
                                dbms_output.put_line('ERRORE UPDATE AVVOCATO_FASCICOLO_SIEP - AVV_ID_AVVOCATO = '||V_A_ID_AVVOCATO);
                                INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
                                     VALUES('ERRORE UPDATE AVVOCATO_FASCICOLO_SIEP con IdAvvocato : '||V_A_ID_AVVOCATO ,
                                             V_A_ID_AVVOCATO,
                                             CURRENT_DATE);
                            ELSE
                                tot_AVV_SIEP_aggiornati := tot_AVV_SIEP_aggiornati + AVV_SIEP_aggiornati;
                            END IF;
                            
                    ----  Valorizza AVV_ID_AVVOCATO_NEW    su tabella AVVOCATO_FASCICOLO_SIEP_BONIF
                            UPDATE AVVOCATO_FASCICOLO_SIEP_BONIF
                            SET
                                AVV_ID_AVVOCATO_NEW = ID_AVV_CERT_REGINDE_attuale
                            WHERE
                                (AVV_ID_AVVOCATO, FAS_SIE_ID_FASCICOLO_SIEP) 
                               IN (SELECT afsb.AVV_ID_AVVOCATO, afsb.FAS_SIE_ID_FASCICOLO_SIEP 
                                     FROM AVVOCATO_FASCICOLO_SIEP_BONIF afsb, FASCICOLO_SIEP fs 
                                    WHERE fs.ID_FASCICOLO_SIEP = afsb.FAS_SIE_ID_FASCICOLO_SIEP 
                                      AND afsb.AVV_ID_AVVOCATO = V_A_ID_AVVOCATO
									  AND SUBSTR(afsb.FAS_SIE_ID_FASCICOLO_SIEP,-6, 2) = W_CODICE_DISTRETTO
                                      AND fs.COD_STATO_FASCICOLO <> '01');
                            
                            IF(SQL%ROWCOUNT=0) THEN
                                dbms_output.put_line('===========================================================');
                                dbms_output.put_line('ERRORE UPDATE AVVOCATO_FASCICOLO_SIEP_BONIF - AVV_ID_AVVOCATO = '||V_A_ID_AVVOCATO);
                                INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
                                     VALUES('ERRORE UPDATE AVVOCATO_FASCICOLO_SIEP_BONIF con IdAvvocato : '||V_A_ID_AVVOCATO ,
                                             V_A_ID_AVVOCATO,
                                             CURRENT_DATE);
                            END IF;
                        END IF;
                    END IF;
                
                    -- AVVOCATO_FASCICOLO_SIUS
                    IF (FLAG_REGINDE_attuale = 'NO' AND 
                        AMBIENTE_attuale = 'SIUS') THEN

                        SELECT COUNT(*)INTO AVV_SIUS_aggiornati
                             FROM AVVOCATO_FASCICOLO_SIUS afs, FASCICOLO_SIUS fs  
                            WHERE afs.FAS_SIU_ID_FASCICOLO_SIUS = fs.ID_FASCICOLO_SIUS  
                              AND afs.AVV_ID_AVVOCATO = V_A_ID_AVVOCATO
							  AND SUBSTR(afs.FAS_SIU_ID_FASCICOLO_SIUS,-6, 2) = W_CODICE_DISTRETTO
                              AND fs.COD_STATO_FASCICOLO NOT in ('01', '07', '05');

                        IF (AVV_SIUS_aggiornati > 0 ) THEN 
                            UPDATE AVVOCATO_FASCICOLO_SIUS 
                            SET
                                AVV_ID_AVVOCATO = ID_AVV_CERT_REGINDE_attuale
                            WHERE
                                (AVV_ID_AVVOCATO, FAS_SIU_ID_FASCICOLO_SIUS) 
                               IN (SELECT afs.AVV_ID_AVVOCATO, afs.FAS_SIU_ID_FASCICOLO_SIUS
                                     FROM AVVOCATO_FASCICOLO_SIUS afs, FASCICOLO_SIUS fs 
                                    WHERE fs.ID_FASCICOLO_SIUS = afs.FAS_SIU_ID_FASCICOLO_SIUS 
                                      AND afs.AVV_ID_AVVOCATO = V_A_ID_AVVOCATO
									  AND SUBSTR(afs.FAS_SIU_ID_FASCICOLO_SIUS,-6, 2) = W_CODICE_DISTRETTO
                                      AND fs.COD_STATO_FASCICOLO NOT in ('01', '07', '05') );
        
                            IF(SQL%ROWCOUNT=0) THEN
                                dbms_output.put_line('===========================================================');
                                dbms_output.put_line('ERRORE UPDATE AVVOCATO_FASCICOLO_SIUS - AVV_ID_AVVOCATO = '||V_A_ID_AVVOCATO);
                                INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
                                     VALUES('ERRORE UPDATE AVVOCATO_FASCICOLO_SIUS con IdAvvocato : '||V_A_ID_AVVOCATO ,
                                             V_A_ID_AVVOCATO,
                                             CURRENT_DATE);
                            ELSE
                                tot_AVV_SIUS_aggiornati := tot_AVV_SIUS_aggiornati + AVV_SIUS_aggiornati;
                            END IF;

                    ----  Valorizza AVV_ID_AVVOCATO_NEW    su tabella AVVOCATO_FASCICOLO_SIUS_BONIF
                            UPDATE AVVOCATO_FASCICOLO_SIUS_BONIF 
                            SET
                                AVV_ID_AVVOCATO_NEW = ID_AVV_CERT_REGINDE_attuale
                            WHERE
                                (AVV_ID_AVVOCATO, FAS_SIU_ID_FASCICOLO_SIUS) 
                               IN (SELECT afub.AVV_ID_AVVOCATO, afub.FAS_SIU_ID_FASCICOLO_SIUS
                                     FROM AVVOCATO_FASCICOLO_SIUS_BONIF afub, FASCICOLO_SIUS fs 
                                    WHERE fs.ID_FASCICOLO_SIUS = afub.FAS_SIU_ID_FASCICOLO_SIUS 
                                      AND afub.AVV_ID_AVVOCATO = V_A_ID_AVVOCATO
									  AND SUBSTR(afub.FAS_SIU_ID_FASCICOLO_SIUS,-6, 2) = W_CODICE_DISTRETTO
                                      AND fs.COD_STATO_FASCICOLO NOT in ('01', '07', '05') );

                            IF(SQL%ROWCOUNT=0) THEN
                                dbms_output.put_line('===========================================================');
                                dbms_output.put_line('ERRORE UPDATE AVVOCATO_FASCICOLO_SIUS_BONIF  - AVV_ID_AVVOCATO = '||V_A_ID_AVVOCATO);
                                INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
                                     VALUES('ERRORE UPDATE AVVOCATO_FASCICOLO_SIUS_BONIF con IdAvvocato : '||V_A_ID_AVVOCATO ,
                                             V_A_ID_AVVOCATO,
                                             CURRENT_DATE);
                            END IF;
                                      
                        END IF;
                    END IF;

                    -- AVVOCATO_FASCICOLO_SIGE
                    IF (FLAG_REGINDE_attuale = 'NO' AND 
                        AMBIENTE_attuale = 'SIGE') THEN

                        SELECT COUNT(*)INTO AVV_SIGE_aggiornati
                             FROM AVVOCATO_FASCICOLO_SIGE afs, FASCICOLO_SIGE fs  
                            WHERE afs.FAS_SIGE_ID_FASCICOLO_SIGE = fs.ID_FASCICOLO_SIGE  
                              AND afs.AVV_ID_AVVOCATO = V_A_ID_AVVOCATO
							  AND SUBSTR(afs.FAS_SIGE_ID_FASCICOLO_SIGE,-6, 2) = W_CODICE_DISTRETTO
                              AND fs.DATA_DEFINIZIONE IS NULL;

                        IF (AVV_SIGE_aggiornati > 0 ) THEN 
                            UPDATE AVVOCATO_FASCICOLO_SIGE 
                            SET
                                AVV_ID_AVVOCATO = ID_AVV_CERT_REGINDE_attuale
                            WHERE
                                (AVV_ID_AVVOCATO, FAS_SIGE_ID_FASCICOLO_SIGE) 
                               IN (SELECT afs.AVV_ID_AVVOCATO, afs.FAS_SIGE_ID_FASCICOLO_SIGE
                                     FROM AVVOCATO_FASCICOLO_SIGE afs, FASCICOLO_SIGE fs 
                                    WHERE fs.ID_FASCICOLO_SIGE = afs.FAS_SIGE_ID_FASCICOLO_SIGE 
                                      AND afs.AVV_ID_AVVOCATO = V_A_ID_AVVOCATO
									  AND SUBSTR(afs.FAS_SIGE_ID_FASCICOLO_SIGE,-6, 2) = W_CODICE_DISTRETTO
                                      AND fs.DATA_DEFINIZIONE IS NULL );
                                      
                            IF(SQL%ROWCOUNT=0) THEN
                                dbms_output.put_line('===========================================================');
                                dbms_output.put_line('ERRORE UPDATE AVVOCATO_FASCICOLO_SIGE - AVV_ID_AVVOCATO = '||V_A_ID_AVVOCATO);
                                INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
                                     VALUES('ERRORE UPDATE AVVOCATO_FASCICOLO_SIGE con IdAvvocato : '||V_A_ID_AVVOCATO ,
                                             V_A_ID_AVVOCATO,
                                             CURRENT_DATE);
                            ELSE
                                tot_AVV_SIGE_aggiornati := tot_AVV_SIGE_aggiornati + AVV_SIGE_aggiornati;
                            END IF;
                            
                    ----  Valorizza AVV_ID_AVVOCATO_NEW    su tabella AVVOCATO_FASCICOLO_SIGE_BONIF
                            UPDATE AVVOCATO_FASCICOLO_SIGE_BONIF 
                            SET
                                AVV_ID_AVVOCATO_NEW = ID_AVV_CERT_REGINDE_attuale
                            WHERE
                                (AVV_ID_AVVOCATO,FAS_SIGE_ID_FASCICOLO_SIGE) 
                               IN (SELECT afgb.AVV_ID_AVVOCATO, afgb.FAS_SIGE_ID_FASCICOLO_SIGE
                                     FROM AVVOCATO_FASCICOLO_SIGE_BONIF afgb, FASCICOLO_SIGE fs 
                                    WHERE fs.ID_FASCICOLO_SIGE = afgb.FAS_SIGE_ID_FASCICOLO_SIGE 
                                      AND afgb.AVV_ID_AVVOCATO = V_A_ID_AVVOCATO
									  AND SUBSTR(afgb.FAS_SIGE_ID_FASCICOLO_SIGE,-6, 2) = W_CODICE_DISTRETTO
                                      AND fs.DATA_DEFINIZIONE IS NULL );
                                      
                            IF(SQL%ROWCOUNT=0) THEN
                                dbms_output.put_line('===========================================================');
                                dbms_output.put_line('ERRORE UPDATE AVVOCATO_FASCICOLO_SIGE_BONIF - AVV_ID_AVVOCATO = '||V_A_ID_AVVOCATO);
                                INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
                                     VALUES('ERRORE UPDATE AVVOCATO_FASCICOLO_SIGE_BONIF con IdAvvocato : '||V_A_ID_AVVOCATO ,
                                             V_A_ID_AVVOCATO,
                                             CURRENT_DATE);
                            END IF;
                        END IF;
                    END IF;

                    -- PARTI_UDIENZA_DIFENSORE
                    IF (FLAG_REGINDE_attuale = 'NO') THEN

                        SELECT COUNT(*)INTO PAR_UDI_DIF_aggiornati
                            FROM PARTI_UDIENZA_DIFENSORE pud  
                            WHERE pud.AVV_ID_AVVOCATO = V_A_ID_AVVOCATO;

                        IF (PAR_UDI_DIF_aggiornati > 0 ) THEN 
                            UPDATE PARTI_UDIENZA_DIFENSORE 
                            SET
                                AVV_ID_AVVOCATO = ID_AVV_CERT_REGINDE_attuale
                            WHERE
                                AVV_ID_AVVOCATO = V_A_ID_AVVOCATO;
        
                            IF(SQL%ROWCOUNT=0) THEN
                                dbms_output.put_line('===========================================================');
                                dbms_output.put_line('ERRORE UPDATE PARTI_UDIENZA_DIFENSORE - AVV_ID_AVVOCATO = '||V_A_ID_AVVOCATO);
                                INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
                                     VALUES('ERRORE UPDATE PARTI_UDIENZA_DIFENSORE con IdAvvocato : '||V_A_ID_AVVOCATO ,
                                             V_A_ID_AVVOCATO,
                                             CURRENT_DATE);
                            ELSE
                                tot_PAR_UDI_DIF_aggiornati := tot_PAR_UDI_DIF_aggiornati + PAR_UDI_DIF_aggiornati;
                            END IF;

                    ----  Valorizza AVV_ID_AVVOCATO_NEW    su tabella PARTI_UDIENZA_DIFENSORE_BONIF                            
                            UPDATE PARTI_UDIENZA_DIFENSORE_BONIF pud
                            SET
                                pud.AVV_ID_AVVOCATO_NEW = ID_AVV_CERT_REGINDE_attuale
                            WHERE
                                pud.AVV_ID_AVVOCATO = V_A_ID_AVVOCATO;
                            
                            IF(SQL%ROWCOUNT=0) THEN
                                dbms_output.put_line('===========================================================');
                                dbms_output.put_line('ERRORE UPDATE PARTI_UDIENZA_DIFENSORE_BONIF - AVV_ID_AVVOCATO = '||V_A_ID_AVVOCATO);
                                INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
                                     VALUES('ERRORE UPDATE PARTI_UDIENZA_DIFENSORE_BONIF con IdAvvocato : '||V_A_ID_AVVOCATO ,
                                             V_A_ID_AVVOCATO,
                                             CURRENT_DATE);
                            --ELSE
                            --    tot_PAR_UDI_DIF_aggiornati := tot_PAR_UDI_DIF_aggiornati + PAR_UDI_DIF_aggiornati;
                            END IF;

                        END IF;
                    END IF;

                    -- STORICO AVVOCATO
                    IF (FLAG_REGINDE_attuale = 'NO') THEN

                        SELECT COUNT(*)INTO STORICO_AVV_aggiornati
                            FROM STORICO_AVVOCATO sa   
                            WHERE sa.AVV_ID_AVVOCATO = V_A_ID_AVVOCATO;
                    
                        IF (STORICO_AVV_aggiornati > 0 ) THEN 
                            UPDATE STORICO_AVVOCATO
                            SET
                                AVV_ID_AVVOCATO = ID_AVV_CERT_REGINDE_attuale
                            WHERE
                                AVV_ID_AVVOCATO = V_A_ID_AVVOCATO;
                                
                            IF(SQL%ROWCOUNT=0) THEN
                                dbms_output.put_line('===========================================================');
                                dbms_output.put_line('ERRORE UPDATE STORICO_AVVOCATO - AVV_ID_AVVOCATO = '||V_A_ID_AVVOCATO);
                                INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
                                     VALUES('ERRORE UPDATE STORICO_AVVOCATO con IdAvvocato : '||V_A_ID_AVVOCATO ,
                                             V_A_ID_AVVOCATO,
                                             CURRENT_DATE);
                            ELSE
                                tot_STORICO_AVV_aggiornati := tot_STORICO_AVV_aggiornati + STORICO_AVV_aggiornati;
                            END IF;
                        
                            ----  Valorizza AVV_ID_AVVOCATO_NEW    su tabella STORICO_AVVOCATO_BONIF    
                            UPDATE STORICO_AVVOCATO_BONIF sab
                            SET
                                sab.AVV_ID_AVVOCATO_NEW = ID_AVV_CERT_REGINDE_attuale
                            WHERE
                                sab.AVV_ID_AVVOCATO = V_A_ID_AVVOCATO;        
                            
                            IF(SQL%ROWCOUNT=0) THEN
                                dbms_output.put_line('===========================================================');
                                dbms_output.put_line('ERRORE UPDATE STORICO_AVVOCATO_BONIF - AVV_ID_AVVOCATO = '||V_A_ID_AVVOCATO);
                                INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
                                     VALUES('ERRORE UPDATE STORICO_AVVOCATO_BONIF con IdAvvocato : '||V_A_ID_AVVOCATO ,
                                             V_A_ID_AVVOCATO,
                                             CURRENT_DATE);
                            END IF;
                        END IF;
                    END IF;

                    -- AVVISI AVVOCATO
                    IF (FLAG_REGINDE_attuale = 'NO') THEN

                        SELECT COUNT(*)INTO AVVISI_AVV_aggiornati
                            FROM AVVISI_AVVOCATO aa   
                            WHERE aa.ID_AVVOCATO = V_A_ID_AVVOCATO;

                        IF (AVVISI_AVV_aggiornati > 0 ) THEN 
                            UPDATE AVVISI_AVVOCATO
                            SET
                                ID_AVVOCATO = ID_AVV_CERT_REGINDE_attuale
                            WHERE
                                ID_AVVOCATO = V_A_ID_AVVOCATO;
        
                            IF(SQL%ROWCOUNT=0) THEN
                                dbms_output.put_line('===========================================================');
                                dbms_output.put_line('ERRORE UPDATE AVVISI_AVVOCATO - AVV_ID_AVVOCATO = '||V_A_ID_AVVOCATO);
                                INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
                                     VALUES('ERRORE UPDATE AVVISI_AVVOCATO con IdAvvocato : '||V_A_ID_AVVOCATO ,
                                             V_A_ID_AVVOCATO,
                                             CURRENT_DATE);
                            ELSE
                                tot_AVVISI_AVV_aggiornati := tot_AVVISI_AVV_aggiornati + AVVISI_AVV_aggiornati;
                            END IF;
                            
                    ----  Valorizza AVV_ID_AVVOCATO_NEW    su tabella AVVISI_AVVOCATO_BONIF    
                            UPDATE AVVISI_AVVOCATO_BONIF aab
                            SET
                                aab.AVV_ID_AVVOCATO_NEW = ID_AVV_CERT_REGINDE_attuale
                            WHERE
                               aab.ID_AVVOCATO = V_A_ID_AVVOCATO;    

                            IF(SQL%ROWCOUNT=0) THEN
                                dbms_output.put_line('===========================================================');
                                dbms_output.put_line('ERRORE UPDATE AVVISI_AVVOCATO_BONIF  - AVV_ID_AVVOCATO = '||V_A_ID_AVVOCATO);
                                INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
                                     VALUES('ERRORE UPDATE AVVISI_AVVOCATO_BONIF  con IdAvvocato : '||V_A_ID_AVVOCATO ,
                                             V_A_ID_AVVOCATO,
                                             CURRENT_DATE);
                            END IF;

                        END IF;
                    END IF;
                
                    -- NUOVA_ISTANZA
                    IF (FLAG_REGINDE_attuale = 'NO') THEN
                        
                        SELECT COUNT(*)INTO NUOVA_ISTANZA_aggiornati
                            FROM NUOVA_ISTANZA ni    
                            WHERE ni.AVV_ID_AVVOCATO = V_A_ID_AVVOCATO;

                        IF (NUOVA_ISTANZA_aggiornati > 0 ) THEN 
                            UPDATE NUOVA_ISTANZA
                            SET
                                AVV_ID_AVVOCATO = ID_AVV_CERT_REGINDE_attuale
                            WHERE
                                AVV_ID_AVVOCATO = V_A_ID_AVVOCATO;
        
                            IF(SQL%ROWCOUNT=0) THEN
                                dbms_output.put_line('===========================================================');
                                dbms_output.put_line('ERRORE UPDATE NUOVA_ISTANZA - AVV_ID_AVVOCATO = '||V_A_ID_AVVOCATO);
                                INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
                                     VALUES('ERRORE UPDATE NUOVA_ISTANZA con IdAvvocato : '||V_A_ID_AVVOCATO ,
                                             V_A_ID_AVVOCATO,
                                             CURRENT_DATE);
                            ELSE
                                tot_NUOVA_ISTANZA_aggiornati := tot_NUOVA_ISTANZA_aggiornati + NUOVA_ISTANZA_aggiornati;
                            END IF;
                            
                    ----  Valorizza AVV_ID_AVVOCATO_NEW    su tabella NUOVA_ISTANZA_BONIF    
                            UPDATE NUOVA_ISTANZA_BONIF nib
                            SET
                                nib.AVV_ID_AVVOCATO_NEW = ID_AVV_CERT_REGINDE_attuale
                            WHERE
                                nib.AVV_ID_AVVOCATO = V_A_ID_AVVOCATO;
                            
                            IF(SQL%ROWCOUNT=0) THEN
                                dbms_output.put_line('===========================================================');
                                dbms_output.put_line('ERRORE UPDATE NUOVA_ISTANZA_BONIF  - AVV_ID_AVVOCATO = '||V_A_ID_AVVOCATO);
                                INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
                                     VALUES('ERRORE UPDATE NUOVA_ISTANZA_BONIF con IdAvvocato : '||V_A_ID_AVVOCATO ,
                                             V_A_ID_AVVOCATO,
                                             CURRENT_DATE);
                            END IF;
                        END IF;
                    END IF;
                
                END;

            END LOOP;
            CLOSE cur_avvocato;

        END;
    
    END LOOP;

  CLOSE cur_avv_con_pendenze;
  ------
  ------ DELETE RECORDS NON AGGIORNATI DALLE TABELLE _BONIF
  -------
     DELETE AVVOCATO_BONIF WHERE AVV_ID_AVVOCATO_NEW IS NULL;
     DELETE AVVOCATO_FASCICOLO_SIEP_BONIF WHERE AVV_ID_AVVOCATO_NEW IS NULL;
     DELETE AVVOCATO_FASCICOLO_SIUS_BONIF WHERE AVV_ID_AVVOCATO_NEW IS NULL;
     DELETE AVVOCATO_FASCICOLO_SIGE_BONIF WHERE AVV_ID_AVVOCATO_NEW IS NULL;
     DELETE AVVOCATO_FASCICOLO_SIEP_BONIF WHERE AVV_ID_AVVOCATO_NEW IS NULL;
     DELETE AVVISI_AVVOCATO_BONIF WHERE AVV_ID_AVVOCATO_NEW IS NULL;
     DELETE STORICO_AVVOCATO_BONIF WHERE AVV_ID_AVVOCATO_NEW IS NULL;
     DELETE NUOVA_ISTANZA_BONIF WHERE AVV_ID_AVVOCATO_NEW IS NULL;
     DELETE PARTI_UDIENZA_DIFENSORE_BONIF WHERE AVV_ID_AVVOCATO_NEW IS NULL;
 -----
    dbms_output.put_line('==================================================');
    dbms_output.put_line('=  Avvocati con pendenze letti           : '||AVV_CON_PENDENZE_letti );
    dbms_output.put_line('=');
    dbms_output.put_line('=  AVVOCATI aggiornati                   : '||AVVOCATI_aggiornati );
    dbms_output.put_line('=');
    dbms_output.put_line('=  Avvocati certificati REGINDE          : '||AVV_CERTIFICATI );
    dbms_output.put_line('=');
    dbms_output.put_line('=  Avvocati collegati ai referenti       : '||AVV_COLLEGATI );
    dbms_output.put_line('=');
    dbms_output.put_line('=  AVVOCATO_FASCICOLO_SIEP aggiornati    : '||tot_AVV_SIEP_aggiornati );
    dbms_output.put_line('=');
    dbms_output.put_line('=  AVVOCATO_FASCICOLO_SIUS aggiornati    : '||tot_AVV_SIUS_aggiornati );
    dbms_output.put_line('=');
    dbms_output.put_line('=  AVVOCATO_FASCICOLO_SIGE aggiornati    : '||tot_AVV_SIGE_aggiornati );
    dbms_output.put_line('=');
    dbms_output.put_line('=  PARTI_UDIENZA_DIFENSORE aggiornati    : '||tot_PAR_UDI_DIF_aggiornati );
    dbms_output.put_line('=');
    dbms_output.put_line('=  STORICO_AVVOCATO aggiornati           : '||tot_STORICO_AVV_aggiornati );
    dbms_output.put_line('=');
    dbms_output.put_line('=  AVVISI_AVVOCATO aggiornati            : '||tot_AVVISI_AVV_aggiornati );
    dbms_output.put_line('=');
    dbms_output.put_line('=  NUOVA_ISTANZA aggiornate              : '||tot_NUOVA_ISTANZA_aggiornati );
    dbms_output.put_line('=');
    dbms_output.put_line('==================================================');
 
    INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
    VALUES('==================================================',
            NULL,
            CURRENT_DATE);

    INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
    VALUES('=  Avvocati con pendenze letti           : ',
            AVV_CON_PENDENZE_letti,
            CURRENT_DATE);

    INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
    VALUES('=  AVVOCATI aggiornati                   : ',
            AVVOCATI_aggiornati,
            CURRENT_DATE);

    INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
    VALUES('=  Avvocati certificati REGINDE          : ',
            AVV_CERTIFICATI,
            CURRENT_DATE);

    INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
    VALUES('=  Avvocati collegati ai referenti       : ',
            AVV_COLLEGATI,
            CURRENT_DATE);

    INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
    VALUES('=  AVVOCATO_FASCICOLO_SIEP aggiornati    : ',
            tot_AVV_SIEP_aggiornati,
            CURRENT_DATE);

    INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
    VALUES('=  AVVOCATO_FASCICOLO_SIUS aggiornati    : ',
            tot_AVV_SIUS_aggiornati,
            CURRENT_DATE);

    INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
    VALUES('=  AVVOCATO_FASCICOLO_SIGE aggiornati    : ',
            tot_AVV_SIGE_aggiornati,
            CURRENT_DATE);
        
    INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
    VALUES('=  PARTI_UDIENZA_DIFENSORE aggiornati    : ',
            tot_PAR_UDI_DIF_aggiornati,
            CURRENT_DATE);
        
    INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
    VALUES('=  STORICO_AVVOCATO aggiornati           : ',
            tot_STORICO_AVV_aggiornati,
            CURRENT_DATE);
        
    INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
    VALUES('=  AVVISI_AVVOCATO aggiornati            : ',
            tot_AVVISI_AVV_aggiornati,
            CURRENT_DATE);
        
    INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
    VALUES('=  NUOVA_ISTANZA aggiornati              : ',
            tot_NUOVA_ISTANZA_aggiornati,
            CURRENT_DATE);
        
    INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
    VALUES('==================================================',
            NULL,
            CURRENT_DATE);
    
    INSERT INTO XBA_LOG_BONIFICA_AVVOCATI
    VALUES('Fine XBA_BONIFICA_AVVOCATO ',
            NULL,
            CURRENT_DATE);
    
END XBA_BONIFICA_AVVOCATO;
