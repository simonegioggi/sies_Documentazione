CREATE OR REPLACE PROCEDURE VALORIZZA_COD_CATASTALE_COMUNE IS

   -- VALORIZZA LA COLONNA COD_CATASTALE_COMUNE IN BASE AL VALORE DELLA STESSA COLONNA  PER I RECORDS AVENTI LA STESSA DESCRIZIONE 
   --
   -- DEFINIZIONE VARIABILI
   V_COD_COMUNE                         COMUNE.COD_COMUNE%TYPE;
   V_DESCRIZIONE                          COMUNE.DESCRIZIONE%TYPE;
   V_COD_CATASTALE_COMUNE      COMUNE.COD_CATASTALE_COMUNE%TYPE;
   V_CO_NSC_DES                           CODICI_SIES_NSC.CO_NSC_DES%TYPE;
    V_CO_SIES_DES                           CODICI_SIES_NSC.CO_SIES_DES%TYPE;


   W_COD_COMUNE                          varchar2(6);
   W_COD_CATASTALE                     varchar2(4);
   W_COD_SEDE_GIUDIZIARIA            varchar2(4);
   W_FLAG_VALIDITA              varchar2(1);


   letti                  NUMBER;
   inseriti                 NUMBER;
   aggiornati             NUMBER;

   cursore_found          BOOLEAN;

   SUCCESSIVO             EXCEPTION;

   -- Dichiarazione del cursore
   CURSOR CUR_COMUNE  IS
     SELECT COD_COMUNE, COD_CATASTALE_COMUNE, 
       DESCRIZIONE
       FROM COMUNE  WHERE COD_CATASTALE_COMUNE IS  NULL;

BEGIN 






   -- Inizializzo contatori
   letti        := 0;
   inseriti       := 0;
   aggiornati   := 0;

   -- APERTURA CURSORE
   OPEN CUR_COMUNE;

   -- LETTURA FUORI CICLO DEI DATI DEL COMUNE_TF
   FETCH CUR_COMUNE INTO  V_COD_COMUNE, V_COD_CATASTALE_COMUNE,
        V_DESCRIZIONE;

   cursore_found := CUR_COMUNE%FOUND;

   -- INIZIO CICLO DI ESTRAZIONE DATI PER OGNI RECORD RILASCIATO DALLA FETCH
   WHILE cursore_found
    LOOP
     BEGIN -- inizio loop
          DBMS_OUTPUT.PUT_LINE ('fetch fuori ciclo'  || V_COD_COMUNE  || V_DESCRIZIONE);
       letti := letti + 1;

           BEGIN
         SELECT COD_COMUNE,  COD_CATASTALE_COMUNE, COD_SEDE_GIUDIZIARIA
           INTO  W_COD_COMUNE,  W_COD_CATASTALE, W_COD_SEDE_GIUDIZIARIA
           FROM COMUNE
          WHERE DESCRIZIONE = V_DESCRIZIONE 
          --AND FLAG_VALIDITA = 'S' 
          AND COD_CATASTALE_COMUNE IS NOT NULL AND rownum = 1;

               BEGIN
                      UPDATE COMUNE
               SET COD_CATASTALE_COMUNE    = W_COD_CATASTALE, COD_SEDE_GIUDIZIARIA = W_COD_SEDE_GIUDIZIARIA
                   WHERE  COD_COMUNE = V_COD_COMUNE;
              aggiornati := aggiornati + 1;
          DBMS_OUTPUT.PUT_LINE ('UPDATE COMUNE'  || V_COD_COMUNE|| '-' || V_DESCRIZIONE || '-' || W_COD_SEDE_GIUDIZIARIA || '-' || aggiornati);
              END;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
                       aggiornati := aggiornati + 1;




           inseriti := inseriti + 1;

            END;

           END;



          aggiornati := aggiornati + 1;


   FETCH CUR_COMUNE INTO  V_COD_COMUNE, V_COD_CATASTALE_COMUNE,
        V_DESCRIZIONE;

     cursore_found := CUR_COMUNE%FOUND;

   
   END LOOP;
   
          DBMS_OUTPUT.PUT_LINE ('COMUNI AGGIORNATI = '  || aggiornati);
end VALORIZZA_COD_CATASTALE_COMUNE;


