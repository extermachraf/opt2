import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TermsConditionsModal extends StatelessWidget {
  const TermsConditionsModal({Key? key}) : super(key: key);

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
                      'Termini e Condizioni di Utilizzo — Nutrivita',
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
                    // Main Title
                    Text(
                      'TERMINI E CONDIZIONI DI UTILIZZO — APP "NUTRIVITA"',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Introduzione
                    _buildSectionTitle('Introduzione'),
                    _buildSectionContent(
                      'L\'applicazione mobile "Nutrivita" (di seguito, l\'"App") è un servizio digitale fornito da AIOM – Associazione Italiana di Oncologia Medica (di seguito, "AIOM" o l\'"Ente"), progettato per supportare pazienti oncologici nel monitoraggio e nella gestione del proprio stato nutrizionale prima, durante e dopo le terapie oncologiche.',
                    ),

                    _buildSectionContent(
                      'In particolare, tramite l\'App, l\'utente può:',
                    ),
                    _buildBulletPoint(
                      'registrare informazioni nutrizionali sui pasti e alimenti consumati, sul relativo apporto calorico e nutritivo;',
                    ),
                    _buildBulletPoint(
                      'monitorare l\'andamento nel tempo dei nutrienti assunti;',
                    ),
                    _buildBulletPoint(
                      'registrare quotidianamente il proprio peso e monitorarne l\'evoluzione nel tempo;',
                    ),
                    _buildBulletPoint(
                      'consultare un database di alimenti e di ricette culinarie con i valori nutrizionali associati a ciascun elemento;',
                    ),
                    _buildBulletPoint(
                      'consultare contenuti educativi testuali su nutrizione e oncologia;',
                    ),
                    _buildBulletPoint(
                      'eseguire quiz a risposta multipla a scopo educativo;',
                    ),
                    _buildBulletPoint(
                      'compilare questionari sullo stato nutrizionale e sulla qualità di vita (Nutritional Risk Screening – NRS 2002; Malnutrition Universal Screening Tool – MUST; Edmonton Symptoms Assessment Scale – ESAS; Sarcopenia Screening - SARC-F; Valutazione del Rischio Nutrizionale; Short-Form Health Survey - SF-12);',
                    ),
                    _buildBulletPoint(
                      'generare un report in PDF, finalizzato alla possibilità di condividere le informazioni registrate in App con professionisti sanitari.',
                    ),

                    _buildSectionContent(
                      'L\'App non sostituisce in alcun modo il parere medico né rappresenta un dispositivo medico. Le informazioni fornite hanno esclusivamente finalità informative e di supporto all\'utente.',
                    ),

                    _buildSectionContent(
                      'L\'accesso alle funzionalità di cui sopra è subordinato all\'installazione dell\'App sul dispositivo mobile dell\'utente. L\'App è ottimizzata per i dispositivi mobile (smartphone) supportati da sistemi operativi Android e iOS, superiori rispettivamente alle versioni 5.x e 9.x.',
                    ),

                    _buildSectionContent(
                      'Per accedere al Servizio, è necessario svolgere un processo di registrazione dell\'utenza con i seguenti dati obbligatori:',
                    ),
                    _buildBulletPoint('email'),
                    _buildBulletPoint(
                      'password corrispondente ai criteri di sicurezza previsti (lunghezza minima di 8 caratteri, comprensiva di almeno una lettera maiuscola, almeno una lettera minuscola, almeno un numero e almeno un carattere speciale) e strettamente personale, non cedibile a terzi',
                    ),
                    _buildBulletPoint('data di nascita'),

                    _buildSectionContent(
                      'All\'atto della prima registrazione all\'App, l\'utente dovrà altresì accettare i presenti termini e condizioni di utilizzo, nonché prendere visione e accettare i contenuti della privacy policy relativa al trattamento dei dati personali specificamente inerente all\'App.',
                    ),

                    _buildSectionContent(
                      'Scaricando, installando, o utilizzando l\'App, oppure manifestando in modalità informatica (i.e., apponendo un segno di spunta (flag) su una casella di selezione (checkbox)), il consenso e l\'accettazione, l\'utente manifesta la sua esplicita volontà a conferma di aver letto compreso, accettato, ed espresso il consenso ai termini di utilizzo e alla privacy policy inerenti all\'App.',
                    ),

                    _buildSectionContent(
                      'Il percorso di registrazione richiede inoltre facoltativamente i seguenti dati, il cui inserimento è a totale discrezione dell\'utente:',
                    ),
                    _buildBulletPoint('genere alla nascita'),
                    _buildBulletPoint('nome'),
                    _buildBulletPoint('cognome'),
                    _buildBulletPoint('numero di telefono'),
                    _buildBulletPoint('luogo di nascita'),
                    _buildBulletPoint('codice fiscale'),
                    _buildBulletPoint('comune di residenza'),

                    // Idoneità e Accesso
                    _buildSectionTitle('Idoneità e Accesso'),
                    _buildSectionContent(
                      'L\'App è concessa in uso a titolo completamente gratuito, nel rispetto dei termini di utilizzo imposti dall\'Ente e dalle piattaforme e store di distribuzione. Per utilizzare l\'App e il Servizio, l\'utente deve soddisfare i seguenti requisiti in relazione ai quali dichiara, garantisce, e accetta, che:',
                    ),
                    _buildBulletPoint(
                      'ha il pieno potere e la capacità giuridica per concludere questo accordo;',
                    ),
                    _buildBulletPoint(
                      'è in possesso dei dispositivi informatici (smartphone) e degli accessi internet (in relazione ai quali sosterrà autonomamente ogni spesa, compresi gli eventuali costi che verranno addebitati dall\'operatore telefonico) necessari per utilizzare l\'App;',
                    ),
                    _buildBulletPoint(
                      'nell\'utilizzare l\'App, non violerà alcun diritto dell\'Ente, ivi compresi i presenti termini di utilizzo.',
                    ),
                    _buildBulletPoint('fornirà dati veritieri.'),

                    // Utilizzo dell'App e Diritti
                    _buildSectionTitle('Utilizzo dell\'App e Diritti'),
                    _buildSectionContent(
                      'A condizione che l\'utente agisca in conformità alle disposizioni del presente accordo e nel rispetto delle vigenti disposizioni di legge, l\'Ente concede una licenza limitata, revocabile, non esclusiva, non cedibile, non trasferibile e non sub-licenziabile, avente ad oggetto il diritto di utilizzare l\'App e di memorizzare sul Suo dispositivo mobile, le informazioni e i dati con essa veicolati.',
                    ),

                    _buildSectionContent(
                      'L\'App è, e resta, di esclusiva proprietà dell\'Ente. L\'utente ha il diritto di scaricare e installare una versione dell\'App su qualsiasi dispositivo di sua proprietà, ed eseguire tale versione dell\'App esclusivamente per uso personale, non commerciale, entro i limiti delle funzionalità immediatamente e direttamente rese disponibili dall\'App.',
                    ),

                    _buildSectionContent(
                      'L\'utente si impegna a utilizzare l\'App esclusivamente nel rispetto ed entro i limiti previsti dal presente accordo, e in ossequio alle vigenti disposizioni di legge. In particolare, l\'utente non può:',
                    ),
                    _buildBulletPoint(
                      'creare opere derivate basate sull\'App;',
                    ),
                    _buildBulletPoint(
                      'utilizzare l\'App per scopi diversi da quelli indicati nel presente accordo;',
                    ),
                    _buildBulletPoint('duplicare o copiare l\'App;'),
                    _buildBulletPoint(
                      'vendere, assegnare, sub-licenziare, distribuire, trasferire o rendere disponibile l\'App o qualsiasi copia di essa in qualsiasi forma a terze parti;',
                    ),
                    _buildBulletPoint(
                      'modificare, adattare, alterare, tradurre, decompilare, disassemblare o decodificare l\'App, salvo nella misura in cui tale divieto non sia consentito dalla legge applicabile;',
                    ),
                    _buildBulletPoint(
                      'rimuovere o alterare le note e le indicazioni relative ai diritti sull\'App.',
                    ),

                    _buildSectionContent(
                      'Salvo quanto espressamente previsto, il presente accordo non trasferisce alcun diritto di proprietà intellettuale o industriale sui contenuti veicolati attraverso l\'App o il Servizio, ivi compresi eventuali marchi, segni distintivi o altre opere o contenuti soggetti a privativa, che restano, pertanto, di esclusiva titolarità dei rispettivi aventi diritto. Fermo restando l\'impegno di garantire il corretto funzionamento dell\'App, l\'Ente si riserva il diritto di modificare, sospendere o terminare l\'App, in qualsiasi momento, e a sua esclusiva discrezione. Ugualmente l\'utente potrà, in qualsiasi momento e senza preavviso alcuno, cessare di utilizzare l\'App e/o rimuoverla da uno o più dispositivi sui quali è stata legittimamente installata.',
                    ),

                    _buildSectionContent(
                      'L\'App è dotata di misure di sicurezza e di procedure di autenticazione finalizzate a consentire l\'accesso ai dati esclusivamente a favore dell\'utente legittimato ad accedervi. Ciò non di meno, l\'utente è tenuto alla massima diligenza nella custodia delle credenziali di accesso e nella custodia del suo dispositivo mobile. L\'utente è altresì informato della circostanza che, qualora dovesse procedere, a sua discrezione, a esportare al di fuori dell\'App, memorizzandoli sul Suo dispositivo mobile, documenti e informazioni estratti da Nutrivita, le misure di sicurezza implementate non saranno più efficaci per proteggere i Suoi dati.',
                    ),

                    // Clausola Medica
                    _buildSectionTitle('Clausola Medica'),
                    _buildSectionContent(
                      'L\'App non sostituisce in nessun caso il parere medico professionale. I contenuti dell\'App non possono intendersi come diagnosi o prescrizione. Per decisioni di salute l\'utente deve consultare un medico.',
                    ),

                    // Aggiornamenti
                    _buildSectionTitle('Aggiornamenti'),
                    _buildSectionContent(
                      'L\'Ente si riserva la facoltà di poter, in qualsiasi momento, e a sua esclusiva discrezione:',
                    ),
                    _buildBulletPoint(
                      'modificare, sospendere, o terminare la fornitura dell\'App;',
                    ),
                    _buildBulletPoint(
                      'modificare o sostituire il presente accordo.',
                    ),

                    _buildSectionContent(
                      'Eventuali modifiche dell\'App o del presente accordo avverranno, abitualmente, mettendo a disposizione un aggiornamento dell\'App la cui installazione potrà essere necessaria per continuare ad utilizzarla. Installando una nuova versione dell\'App, o comunque continuando a utilizzare l\'App, l\'utente accetta le modifiche disposte dall\'Ente. Qualora non intenda aderire alle modifiche introdotte, quale unico rimedio, l\'utente potrà in qualsiasi momento e senza alcun costo, cessare di utilizzare l\'App, rimuovendo la stessa dai dispositivi sui quali è stata legittimamente installata. L\'Ente non garantisce inoltre che l\'App o il Servizio operino sempre senza errori o senza interruzioni.',
                    ),

                    // Responsabilità
                    _buildSectionTitle('Responsabilità'),
                    _buildSectionContent(
                      'Fermo restando l\'impegno nel cercare di garantire la continuità dell\'App, l\'Ente non presta alcuna garanzia e, nei limiti previsti dalla normativa applicabile, non sarà in alcun modo responsabile, per le ipotesi di ritardi, imprecisioni nell\'aggiornamento delle informazioni, malfunzionamenti, interruzioni e/o sospensioni dell\'accesso ai dati causati da: errato utilizzo da parte dell\'utente dell\'App; malfunzionamenti di qualsiasi tipo del dispositivo mobile dall\'utente utilizzato; interruzioni totali o parziali, o in ogni caso inefficienze, dei servizi forniti dagli operatori di telecomunicazioni o da qualunque altro soggetto terzo addetto alla trasmissione dei dati; operazioni di manutenzione effettuate dall\'Ente al fine di salvaguardare l\'efficienza e la sicurezza dell\'App; qualsiasi altra causa non imputabile all\'Ente.',
                    ),

                    // Comunicazioni
                    _buildSectionTitle('Comunicazioni'),
                    _buildSectionContent(
                      'Per inviare qualunque tipo di comunicazione relativa all\'App, o al presente accordo, l\'utente potrà contattare l\'Ente al seguente indirizzo di posta elettronica:',
                    ),
                    _buildSectionContent('aiom.segretario@aiom.it'),

                    // Recesso
                    _buildSectionTitle('Recesso'),
                    _buildSectionContent(
                      'I termini di utilizzo qui riportati rimarranno in vigore sino a quando gli stessi non dovessero essere superati da un aggiornamento o modifica, introdotti secondo le modalità previste da questo stesso accordo. Fermo restando l\'impegno di garantire il corretto funzionamento dell\'App, l\'Ente potrà recedere unilateralmente dal presente accordo, in qualsiasi momento, senza alcun preavviso, e senza alcun costo o onere, terminando la funzionalità dell\'App. Ugualmente, l\'utente potrà, in qualsiasi momento, senza alcun preavviso e senza sopportazione di alcun costo, cessare l\'utilizzo dell\'App, rimuovendo l\'App dai dispositivi sui quali è stata legittimamente installata.',
                    ),

                    // Legge e Foro
                    _buildSectionTitle('Legge e Foro'),
                    _buildSectionContent(
                      'Il presente accordo è disciplinato dalla legge italiana. L\'Ente potrà, a sua discrezione, rendere disponibile il presente documento anche in una lingua diversa dall\'Italiano. L\'utente è perfettamente consapevole e accetta che tale eventuale traduzione verrà fornita a scopo esclusivamente illustrativo e che la versione in lingua italiana regolerà il suo rapporto con l\'Ente. Per qualsiasi controversia nascente dal presente accordo sarà competente in via esclusiva il Foro di Milano, in Italia.',
                    ),

                    SizedBox(height: 3.h),
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
                    'Chiudi',
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
          fontSize: 14.sp,
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
            '- ',
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
