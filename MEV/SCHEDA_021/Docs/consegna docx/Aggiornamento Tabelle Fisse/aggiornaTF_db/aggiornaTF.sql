-------------------------------------------------------------------------------
-- Scopo ..: Creazione degli oggetti del database del sistema informativo
-- Note ...: eseguire da SQLPLUS /NOLOG
--
-- MEV-2019_21 - Aggiorna Tabelle Fisse
-------------------------------------------------------------------------------

WHENEVER SQLERROR CONTINUE
WHENEVER OSERROR CONTINUE

PROMPT Procedura di installazione versione MEV-2019_21 - Aggiorna Tabelle Fisse di SIES
PROMPT
PROMPT Se non si intende procedere chiudere SQL*Plus premendo adesso CTRL+C
PAUSE oppure premere INVIO...

PROMPT
PROMPT

ACCEPT dbsid PROMPT 'Inserire il SID dell''istanza Oracle (esempio SIESTO) ... : ';
ACCEPT siesuser PROMPT 'Inserire il nome dello schema SIES ... : ';
ACCEPT pwd_sies PROMPT 'Inserire la password dello schema SIES ... : ';

PROMPT
PROMPT
PROMPT Per generare il file di log ed il percorso dei datafile in modo opportuno
PROMPT occorre indicare un nome mnemonico per questa installazione.
PROMPT Valore di default: &dbsid
PROMPT
ACCEPT nomeinstallazione PROMPT 'Inserire il nome di questa installazione : ' DEFAULT &dbsid

DEFINE logpath=log
HOST mkdir &logpath

PROMPT
PROMPT Inserimento dati completato
PAUSE Premere INVIO per continuare...

PROMPT
SPOOL &logpath/creazione_&nomeinstallazione..log

PROMPT ==============================================================================
PROMPT Riassunto dei dati immessi per questa installazione
PROMPT Nome ....................: &nomeinstallazione
PROMPT ==============================================================================
PROMPT SID Oracle ..............: &dbsid
PROMPT Utente_SIES..............: &siesuser
PROMPT Password_SIES............: &pwd_sies
PROMPT ==============================================================================
!echo '=============================================================================='
!echo '***** DATA INIZIO PROCEDURA:' `date +%d/%m/%Y_%r`
!echo '=============================================================================='
PROMPT
PROMPT Se non si intende procedere chiudere adesso SQL*Plus premendo CTRL+C
PAUSE altrimenti premere INVIO per continuare...

!cd $ORACLE_HOME/bin

CONNECT &siesuser/&pwd_sies@&dbsid
SET TERMOUT ON;
PROMPT 
PROMPT ===================================================
PROMPT  LANCIO AGGIORNAMENTO MEV-2019_21 - Aggiorna Tabelle Fisse...
PROMPT ===================================================

