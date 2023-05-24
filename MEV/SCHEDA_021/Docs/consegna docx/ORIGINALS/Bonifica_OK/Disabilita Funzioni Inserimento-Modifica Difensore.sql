--- Disabilita funzione Inserimento/Modifica Difensore in Funzioni Amministrative/Gestione Difensori
---     Funzione Inserimento Difensore
delete relazione_funzione where fun_id_funzione = 41 and fun_id_funzione_figlia =11040010;
delete relazione_funzione where FUN_ID_FUNZIONE = 11040012 and FUN_ID_FUNZIONE_FIGLIA  = 11040010;
---     Funzione Modifica Difensore
UPDATE FUNZIONE_PROFILO SET DATA_FINE_VALIDITA = TO_DATE ('2021-07-05 01:00:00', 'YYYY-MM-DD HH:MI:SS') WHERE FUN_ID_FUNZIONE = '11040031';
COMMIT;


