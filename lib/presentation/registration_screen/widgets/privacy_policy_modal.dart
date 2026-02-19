import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class PrivacyPolicyModal extends StatelessWidget {
  const PrivacyPolicyModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.w)),
      insetPadding: EdgeInsets.all(4.w),
      child: Container(
        constraints: BoxConstraints(maxHeight: 90.h, maxWidth: 95.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.w),
                  topRight: Radius.circular(4.w),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'INFORMATIVA SUL TRATTAMENTO DEI DATI PERSONALI',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Introduction
                    Text(
                      'Ai sensi dell\'art. 13 e ss. del Regolamento UE 679/2016 ("GDPR") e del D.Lgs. 196/2003 e s.m.i., AIOM fornisce le seguenti informazioni in merito al trattamento dei dati personali effettuato attraverso Nutrivita, App che si pone l\'obiettivo di supportare i pazienti oncologici nella gestione di un particolare regime alimentare e di facilitare i flussi informativi con i medici curanti.',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimaryLight,
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // TITOLARE DEL TRATTAMENTO
                    _buildSectionTitle('TITOLARE DEL TRATTAMENTO'),
                    _buildSectionContent(
                        'Titolare del trattamento dei dati effettuato attraverso Nutrivita è AIOM - Associazione Italiana di Oncologia Medica, p.iva n. 11957150151, con sede in Via E. Nöe, 23, Milano, contattabile via posta al suddetto indirizzo ovvero via mail al seguente recapito: aiom.segretario@aiom.it.'),

                    // DATI TRATTATI, NATURA, FINALITA' E BASE GIURIDICA DEL TRATTAMENTO
                    _buildSectionTitle(
                        'DATI TRATTATI, NATURA, FINALITA\' E BASE GIURIDICA DEL TRATTAMENTO'),
                    _buildSectionContent(
                        'Attraverso Nutrivita potranno essere trattate diverse tipologie di dati personali. Per la creazione del profilo utente è necessario fornire un indirizzo e-mail valido e una password personalizzata; l\'utente è altresì tenuto a fornire data di nascita, peso e altezza in quanto necessari alla caratterizzazione nutrizionale del profilo. L\'utente può liberamente inserire ulteriori dati identificativi e di contatto (nome, cognome, genere, e-mail, numero di telefono, luogo di nascita, c.f.) affinché eventuali estrapolazioni dei dati caricati in Nutrivita possano riportare i riferimenti dell\'utente. Nutrivita è stata creata per raccogliere i dati relativi alle abitudini alimentari dell\'utente e può essere arricchita con dati relativi alle attività quotidiane e/o da informazioni di tipo clinico (diagnosi, patologie concomitanti, trattamenti in corso, farmaci periodici); tali informazioni potrebbero essere trattate anche a seguito delle risposte fornite ai vari questionari proposti all\'utente. L\'utente potrà inoltre caricare lo schema nutrizionale prescritto dal nutrizionista affinché il sistema evidenzi eventuali discrepanze significative. Nutrivita prevede un modulo dedicato al reporting dei dati inseriti a sistema e dei risultati della compilazione dei questionari.'),
                    _buildSectionContent(
                        'Tranne che per i dati necessari all\'apertura del profilo e alla caratterizzazione nutrizionale del profilo, il cui mancato inserimento non permette all\'utente di usufruire dei servizi resi attraverso Nutrivita, è l\'utente a decidere quali informazioni registrare e con chi condividerle, attraverso la possibilità di estrapolare e inviare, a mezzo mail o altra app di messaggistica i dati caricati. Si invita pertanto l\'utente a prestare attenzione alle informazioni caricate in Nutrivita attraverso il sistema di caricamento foto (potrebbero ad esempio essere acquisite ulteriori tipologie di dati riferibili anche a terzi; es. in caso di caricamento di una prescrizione medica, con sottoscrizione del medico curante).'),
                    _buildSectionContent(
                        'Tutti i dati caricati da Nutrivita sono crittografati e l\'utente può accedervi solo attraverso il proprio codice di accesso.'),
                    _buildSectionContent(
                        'Si precisa che saranno oggetto di trattamento anche i log di controllo dell\'accesso ai dati, di controllo delle attività di amministrazione e di controllo degli eventi di sistema.'),

                    _buildSubSectionTitle(
                        'Le finalità del trattamento sono le seguenti:'),
                    _buildBulletPoint(
                        'permettere all\'utente di effettuare un prescreening NRS (Nutritional Risk Screening), di realizzare un diario alimentare, di avere un supporto nella gestione di un particolare regime alimentare nonché di migliorare il flusso informativo nei confronti del/i medico/i curante/i, attraverso la registrazione di dati personali, obbligatori o facoltativi, anche appartenenti a categorie particolari di dati, da parte dell\'utente;'),
                    _buildBulletPoint(
                        'valutare nel tempo l\'efficacia dell\'iniziativa offerta da AIOM, volta a supportare i pazienti oncologici nella gestione di un particolare regime alimentare e facilitare i rapporti con i medici curanti, attraverso l\'esame del numero di utenti registrati;'),
                    _buildBulletPoint(
                        'effettuare controlli finalizzati a garantire la conformità delle misure organizzative e tecniche adottate per la gestione dei dati personali, incluse le procedure in tema di cancellazione dei dati, attraverso la gestione dei log delle attività.'),

                    _buildSubSectionTitle(
                        'Le basi giuridiche del trattamento sono rispettivamente date da:'),
                    _buildBulletPoint(
                        'il consenso espresso dall\'utente in relazione al trattamento dei dati effettuato attraverso Nutrivita (art. 6.1.a e art. 9.2.a GDPR);'),
                    _buildBulletPoint(
                        'il legittimo interesse di AIOM a promuovere la prevenzione, la cura e la gestione globale del paziente oncologico (art. 6.1.f GDPR), offrendo un\'applicazione che possa supportare i pazienti oncologici nella gestione di un particolare regime alimentare e di facilitare i rapporti con i medici curanti;'),
                    _buildBulletPoint(
                        'la necessità di adempiere ad un obbligo legale al quale è soggetto il Titolare del trattamento (6.1.c GDPR), tra cui provvedere all\'avvio delle procedure di cancellazione dei dati degli utenti in caso di inutilizzo dell\'App e di verifica della conformità delle misure organizzative e tecniche adottate per la gestione dei dati personali.'),

                    _buildSectionContent(
                        'Il consenso espresso in relazione al trattamento dei dati personali potrà essere in ogni momento revocato. La revoca del consenso non pregiudica la liceità del trattamento basata sul consenso prima della revoca.'),

                    // DESTINATARI DEI DATI
                    _buildSectionTitle('DESTINATARI DEI DATI'),
                    _buildSectionContent(
                        'I Dati potranno essere comunicati a soggetti che agiscono in qualità di titolari o responsabili del trattamento ai sensi dell\'art. 28 GDPR, al fine di garantire il funzionamento tecnico del sistema.'),

                    // TRASFERIMENTO DEI DATI AL DI FUORI DELLO SPAZIO ECONOMICO EUROPEO
                    _buildSectionTitle(
                        'TRASFERIMENTO DEI DATI AL DI FUORI DELLO SPAZIO ECONOMICO EUROPEO'),
                    _buildSectionContent(
                        'L\'utilizzo di Nutrivita prevede il trasferimento, l\'archiviazione e più in generale il trattamento dei dati personali dell\'utente solo in Paesi dello Spazio Economico Europeo o in altri Paesi sottoposti al medesimo grado di tutela.'),

                    // CONSERVAZIONE DEI DATI
                    _buildSectionTitle('CONSERVAZIONE DEI DATI'),
                    _buildSectionContent(
                        'La durata del trattamento dei dati dell\'utente e il periodo di conservazione dipendono dalla finalità e dalla base giuridica del trattamento. Più precisamente: i. in relazione ai dati raccolti per permettere all\'utente di accedere alle varie funzionalità di Nutrivita, i dati saranno alternativamente conservati: - sino alla cancellazione, da parte dell\'utente, dei dati eseguita direttamente dall\'App; in caso revoca del consenso, la cancellazione avverrà automaticamente per tutti i dati inclusi quelli relativi all\'attivazione del profilo utente; la disinstallazione dell\'App comporterà la cancellazione immediata dei dati localmente salvati, che saranno definitivamente eliminati 180 giorni dopo l\'invito ad accedere nuovamente all\'App, inoltrato dopo 30 giorni di inattività, qualora non segua l\'accesso; - sino a 180 giorni dopo l\'invito ad accedere nuovamente a Nutrivita, inoltrato dopo 30 giorni di inattività, qualora non segua l\'accesso; - sino a 60 giorni dopo la comunicazione dal ritiro dal mercato dell\'App; ii. in relazione al trattamento dei dati relativi ai consensi espressi, sino a 5 anni dalla cancellazione del profilo utente ovvero sino a 5 anni dal definitivo ritiro dell\'App.'),

                    // DIRITTI DEGLI INTERESSATI
                    _buildSectionTitle('DIRITTI DEGLI INTERESSATI'),
                    _buildSectionContent(
                        'Gli interessati potranno in ogni momento chiedere di conoscere l\'origine, la finalità e le modalità su cui si basa il trattamento, di ottenere l\'accesso agli stessi, l\'aggiornamento, la rettifica, l\'integrazione, la cancellazione, la trasformazione in forma anonima, la limitazione del trattamento, di disporre il blocco dei dati trattati in violazione di legge e di ottenerne copia su un formato strutturato, di uso comune e leggibile da dispositivo automatico ovvero di trasmettere tali dati a un altro titolare del trattamento senza impedimenti, di revocare il consenso espresso e di non essere sottoposti a una decisione basata esclusivamente su un trattamento automatizzato. Gli interessati potranno altresì proporre reclamo al reclamo all\'Autorità di Controllo, rappresentata in Italia dal Garante per la Protezione dei Dai Personali (www.garanteprivacy.it).'),
                    _buildSectionContent(
                        'Per esercitare i propri diritti, gli interessati potranno scrivere a AIOM - Associazione Italiana di Oncologia Medica AIOM Servizi S.r.l., ai recapiti sopra precisati.'),

                    SizedBox(height: 4.h),

                    // IMPORTANTE Section
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(3.w),
                        border: Border.all(color: Colors.orange.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'IMPORTANTE! Privacy e Termini di Utilizzo di Nutrivita',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'I dati gestiti attraverso Nutrivita possono rivelare le tue condizioni di salute. Per poter accedere ai servizi di Nutrivita è necessario esprimere il tuo consenso al trattamento. Leggi con attenzione la Privacy Policy e ricorda che il tuo consenso potrà essere sempre revocato; in caso di revoca del consenso, il tuo profilo sarà rimosso e i tuoi dati cancellati.',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: Colors.orange.shade700,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Ti chiediamo inoltre di rispettare i Termini e le condizioni di utilizzo.',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: Colors.orange.shade700,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Con la presente',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            '[] acconsento al trattamento di dati personali',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: Colors.orange.shade700,
                            ),
                          ),
                          Text(
                            '[] dichiaro di conoscere e accettare i termini e le condizioni di utilizzo',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4.w),
                  bottomRight: Radius.circular(4.w),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 3.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                  ),
                  child: Text(
                    'Ho letto l\'informativa',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 3.h, bottom: 1.h),
      child: Text(
        title,
        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          color: AppTheme.lightTheme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 13.sp,
        ),
      ),
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 2.h, bottom: 1.h),
      child: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          color: AppTheme.textPrimaryLight,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Text(
        content,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.textPrimaryLight,
          height: 1.5,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildBulletPoint(String content) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimaryLight,
                height: 1.4,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}