SET TERMOUT ON;
PROMPT MEV-2019_21 - Aggiorna Tabelle Fisse
SET TERMOUT OFF;
-- OPERAAZIONI PRELIMINARI DGSIA
@aggiornaTF/Crea_Tabella_COMUNE_TF.sql
@aggiornaTF/Insert_COMUNE_TF.sql
@aggiornaTF/XAT_SALVA_TABELLE_PRE_ALLINEAMENTO.prc
@aggiornaTF/Alter_Comune.sql
@aggiornaTF/AGGIORNA_COMUNE.prc
@aggiornaTF/Insert_Comuni_assenti_in_Tabelle_Fisse.sql
@aggiornaTF/Aggiornamento_Comuni_non_presenti_in_COMUNE_TF.sql
@aggiornaTF/VERIFICA_LN_AVVOCATO.prc
@aggiornaTF/AGGIORNAMENTO_COMUNI_DOPO_VERIFICA.sql
@aggiornaTF/VERIFICA_LN_AVVOCATO_2.prc
@aggiornaTF/VALORIZZA_COD_CATASTALE_COMUNE.prc
@aggiornaTF/Aggiorna_cod_catastale_2.sql
@aggiornaTF/Aggiorna_Sede_Giudiziaria_COMUNE.sql
@aggiornaTF/Crea_Tabella_PROVINCIA_TF.sql
@aggiornaTF/Insert_PROVINCIA_TF_finale.sql
@aggiornaTF/AGGIORNA_DOMINIO_PROVINCIA.prc
@aggiornaTF/AGGIORNA_DOMINIO_PROVINCIA_dopo_allineamento.sql
@aggiornaTF/Insert_PROVINCIA_mancanti_in_Tabelle_Fisse.sql
@aggiornaTF/Ripulisci_CG_REF_CODES_PROVINCIA_per_distribuzione.sql
@aggiornaTF/Aggiornamento_CG_REF_CODES_PROVINCIA_esercizio.sql
@aggiornaTF/Crea_Tabella_STATO_NAZIONE_TF.sql
@aggiornaTF/Valorizzazione_cod_catastale_STATO_NAZIONE.sql
@aggiornaTF/Insert_STATO_NAZIONE_TF_finale.sql
@aggiornaTF/AGGIORNA_DOMINIO_NAZIONE.prc
@aggiornaTF/VERIFICA_LN_AVVOCATO_3.prc
@aggiornaTF/Insert_Stati_in_STATO_NAZIONE.sql
@aggiornaTF/Valorizzazione_cod_catastale_STATO_NAZIONE.sql
@aggiornaTF/Ripulisci_CG_REF_CODES_NAZIONE_per_distribuzione.sql
@aggiornaTF/Aggiornamento_CG_REF_CODES_NAZIONE_esercizio.sql
@aggiornaTF/Insert_REGIONE.sql
@aggiornaTF/Alter_CODICI_SIES_NSC.sql
@aggiornaTF/AGGIORNA_CO_DOMAIN_NSC_COMUNE.prc
@aggiornaTF/VALORIZZA_CO_DOMAIN_NSC_COMUNE.prc
@aggiornaTF/Aggiorna_CODICI_SIES_NSC_COMUNE_dopo_valorizzazione.sql
@aggiornaTF/Delete_CODICI_SIES_NSC_dopo_valorizzazione.sql
@aggiornaTF/Valorizza_CO_VAL3_con_data_fine_validita_comune.sql
@aggiornaTF/Ripulisci_CODICI_SIES_NSC_COMUNE_per_distribuzione.sql
@aggiornaTF/Aggiornamento_CODICI_SIES_NSC_COMUNE_esercizio.sql
@aggiornaTF/AGGIORNA_CO_DOMAIN_NSC_NAZIONE.prc
@aggiornaTF/Nazione_SIES_NSC_assenti_in_NSC.sql
@aggiornaTF/Nazione_SIES_NSC_privi_di_Codice_Univoco.sql
@aggiornaTF/Aggiorna_CODICI_SIES_NSC_NAZIONE_dopo_valorizzazione.sql
@aggiornaTF/Ripulisci_CODICI_SIES_NSC_NAZIONE_per_distribuzione.sql
@aggiornaTF/Aggiornamento_CODICI_SIES_NSC_NAZIONE_esercizio.sql
@aggiornaTF/Alter_COMUNI_STATI.sql
--@aggiornaTF/Aggiorna_TABELLA_COMUNI_SIES_AVVOCATURA.sql
@aggiornaTF/AGGIORNA_COMUNI_AVVOCATURA.prc
@aggiornaTF/Aggiorna_TABELLA_STATI_SIES_AVVOCATURA.sql
-- RIEPILOGO x i 29 DISTRETTI
/*
@aggiornaTF/XAT_SALVA_TABELLE_PRE_ALLINEAMENTO.prc
@aggiornaTF/Alter_Comune.sql
@aggiornaTF/Aggiornamento_TABELLA_COMUNE_esercizio.sql
@aggiornaTF/Aggiornamento_CG_REF_CODES_PROVINCIA_esercizio.sql
@aggiornaTF/Insert_REGIONE.sql
@aggiornaTF/Aggiornamento_CG_REF_CODES_NAZIONE_esercizio.sql
@aggiornaTF/Alter_CODICI_SIES_NSC.sql
@aggiornaTF/Aggiornamento_CODICI_SIES_NSC_COMUNE_esercizio.sql
@aggiornaTF/Alter_COMUNI_STATI.sql
@aggiornaTF/Aggiorna_TABELLA_COMUNI_SIES_AVVOCATURA.sql
@aggiornaTF/Aggiorna_TABELLA_STATI_SIES_AVVOCATURA.sql
*/

SET TERMOUT ON;
COMMIT;

PROMPT
PROMPT ==============================================================================
PROMPT *******          ******** | Operazioni completate | *******           ********
PROMPT ==============================================================================
PROMPT Le operazioni sono state registrate sul file
PROMPT &logpath/creazione_&nomeinstallazione..log
PROMPT ==============================================================================
!echo '=============================================================================='
!echo '***** DATA FINE PROCEDURA:' `date +%d/%m/%Y_%r`
!echo '=============================================================================='
PROMPT

DISCONNECT

SPOOL off

PAUSE Premere INVIO per concludere...
EXIT