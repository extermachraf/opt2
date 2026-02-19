import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../dashboard/widgets/quick_action_sheet_widget.dart';
import './widgets/educational_section_widget.dart';
import './widgets/search_bar_widget.dart';
import '../assessment_screen/widgets/quiz_tab_widget.dart';

class PatientEducation extends StatefulWidget {
  const PatientEducation({super.key});

  @override
  State<PatientEducation> createState() => _PatientEducationState();
}

class _PatientEducationState extends State<PatientEducation> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredSections = [];
  List<String> _bookmarkedSections = [];
  String _currentView = 'education'; // 'education', 'quiz_selection', or 'quiz'
  String _selectedQuizCategory = '';
  int _selectedNavIndex = 0;

  final List<Map<String, dynamic>> nutritionModules = [
    {
      'id': 'la_nutrizione',
      'title': 'La Nutrizione',
      'icon': 'restaurant',
      'color': const Color(0xFF4CAF50),
      'content':
          ''' Moduli Informativi – La Nutrizione\n\n La nutrizione è "il complesso dei processi biologici che consentono o condizionano la crescita, lo sviluppo e l'integrità dell'organismo vivente in relazione alla disponibilità di energia, nutrienti e altre sostanze di interesse nutrizionale".\n\n Nutrizione e alimentazione sono due concetti differenti, in quanto per alimentazione si intende "la scelta e il consumo consapevole da parte dell'individuo di alimenti e bevande nelle loro varie combinazioni".\n\n L'alimentazione ricopre un ruolo fondamentale per la qualità di vita. Il pasto è un momento imprescindibile non solo da un punto di vista delle esigenze nutrizionali ma anche da quello familiare e sociale.\n\n I pazienti oncologici, in particolare quelli affetti da neoplasie polmonari e dell'apparato gastrointestinale o con tumori in fase avanzata, incontrano spesso problemi nel mantenere un'alimentazione consona.\n\n Il regime alimentare ridotto, oltre alle alterazioni del metabolismo indotte dal tumore all'organismo, è responsabile della malnutrizione per difetto, segnata da perdita di peso corporeo e massa muscolare. La diminuzione dell'alimentazione si traduce in un abbassamento della tolleranza ai trattamenti, peggiorando la qualità di vita e aumentando la mortalità.\n\n Il caso contrario riguarda la malnutrizione per eccesso, che rappresenta un rischio per lo sviluppo di patologie metaboliche.\n\n Alla luce della scarsa consapevolezza fra pazienti e professionisti sanitari della prevalenza e delle conseguenze della cattiva malnutrizione nel malato oncologico, è necessario che la valutazione multidimensionale del malato oncologico consideri anche l'aspetto nutrizionale.\n\n I capitoli contenuti in questo modulo contengono un catalogo di domande e risposte molto pratiche sulle principali tematiche legate alla nutrizione nei pazienti affetti da neoplasie:\n- Il tumore e la nutrizione\n- Che cosa fare prima/durante la terapia\n- La perdita di peso\n- Alimenti e nutrienti\n- Mantenersi in salute\n- Sfatare qualche mito sulla nutrizione\n\n Si precisa che tutte le informazioni fornite in questo modulo non sono da intendersi sostitutive del parere dei medici specialisti. ''',
    },
    {
      'id': 'prima_e_durante_la_terapia',
      'title': 'Cosa fare in caso di...',
      'icon': 'local_hospital',
      'color': const Color(0xFF03A9F4),
      'content':
          ''' Prima e durante la terapia\n\n È cruciale affrontare un intervento chirurgico in uno stato nutrizionale ottimale per ridurre il rischio di complicazioni. Per questo, prima di un'operazione, il paziente viene sottoposto a screening per prepararlo con diete e integratori specifici, come previsto da protocolli quali l'immunonutrizione o l'ERAS.\n\n Dopo l'intervento, specialmente se a carico dell'apparato digerente, è fondamentale rivolgersi a un team di nutrizione clinica per elaborare un piano adeguato.\n\n Durante le terapie, nessun alimento è assolutamente controindicato se consumato con moderazione. È comunque consigliabile limitare gli zuccheri semplici (soprattutto durante terapie cortisoniche), assicurare un adeguato apporto di proteine e preferire alimenti ricchi di acidi grassi omega-3.\n\n Un paziente ben nutrito tollera meglio gli effetti collaterali che le terapie possono avere.\n\n Consigli pratici per gestire gli effetti collaterali:\n- Bocca che brucia: Bere liquidi nutrienti, consumare cibi freddi, usare una cannuccia ed evitare cibi salati, speziati o ruvidi. Ammorbidire i cibi con salse non piccanti.\n- Bocca secca: Bere spesso piccoli sorsi, succhiare ghiaccio e mantenere i cibi umidi. Caramelle o gomme possono stimolare la salivazione.\n- Lingua bianca: Pulire la lingua con un batuffolo di cotone imbevuto in una soluzione di acqua e bicarbonato.\n- Difficoltà a deglutire (disfagia): Consumare cibi morbidi, sformati o frullati.\n- Nausea e vomito: Esistono farmaci antiemetici molto efficaci. È utile mangiare poco e spesso ed evitare cibi con odori e sapori forti.\n- Senso di sazietà precoce: Preferire pasti piccoli e frequenti e cibi molto calorici, ma senza eccedere con i grassi.\n- Stitichezza: Aumentare il consumo di fibre (prodotti integrali, frutta e verdura con la buccia), bere molto e fare attività fisica.\n- Diarrea: Ridurre le fibre, bere molto per reintegrare i liquidi, evitare alcol e caffè e consumare pasti leggeri e frequenti. I probiotici, su prescrizione medica, possono essere utili.\n- Pancia gonfia: Mangiare e bere lentamente, evitare cibi che producono gas (fagioli, cavoli, uva) e bevande gassate. L'attività fisica leggera può aiutare.\n- Alterazioni del gusto: Un sapore metallico può essere causato dalla chemioterapia, da carenze di oligoelementi o da ridotta salivazione. Per rendere i cibi più gradevoli, si possono usare spezie, marinare la carne o acidificare la bocca con una fettina di limone prima del pasto.\n\n Per condizioni specifiche come colostomia, ileostomia o laringectomia, è necessaria un'alimentazione personalizzata definita dal medico.\n\n Il tumore alla mammella necessita di attenzione al peso. Le donne trattate per tumore al seno devono prestare attenzione all'aumento di peso, dovuto al cambiamento del metabolismo, che è un fenomeno frequente e può peggiorare la prognosi.\n\n L'immunoterapia può avere un impatto sulla flora intestinale. Studi recenti indicano che il microbiota intestinale ha un ruolo chiave nella risposta all'immunoterapia, e un'alimentazione ricca di fibre sembra essere correlata a una maggiore efficacia dei trattamenti. ''',
    },
    {
      'id': 'perdita_di_peso',
      'title': 'La Perdita di Peso',
      'icon': 'fitness_center',
      'color': const Color(0xFFFF9800),
      'content':
          ''' La perdita di peso\n\n L'importanza di non perdere peso\nMantenere o rallentare la perdita di peso preserva la funzione del sistema immunitario e muscolare, rendendo l'organismo più resistente alle infezioni e migliorando la risposta ai trattamenti antitumorali.\n\n Il calo ponderale diminuisce la capacità del corpo di rispondere ai trattamenti, aumentando il rischio di mortalità. Per questo motivo, non deve essere ignorata né sottovalutata dall'oncologo né dal paziente, che deve richiedere di essere pesato regolarmente.\n\n Perché può avvenire una perdita di peso?\n- Alterazioni metaboliche: la crescita tumorale induce cambiamenti sistemici, scatenando una risposta immunitaria che produce sostanze che mutano i processi metabolici. Questo può causare anoressia e perdita di massa muscolare (cachessia).\n- Terapie antitumorali: possono causare riduzione dell'appetito, debolezza muscolare, nausea, vomito, ulcere orali e alterazioni delle mucose gastrointestinali.\n- Ostruzione meccanica: tumori localizzati nel cavo orale, faringe, esofago o stomaco possono impedire il passaggio del cibo.\n- Intervento chirurgico esteso: può alterare la digestione e l'assorbimento dei nutrienti.\n\n Contrastare la perdita di peso\nSi raccomanda l'elaborazione di un piano dietetico personalizzato nel contesto di un programma di supporto nutrizionale, conforme alle preferenze del paziente.\n\nSe l'alimentazione naturale non è sufficiente, essa deve essere integrata con supplementi nutrizionali orali o, se necessario, con nutrizione artificiale (enterale o parenterale).\n\nÈ importante controllare il proprio peso periodicamente e segnalare variazioni significative al medico curante. L'anoressia può essere trattata farmacologicamente, su prescrizione medica. ''',
    },
    {
      'id': 'alimenti_e_nutrienti',
      'title': 'Alimenti e Nutrienti',
      'icon': 'emoji_food_beverage',
      'color': const Color(0xFFE91E63),
      'content':
          ''' Alimenti e nutrienti\n\n Gli alimenti sono i prodotti che consumiamo e che contengono i nutrienti essenziali per il funzionamento del corpo. Sono suddivisi in sette gruppi principali:\n- Carni e pesce\n- Latte e derivati\n- Cereali\n- Legumi\n- Grassi da condimento\n- Ortaggi\n- Frutta\n\n La piramide alimentare illustra un regime dietetico equilibrato. Gli alimenti alla base dovrebbero essere consumati in maggiori quantità e più spesso, mentre quelli al vertice con moderazione.\n\n I nutrienti principali:\n- Carboidrati: principale fonte di energia. Apporto ideale: circa 30 calorie per chilo di peso corporeo.\n- Proteine: essenziali per la riparazione dei tessuti. Fabbisogno in paziente oncologico: 1,2-1,5 g per chilo al giorno.\n- Lipidi: fonte di energia e componente strutturale delle cellule.\n- Vitamine: essenziali per il normale funzionamento del corpo. Integratori vitaminici solo su consiglio medico.\n\n Supplementi e nutraceutici:\n- Supplementi Nutrizionali Orali (SNO): alimenti a fini medici speciali, bilanciati in calorie, proteine, vitamine e minerali.\n- Supplementi Modulari: nutrienti specifici in polvere da aggiungere a cibi e bevande.\n- Bevande Ipernutritive: frullati preparati in casa con frutta o latte, eventualmente arricchiti da supplementi.\n- Nutraceutici: principi nutritivi con proprietà farmacologiche (aminoacidi a catena ramificata, EPA, HMB, carnitina), utili per contrastare la perdita di massa muscolare e appetito. Sempre sotto controllo medico. ''',
    },
    {
      'id': 'mantenersi_in_salute',
      'title': 'Mantenersi in Salute',
      'icon': 'self_improvement',
      'color': const Color(0xFF8BC34A),
      'content':
          ''' Mantenersi in salute\n\n Una volta conclusi i trattamenti:\n- Chi ha perso peso dovrebbe concentrarsi sul recupero.\n- Chi tende a ingrassare deve adottare una dieta adeguata per prevenirlo.\n\n Obiettivo per tutti: alimentazione sana, variata e bilanciata.\n\n Per mantenere il peso ideale:\n- Ridurre l'apporto calorico\n- Aumentare l'attività fisica\n\n Buone pratiche:\n- Limitare il consumo di cibi processati e ultraprocessati.\n- Ridurre i grassi di origine animale.\n- Consumare almeno cinque porzioni di frutta e verdura al giorno.\n- Diminuire zucchero e sale, insaporendo i piatti con erbe e spezie.\n\n Uno stile di vita sano si fonda su una corretta alimentazione e attività fisica regolare. ''',
    },
    {
      'id': 'sfatiamo_qualche_mito',
      'title': 'Sfatiamo qualche mito',
      'icon': 'fact_check',
      'color': const Color(0xFF795548),
      'content':
          ''' Sfatiamo qualche mito\n\n - I "supercibi" prevengono i tumori?\nNo, nessun singolo alimento può prevenire un tumore. Conta una dieta complessivamente variata e bilanciata, come quella mediterranea.\n\n - Gli alimenti processati e ultraprocessati sono pericolosi?\nNo, per quelli processati se consumati con moderazione; sì, per quelli ultraprocessati, ricchi di additivi e poveri di nutrienti, associati a un maggior rischio di tumori e altre malattie.\n\n - Esistono cibi che riducono gli effetti collaterali delle terapie?\nNo, tuttavia un paziente ben nutrito sopporta meglio gli effetti collaterali.\n\n - Esiste una dieta anti-tumore?\nNo, non esiste una dieta specifica, ma è fondamentale un'alimentazione sana ed equilibrata.\n\n - Una dieta "acida" provoca il tumore?\nNo, gli alimenti non possono alterare il pH del corpo, finemente regolato dall'organismo stesso.\n\n - Gli omega-3 del pesce combattono il tumore?\nNo, sebbene abbiano effetti antinfiammatori e aiutino a prevenire la perdita di peso, non ci sono prove di un effetto diretto sulla crescita tumorale nell'uomo.\n\n - Assumere dolci fa crescere il tumore?\nNo, non esiste un'evidenza diretta, ma è importante evitare livelli cronicamente alti di insulina.\n\n - La carne rossa provoca il tumore?\nNo, se consumata con moderazione (non più di 500 g a settimana) e cotta in modo adeguato; le carni conservate andrebbero invece evitate.\n\n - Conviene diventare vegetariani per curare i tumori?\nNo, una dieta vegetariana o vegana non è indicata per i malati oncologici che necessitano di adeguato apporto di proteine e calorie anche da fonti animali.\n\n - Ridurre le calorie migliora la salute del paziente oncologico?\nNo, una dieta ipocalorica durante le terapie può causare perdita di massa muscolare e malnutrizione.\n\n - Il digiuno cura il tumore?\nNo, non vi è prova scientifica; una drastica restrizione alimentare è dannosa.\n\n - L'attività fisica fa male durante la malattia?\nNo, un'attività moderata e personalizzata migliora la qualità della vita.\n\n - La cottura al microonde è rischiosa?\nNo, non è dimostrato che aumenti il rischio di tumore.\n\n - Le muffe sono cancerogene?\nSì, ma solo alcune: le aflatossine, prodotte da certi tipi di muffe, sono cancerogene e possono causare il tumore del fegato se assunte in grandi quantità. ''',
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredSections = nutritionModules;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToQuiz() {
    setState(() {
      _currentView = 'quiz_selection';
    });
  }

  void _navigateToEducation() {
    setState(() {
      _currentView = 'education';
    });
  }

  void _navigateToSpecificQuiz(String category) {
    setState(() {
      _selectedQuizCategory = category;
      _currentView = 'quiz';
    });
  }

  void _navigateBackToQuizSelection() {
    setState(() {
      _currentView = 'quiz_selection';
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSections = nutritionModules;
      } else {
        _filteredSections = nutritionModules.where((section) {
          return section['title'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
              section['content'].toString().toLowerCase().contains(
                    query.toLowerCase(),
                  );
        }).toList();
      }
    });
  }

  void _toggleBookmark(String sectionId) {
    setState(() {
      if (_bookmarkedSections.contains(sectionId)) {
        _bookmarkedSections.remove(sectionId);
      } else {
        _bookmarkedSections.add(sectionId);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _bookmarkedSections.contains(sectionId)
              ? 'Sezione aggiunta ai preferiti'
              : 'Sezione rimossa dai preferiti',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.oceanGradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              // Custom Ocean Header
              _buildOceanHeader(),
              // Body content
              Expanded(
                child: _currentView == 'quiz'
                    ? _buildQuizView()
                    : _currentView == 'quiz_selection'
                        ? _buildQuizSelectionView()
                        : _buildEducationView(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildOceanBottomNav(),
    );
  }

  Widget _buildOceanHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(2.w, 2.h, 4.w, 2.h),
      child: Row(
        children: [
          IconButton(
            onPressed: _currentView == 'quiz'
                ? _navigateBackToQuizSelection
                : _currentView == 'quiz_selection'
                    ? _navigateToEducation
                    : () => Navigator.pop(context),
            icon: const CustomIconWidget(
              iconName: 'arrow_back_ios',
              color: Colors.white,
              size: 22,
            ),
          ),
          Expanded(
            child: Text(
              _currentView == 'quiz'
                  ? 'Quiz Educativi'
                  : _currentView == 'quiz_selection'
                      ? 'Seleziona Quiz'
                      : 'Approfondimenti',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (_currentView == 'education')
            IconButton(
              onPressed: _showBookmarkedSections,
              icon: const CustomIconWidget(
                iconName: 'bookmark',
                color: Colors.white,
                size: 24,
              ),
            )
          else
            SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildQuizView() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: QuizTabWidget(
          onDataChanged: () {},
          initialCategory: _selectedQuizCategory,
          hideCategorySelector: true,
        ),
      ),
    );
  }

  Widget _buildEducationView() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 2.h),
            child: SearchBarWidget(
              controller: _searchController,
              onSearchChanged: _onSearchChanged,
              hintText: 'Cerca argomenti, parole chiave...',
            ),
          ),

          // Quiz Navigation Button
          Container(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
            child: GestureDetector(
              onTap: _navigateToQuiz,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.seaMid.withAlpha(51),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowSea.withAlpha(20),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon container
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.seaTop, AppTheme.seaMid],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.quiz_outlined,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4.w),

                    // Text content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quiz Educativi',
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Quiz interattivi per migliorare le tue conoscenze nutrizionali',
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              color: AppTheme.textMuted,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow icon
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppTheme.seaMid,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content (Education sections)
          Expanded(
            child: _filteredSections.isEmpty
                ? _buildEmptySearchState()
                : ListView.builder(
                    padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 12.h),
                    itemCount: _filteredSections.length,
                    itemBuilder: (context, index) {
                      final section = _filteredSections[index];
                      final isBookmarked =
                          _bookmarkedSections.contains(section['id']);

                      return Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: EducationalSectionWidget(
                          section: section,
                          isBookmarked: isBookmarked,
                          onBookmarkToggle: () =>
                              _toggleBookmark(section['id']),
                        ),
                      );
                    },
                  ),
          ),

          // Disclaimer
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
            decoration: BoxDecoration(
              color: AppTheme.accentSand.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accentSand.withAlpha(100)),
            ),
            child: Row(
              children: [
                const CustomIconWidget(
                  iconName: 'info',
                  color: Color(0xFFE65100),
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Queste informazioni non sostituiscono il parere medico',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFE65100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// navbar - same as dashboard
  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => QuickActionSheetWidget(
        onLogMeal: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.addMeal);
        },
        onAddRecipe: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.recipeManagement);
        },
        onTakePhoto: () {
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            AppRoutes.addMeal,
            arguments: {'autoOpenCamera': true},
          );
        },
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedNavIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.mealDiary);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.addMeal);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.reports);
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.profileSettings);
        break;
    }
  }

  Widget _buildOceanBottomNav() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: AppTheme.bottomNavDecoration,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavIcon('home', 0),
              _buildNavIcon('calendar_today', 1),
              SizedBox(width: 15.w), // Space for FAB
              _buildNavIcon('trending_up', 3),
              _buildNavIcon('person', 4),
            ],
          ),
          // Centered FAB
          Positioned(
            top: -35,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _showQuickActions,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: AppTheme.fabGradientDecoration,
                  child: const Center(
                    child: CustomIconWidget(
                      iconName: 'add',
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(String iconName, int index) {
    final isActive = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: CustomIconWidget(
        iconName: iconName,
        color: isActive ? AppTheme.seaMid : const Color(0xFFB0BEC5),
        size: 26,
      ),
    );
  }

  Widget _buildQuizSelectionView() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introduction text
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.seaTop.withAlpha(30),
                    AppTheme.seaMid.withAlpha(20),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.seaMid.withAlpha(51)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.seaTop, AppTheme.seaMid],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.quiz_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Scegli l\'Argomento del Quiz',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.seaDeep,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Seleziona l\'argomento specifico che vuoi approfondire per migliorare le tue conoscenze nutrizionali.',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      color: AppTheme.textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Quiz Selection Cards
            Column(
              children: [
                GestureDetector(
                  onTap: () => _navigateToSpecificQuiz('false_myths'),
                  child: _buildTopicQuizCard(
                    'Falsi Miti',
                    'Quiz sui falsi miti della nutrizione oncologica - vero o falso?',
                    '10 Domande',
                    Icons.fact_check,
                    AppTheme.seaMid,
                  ),
                ),

                SizedBox(height: 2.h),

                GestureDetector(
                  onTap: () => _navigateToSpecificQuiz(
                    'alimenti_nutrienti_supplementi',
                  ),
                  child: _buildTopicQuizCard(
                    'Alimenti e Nutrienti',
                    'Quiz su alimenti, nutrienti e supplementi nutrizionali orali, nutraceutici',
                    '10 Domande',
                    Icons.restaurant,
                    AppTheme.seaTop,
                  ),
                ),

                SizedBox(height: 2.h),

                GestureDetector(
                  onTap: () => _navigateToSpecificQuiz(
                    'nutrizione_terapie_oncologiche',
                  ),
                  child: _buildTopicQuizCard(
                    'Nutrizione e Terapie',
                    'Quiz sulla nutrizione durante le terapie oncologiche',
                    '10 Domande',
                    Icons.local_hospital,
                    AppTheme.seaDeep,
                  ),
                ),

                SizedBox(height: 2.h),

                GestureDetector(
                  onTap: () => _navigateToSpecificQuiz('cosa_fare_prima_terapia'),
                  child: _buildTopicQuizCard(
                    'Prima e Durante la Terapia',
                    'Quiz su che cosa fare prima e in corso di terapia',
                    '10 Domande',
                    Icons.timeline,
                    const Color(0xFF00838F),
                  ),
                ),

                SizedBox(height: 2.h),

                GestureDetector(
                  onTap: () => _navigateToSpecificQuiz('mangiare_sano_salute'),
                  child: _buildTopicQuizCard(
                    'Alimentazione Sana',
                    'Quiz su mangiare sano per mantenersi in salute',
                    '5 Domande',
                    Icons.favorite,
                    AppTheme.accentWave,
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Help text
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.accentSand.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: const Color(0xFFE65100),
                    size: 22,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Consiglio: Inizia con "Falsi Miti" per sfatare le credenze errate, poi approfondisci con gli altri argomenti',
                      style: GoogleFonts.inter(
                        fontSize: 15.sp, // Fixed typo from .12sp
                        color: const Color(0xFFE65100),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicQuizCard(
    String title,
    String description,
    String questionCount,
    IconData iconData,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(40)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowSea.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon section
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, size: 24, color: color),
          ),

          SizedBox(width: 4.w),

          // Content section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    color: AppTheme.textMuted,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    questionCount,
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Arrow icon
          Icon(Icons.arrow_forward_ios, size: 16, color: color),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.seaMid.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const CustomIconWidget(
              iconName: 'search_off',
              color: AppTheme.seaMid,
              size: 48,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Nessun risultato trovato',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Prova a cercare con parole diverse',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _showBookmarkedSections() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 1.h),
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.seaMid.withAlpha(50),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.seaTop, AppTheme.seaMid],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const CustomIconWidget(
                        iconName: 'bookmark',
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Sezioni salvate',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _bookmarkedSections.isEmpty
                    ? _buildEmptyBookmarksState()
                    : ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        itemCount: _bookmarkedSections.length,
                        itemBuilder: (context, index) {
                          final sectionId = _bookmarkedSections[index];
                          final section = nutritionModules.firstWhere(
                            (s) => s['id'] == sectionId,
                          );

                          return Container(
                            margin: EdgeInsets.only(bottom: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.seaMid.withAlpha(30),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.shadowSea.withAlpha(10),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.seaMid.withAlpha(20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: CustomIconWidget(
                                  iconName: section['icon'],
                                  color: AppTheme.seaMid,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                section['title'],
                                style: GoogleFonts.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  _toggleBookmark(sectionId);
                                  Navigator.pop(context);
                                },
                                icon: const CustomIconWidget(
                                  iconName: 'bookmark_remove',
                                  color: AppTheme.errorLight,
                                  size: 20,
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyBookmarksState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.seaMid.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const CustomIconWidget(
              iconName: 'bookmark_border',
              color: AppTheme.seaMid,
              size: 48,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Nessuna sezione salvata',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Tocca l\'icona del segnalibro per salvare le sezioni',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15.sp, // Increased from 13.sp for better readability
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
