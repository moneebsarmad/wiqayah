import Foundation

/// Represents a dhikr that must be recited to unlock an app
struct DhikrRequirement: Identifiable, Codable {
    let id: String
    let name: String
    let arabic: String
    let transliteration: String
    var repetitions: Int
    let verificationThreshold: Double
    let category: DhikrCategory

    // MARK: - Categories
    enum DhikrCategory: String, Codable, CaseIterable {
        case simple = "simple"
        case ayat = "ayat"
        case surah = "surah"
        case adhkarSet = "adhkar_set"
    }

    // MARK: - Initialization
    init(
        id: String = UUID().uuidString,
        name: String,
        arabic: String,
        transliteration: String,
        repetitions: Int = 1,
        verificationThreshold: Double = 0.7,
        category: DhikrCategory = .simple
    ) {
        self.id = id
        self.name = name
        self.arabic = arabic
        self.transliteration = transliteration
        self.repetitions = repetitions
        self.verificationThreshold = verificationThreshold
        self.category = category
    }

    // MARK: - Computed Properties

    /// Display text showing required repetitions
    var displayText: String {
        if repetitions > 1 {
            return "\(name) (\(repetitions)×)"
        }
        return name
    }

    // MARK: - With Multiplier

    /// Returns a copy with adjusted repetitions (for debt system)
    func withMultiplier(_ multiplier: Int) -> DhikrRequirement {
        var copy = self
        copy.repetitions = repetitions * multiplier
        return copy
    }

    // MARK: - Static Dhikr Library
    static let subhanallah = DhikrRequirement(
        id: "subhanallah",
        name: "Subhanallah",
        arabic: "سُبْحَانَ ٱللَّٰهِ",
        transliteration: "Subhanallah",
        repetitions: 3,
        verificationThreshold: 0.7,
        category: .simple
    )

    static let alhamdulillah = DhikrRequirement(
        id: "alhamdulillah",
        name: "Alhamdulillah",
        arabic: "ٱلْحَمْدُ لِلَّٰهِ",
        transliteration: "Alhamdulillah",
        repetitions: 3,
        verificationThreshold: 0.7,
        category: .simple
    )

    static let allahuAkbar = DhikrRequirement(
        id: "allahu_akbar",
        name: "Allahu Akbar",
        arabic: "ٱللَّٰهُ أَكْبَرُ",
        transliteration: "Allahu Akbar",
        repetitions: 3,
        verificationThreshold: 0.7,
        category: .simple
    )

    static let ayatAlKursi = DhikrRequirement(
        id: "ayat_al_kursi",
        name: "Ayat al-Kursi",
        arabic: """
        ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلْحَىُّ ٱلْقَيُّومُ ۚ لَا تَأْخُذُهُۥ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُۥ مَا فِى ٱلسَّمَٰوَٰتِ وَمَا فِى ٱلْأَرْضِ ۗ مَن ذَا ٱلَّذِى يَشْفَعُ عِندَهُۥٓ إِلَّا بِإِذْنِهِۦ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَىْءٍ مِّنْ عِلْمِهِۦٓ إِلَّا بِمَا شَآءَ ۚ وَسِعَ كُرْسِيُّهُ ٱلسَّمَٰوَٰتِ وَٱلْأَرْضَ ۖ وَلَا يَـُٔودُهُۥ حِفْظُهُمَا ۚ وَهُوَ ٱلْعَلِىُّ ٱلْعَظِيمُ
        """,
        transliteration: "Allahu la ilaha illa huwal hayyul qayyum. La ta'khuzuhu sinatun wa la nawm. Lahu ma fis samawati wa ma fil ard. Man zal lazi yashfa'u 'indahu illa bi iznih. Ya'lamu ma bayna aydihim wa ma khalfahum. Wa la yuhituna bi shay'im min 'ilmihi illa bima sha'. Wasi'a kursiyyuhus samawati wal ard. Wa la ya'uduhu hifzuhuma wa huwal 'aliyyul 'azim.",
        repetitions: 1,
        verificationThreshold: 0.75,
        category: .ayat
    )

    static let surahKahfFirst5 = DhikrRequirement(
        id: "kahf_first_5",
        name: "Surah al-Kahf (First 5 Ayat)",
        arabic: """
        ٱلْحَمْدُ لِلَّهِ ٱلَّذِىٓ أَنزَلَ عَلَىٰ عَبْدِهِ ٱلْكِتَـٰبَ وَلَمْ يَجْعَل لَّهُۥ عِوَجَا ۜ ﴿١﴾ قَيِّمًا لِّيُنذِرَ بَأْسًا شَدِيدًا مِّن لَّدُنْهُ وَيُبَشِّرَ ٱلْمُؤْمِنِينَ ٱلَّذِينَ يَعْمَلُونَ ٱلصَّـٰلِحَـٰتِ أَنَّ لَهُمْ أَجْرًا حَسَنًا ﴿٢﴾ مَّـٰكِثِينَ فِيهِ أَبَدًا ﴿٣﴾ وَيُنذِرَ ٱلَّذِينَ قَالُوا۟ ٱتَّخَذَ ٱللَّهُ وَلَدًا ﴿٤﴾ مَّا لَهُم بِهِۦ مِنْ عِلْمٍ وَلَا لِـَٔابَآئِهِمْ ۚ كَبُرَتْ كَلِمَةً تَخْرُجُ مِنْ أَفْوَٰهِهِمْ ۚ إِن يَقُولُونَ إِلَّا كَذِبًا ﴿٥﴾
        """,
        transliteration: "Alhamdu lillahil lazi anzala 'ala 'abdihi al-kitaba wa lam yaj'al lahu 'iwaja. Qayyiman liyunzira ba'san shadidan min ladunhu wa yubashshiral mu'mininal lazina ya'maluna as-salihati anna lahum ajran hasana. Makisina fihi abada. Wa yunziral lazina qalut takhaza Allahu walada. Ma lahum bihi min 'ilmin wa la li aba'ihim. Kaburat kalimatan takhruju min afwahihim. In yaquluna illa kaziba.",
        repetitions: 1,
        verificationThreshold: 0.7,
        category: .surah
    )

    static let morningAdhkar = DhikrRequirement(
        id: "morning_adhkar",
        name: "Morning Adhkar Set",
        arabic: """
        أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لاَ إِلَـهَ إِلاَّ اللهُ وَحْدَهُ لاَ شَرِيْكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيْرٌ
        """,
        transliteration: "Asbahna wa asbahal mulku lillah, walhamdu lillah, la ilaha illallahu wahdahu la sharika lah, lahul mulku wa lahul hamdu wa huwa 'ala kulli shay'in qadir.",
        repetitions: 1,
        verificationThreshold: 0.7,
        category: .adhkarSet
    )
}
