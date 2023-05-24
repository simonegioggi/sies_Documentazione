-------------------------------------------------------------------------------
-- Scopo ..: Creazione degli oggetti del database del sistema informativo
-- Note ...: eseguire da SQLPLUS /NOLOG
--
-- MEV-2019_21 - ripristino_bonifica_db
-------------------------------------------------------------------------------

WHENEVER SQLERROR CONTINUE
WHENEVER OSERROR CONTINUE

PROMPT Procedura di installazione versione MEV-2019_21 - ripristino_bonifica_db di SIES
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
PROMPT  LANCIO AGGIORNAMENTO MEV-2019_21 - ripristino_bonifica_db...
PROMPT ===================================================

SET TERMOUT ON;
PROMPT MEV-2019_21 - ripristino_bonifica_db
SET TERMOUT OFF;
@bonifica/XBA_RESTORE_TABELLE_AVVOCATI.prc

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