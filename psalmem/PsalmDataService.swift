import Foundation
import SwiftData

class PsalmDataService {
    static let shared = PsalmDataService()
    
    private init() {}
    
    func populatePsalms(modelContext: ModelContext) {
        DiagnosticLogger.shared.logDataLoadStarted()
        
        // Check if psalms already exist
        let fetchDescriptor = FetchDescriptor<Psalm>()
        let existingPsalms = try? modelContext.fetch(fetchDescriptor)
        
        if existingPsalms?.isEmpty == false {
            DiagnosticLogger.shared.logInfo("Data already exists, skipping population")
            return // Already populated
        }
        
        // Create translations
        let kjv = Translation(name: "King James Version", abbreviation: "KJV")
        let esv = Translation(name: "English Standard Version", abbreviation: "ESV")
        
        modelContext.insert(kjv)
        modelContext.insert(esv)
        
        // --- PSALM 1 ---
        let psalm1 = Psalm(number: 1, title: "The Way of the Righteous and the Wicked")
        modelContext.insert(psalm1)
        let psalm1KJV = [
            "Blessed is the man that walketh not in the counsel of the ungodly, nor standeth in the way of sinners, nor sitteth in the seat of the scornful.",
            "But his delight is in the law of the LORD; and in his law doth he meditate day and night.",
            "And he shall be like a tree planted by the rivers of water, that bringeth forth his fruit in his season; his leaf also shall not wither; and whatsoever he doeth shall prosper.",
            "The ungodly are not so: but are like the chaff which the wind driveth away.",
            "Therefore the ungodly shall not stand in the judgment, nor sinners in the congregation of the righteous.",
            "For the LORD knoweth the way of the righteous: but the way of the ungodly shall perish."
        ]
        let psalm1ESV = [
            "Blessed is the man who walks not in the counsel of the wicked, nor stands in the way of sinners, nor sits in the seat of scoffers;",
            "but his delight is in the law of the LORD, and on his law he meditates day and night.",
            "He is like a tree planted by streams of water that yields its fruit in its season, and its leaf does not wither. In all that he does, he prospers.",
            "The wicked are not so, but are like chaff that the wind drives away.",
            "Therefore the wicked will not stand in the judgment, nor sinners in the congregation of the righteous;",
            "for the LORD knows the way of the righteous, but the way of the wicked will perish."
        ]
        for i in 0..<psalm1KJV.count {
            let kjvVerse = Verse(number: i+1, text: psalm1KJV[i], psalm: psalm1, translation: kjv)
            let esvVerse = Verse(number: i+1, text: psalm1ESV[i], psalm: psalm1, translation: esv)
            modelContext.insert(kjvVerse)
            modelContext.insert(esvVerse)
        }
        
        // --- PSALM 2 ---
        let psalm2 = Psalm(number: 2, title: "The Reign of the LORD's Anointed")
        modelContext.insert(psalm2)
        let psalm2KJV = [
            "Why do the heathen rage, and the people imagine a vain thing?",
            "The kings of the earth set themselves, and the rulers take counsel together, against the LORD, and against his anointed, saying,",
            "Let us break their bands asunder, and cast away their cords from us.",
            "He that sitteth in the heavens shall laugh: the Lord shall have them in derision.",
            "Then shall he speak unto them in his wrath, and vex them in his sore displeasure.",
            "Yet have I set my king upon my holy hill of Zion.",
            "I will declare the decree: the LORD hath said unto me, Thou art my Son; this day have I begotten thee.",
            "Ask of me, and I shall give thee the heathen for thine inheritance, and the uttermost parts of the earth for thy possession.",
            "Thou shalt break them with a rod of iron; thou shalt dash them in pieces like a potter's vessel.",
            "Be wise now therefore, O ye kings: be instructed, ye judges of the earth.",
            "Serve the LORD with fear, and rejoice with trembling.",
            "Kiss the Son, lest he be angry, and ye perish from the way, when his wrath is kindled but a little. Blessed are all they that put their trust in him."
        ]
        let psalm2ESV = [
            "Why do the nations rage and the peoples plot in vain?",
            "The kings of the earth set themselves, and the rulers take counsel together, against the LORD and against his Anointed, saying,",
            "Let us burst their bonds apart and cast away their cords from us.",
            "He who sits in the heavens laughs; the Lord holds them in derision.",
            "Then he will speak to them in his wrath, and terrify them in his fury, saying,",
            "As for me, I have set my King on Zion, my holy hill.",
            "I will tell of the decree: The LORD said to me, 'You are my Son; today I have begotten you.'",
            "Ask of me, and I will make the nations your heritage, and the ends of the earth your possession.",
            "You shall break them with a rod of iron and dash them in pieces like a potter's vessel.",
            "Now therefore, O kings, be wise; be warned, O rulers of the earth.",
            "Serve the LORD with fear, and rejoice with trembling.",
            "Kiss the Son, lest he be angry, and you perish in the way, for his wrath is quickly kindled. Blessed are all who take refuge in him."
        ]
        for i in 0..<psalm2KJV.count {
            let kjvVerse = Verse(number: i+1, text: psalm2KJV[i], psalm: psalm2, translation: kjv)
            let esvVerse = Verse(number: i+1, text: psalm2ESV[i], psalm: psalm2, translation: esv)
            modelContext.insert(kjvVerse)
            modelContext.insert(esvVerse)
        }
        
        // Psalm 3 (KJV)
        let psalm3KJV = Psalm(number: 3, title: "Psalm 3")
        modelContext.insert(psalm3KJV)
        let psalm3KJVV = [
            "1": "Lord, how are they increased that trouble me! many are they that rise up against me.",
            "2": "Many there be which say of my soul, There is no help for him in God. Selah.",
            "3": "But thou, O Lord, art a shield for me; my glory, and the lifter up of mine head.",
            "4": "I cried unto the Lord with my voice, and he heard me out of his holy hill. Selah.",
            "5": "I laid me down and slept; I awaked; for the Lord sustained me.",
            "6": "I will not be afraid of ten thousands of people, that have set themselves against me round about.",
            "7": "Arise, O Lord; save me, O my God: for thou hast smitten all mine enemies upon the cheek bone; thou hast broken the teeth of the ungodly.",
            "8": "Salvation belongeth unto the Lord: thy blessing is upon thy people. Selah."
        ]
        for (num, text) in psalm3KJVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm3KJV
            verse.translation = kjv
            modelContext.insert(verse)
        }
        // Psalm 3 (ESV)
        let psalm3ESV = Psalm(number: 3, title: "Psalm 3")
        modelContext.insert(psalm3ESV)
        let psalm3ESVV = [
            "1": "O Lord, how many are my foes! Many are rising against me;",
            "2": "many are saying of my soul, 'There is no salvation for him in God.' Selah",
            "3": "But you, O Lord, are a shield about me, my glory, and the lifter of my head.",
            "4": "I cried aloud to the Lord, and he answered me from his holy hill. Selah",
            "5": "I lay down and slept; I woke again, for the Lord sustained me.",
            "6": "I will not be afraid of many thousands of people who have set themselves against me all around.",
            "7": "Arise, O Lord! Save me, O my God! For you strike all my enemies on the cheek; you break the teeth of the wicked.",
            "8": "Salvation belongs to the Lord; your blessing be on your people! Selah"
        ]
        for (num, text) in psalm3ESVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm3ESV
            verse.translation = esv
            modelContext.insert(verse)
        }
        // Psalm 4 (KJV)
        let psalm4KJV = Psalm(number: 4, title: "Psalm 4")
        modelContext.insert(psalm4KJV)
        let psalm4KJVV = [
            "1": "Hear me when I call, O God of my righteousness: thou hast enlarged me when I was in distress; have mercy upon me, and hear my prayer.",
            "2": "O ye sons of men, how long will ye turn my glory into shame? how long will ye love vanity, and seek after leasing? Selah.",
            "3": "But know that the Lord hath set apart him that is godly for himself: the Lord will hear when I call unto him.",
            "4": "Stand in awe, and sin not: commune with your own heart upon your bed, and be still. Selah.",
            "5": "Offer the sacrifices of righteousness, and put your trust in the Lord.",
            "6": "There be many that say, Who will shew us any good? Lord, lift thou up the light of thy countenance upon us.",
            "7": "Thou hast put gladness in my heart, more than in the time that their corn and their wine increased.",
            "8": "I will both lay me down in peace, and sleep: for thou, Lord, only makest me dwell in safety."
        ]
        for (num, text) in psalm4KJVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm4KJV
            verse.translation = kjv
            modelContext.insert(verse)
        }
        // Psalm 4 (ESV)
        let psalm4ESV = Psalm(number: 4, title: "Psalm 4")
        modelContext.insert(psalm4ESV)
        let psalm4ESVV = [
            "1": "Answer me when I call, O God of my righteousness! You have given me relief when I was in distress. Be gracious to me and hear my prayer!",
            "2": "O men, how long shall my honor be turned into shame? How long will you love vain words and seek after lies? Selah",
            "3": "But know that the Lord has set apart the godly for himself; the Lord hears when I call to him.",
            "4": "Be angry, and do not sin; ponder in your own hearts on your beds, and be silent. Selah",
            "5": "Offer right sacrifices, and put your trust in the Lord.",
            "6": "There are many who say, 'Who will show us some good? Lift up the light of your face upon us, O Lord!'",
            "7": "You have put more joy in my heart than they have when their grain and wine abound.",
            "8": "In peace I will both lie down and sleep; for you alone, O Lord, make me dwell in safety."
        ]
        for (num, text) in psalm4ESVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm4ESV
            verse.translation = esv
            modelContext.insert(verse)
        }
        // Psalm 5 (KJV)
        let psalm5KJV = Psalm(number: 5, title: "Psalm 5")
        modelContext.insert(psalm5KJV)
        let psalm5KJVV = [
            "1": "Give ear to my words, O Lord, consider my meditation.",
            "2": "Hearken unto the voice of my cry, my King, and my God: for unto thee will I pray.",
            "3": "My voice shalt thou hear in the morning, O Lord; in the morning will I direct my prayer unto thee, and will look up.",
            "4": "For thou art not a God that hath pleasure in wickedness: neither shall evil dwell with thee.",
            "5": "The foolish shall not stand in thy sight: thou hatest all workers of iniquity.",
            "6": "Thou shalt destroy them that speak leasing: the Lord will abhor the bloody and deceitful man.",
            "7": "But as for me, I will come into thy house in the multitude of thy mercy: and in thy fear will I worship toward thy holy temple.",
            "8": "Lead me, O Lord, in thy righteousness because of mine enemies; make thy way straight before my face.",
            "9": "For there is no faithfulness in their mouth; their inward part is very wickedness; their throat is an open sepulchre; they flatter with their tongue.",
            "10": "Destroy thou them, O God; let them fall by their own counsels; cast them out in the multitude of their transgressions; for they have rebelled against thee.",
            "11": "But let all those that put their trust in thee rejoice: let them ever shout for joy, because thou defendest them: let them also that love thy name be joyful in thee.",
            "12": "For thou, Lord, wilt bless the righteous; with favour wilt thou compass him as with a shield."
        ]
        for (num, text) in psalm5KJVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm5KJV
            verse.translation = kjv
            modelContext.insert(verse)
        }
        // Psalm 5 (ESV)
        let psalm5ESV = Psalm(number: 5, title: "Psalm 5")
        modelContext.insert(psalm5ESV)
        let psalm5ESVV = [
            "1": "Give ear to my words, O Lord; consider my groaning.",
            "2": "Give attention to the sound of my cry, my King and my God, for to you do I pray.",
            "3": "O Lord, in the morning you hear my voice; in the morning I prepare a sacrifice for you and watch.",
            "4": "For you are not a God who delights in wickedness; evil may not dwell with you.",
            "5": "The boastful shall not stand before your eyes; you hate all evildoers.",
            "6": "You destroy those who speak lies; the Lord abhors the bloodthirsty and deceitful man.",
            "7": "But I, through the abundance of your steadfast love, will enter your house. I will bow down toward your holy temple in the fear of you.",
            "8": "Lead me, O Lord, in your righteousness because of my enemies; make your way straight before me.",
            "9": "For there is no truth in their mouth; their inmost self is destruction; their throat is an open grave; they flatter with their tongue.",
            "10": "Make them bear their guilt, O God; let them fall by their own counsels; because of the abundance of their transgressions cast them out, for they have rebelled against you.",
            "11": "But let all who take refuge in you rejoice; let them ever sing for joy, and spread your protection over them, that those who love your name may exult in you.",
            "12": "For you bless the righteous, O Lord; you cover him with favor as with a shield."
        ]
        for (num, text) in psalm5ESVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm5ESV
            verse.translation = esv
            modelContext.insert(verse)
        }
        
        // --- PSALMS 3-20 ---
        // TODO: Add the full text for Psalms 3-20 in both KJV and ESV below, following the same pattern as above.
        // For brevity, only Psalms 1 and 2 are shown here. The rest should be filled in with their actual verses.
        
        // Psalm 6 (KJV)
        let psalm6KJV = Psalm(number: 6, title: "Psalm 6")
        modelContext.insert(psalm6KJV)
        let psalm6KJVV = [
            "1": "O Lord, rebuke me not in thine anger, neither chasten me in thy hot displeasure.",
            "2": "Have mercy upon me, O Lord; for I am weak: O Lord, heal me; for my bones are vexed.",
            "3": "My soul is also sore vexed: but thou, O Lord, how long?",
            "4": "Return, O Lord, deliver my soul: oh save me for thy mercies' sake.",
            "5": "For in death there is no remembrance of thee: in the grave who shall give thee thanks?",
            "6": "I am weary with my groaning; all the night make I my bed to swim; I water my couch with my tears.",
            "7": "Mine eye is consumed because of grief; it waxeth old because of all mine enemies.",
            "8": "Depart from me, all ye workers of iniquity; for the Lord hath heard the voice of my weeping.",
            "9": "The Lord hath heard my supplication; the Lord will receive my prayer.",
            "10": "Let all mine enemies be ashamed and sore vexed: let them return and be ashamed suddenly."
        ]
        for (num, text) in psalm6KJVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm6KJV
            verse.translation = kjv
            modelContext.insert(verse)
        }
        // Psalm 6 (ESV)
        let psalm6ESV = Psalm(number: 6, title: "Psalm 6")
        modelContext.insert(psalm6ESV)
        let psalm6ESVV = [
            "1": "O Lord, rebuke me not in your anger, nor discipline me in your wrath.",
            "2": "Be gracious to me, O Lord, for I am languishing; heal me, O Lord, for my bones are troubled.",
            "3": "My soul also is greatly troubled. But you, O Lord—how long?",
            "4": "Turn, O Lord, deliver my life; save me for the sake of your steadfast love.",
            "5": "For in death there is no remembrance of you; in Sheol who will give you praise?",
            "6": "I am weary with my moaning; every night I flood my bed with tears; I drench my couch with my weeping.",
            "7": "My eye wastes away because of grief; it grows weak because of all my foes.",
            "8": "Depart from me, all you workers of evil, for the Lord has heard the sound of my weeping.",
            "9": "The Lord has heard my plea; the Lord accepts my prayer.",
            "10": "All my enemies shall be ashamed and greatly troubled; they shall turn back and be put to shame in a moment."
        ]
        for (num, text) in psalm6ESVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm6ESV
            verse.translation = esv
            modelContext.insert(verse)
        }
        // Psalm 7 (KJV)
        let psalm7KJV = Psalm(number: 7, title: "Psalm 7")
        modelContext.insert(psalm7KJV)
        let psalm7KJVV = [
            "1": "O Lord my God, in thee do I put my trust: save me from all them that persecute me, and deliver me:",
            "2": "Lest he tear my soul like a lion, rending it in pieces, while there is none to deliver.",
            "3": "O Lord my God, if I have done this; if there be iniquity in my hands;",
            "4": "If I have rewarded evil unto him that was at peace with me; (yea, I have delivered him that without cause is mine enemy:)",
            "5": "Let the enemy persecute my soul, and take it; yea, let him tread down my life upon the earth, and lay mine honour in the dust. Selah.",
            "6": "Arise, O Lord, in thine anger, lift up thyself because of the rage of mine enemies: and awake for me to the judgment that thou hast commanded.",
            "7": "So shall the congregation of the people compass thee about: for their sakes therefore return thou on high.",
            "8": "The Lord shall judge the people: judge me, O Lord, according to my righteousness, and according to mine integrity that is in me.",
            "9": "Oh let the wickedness of the wicked come to an end; but establish the just: for the righteous God trieth the hearts and reins.",
            "10": "My defence is of God, which saveth the upright in heart.",
            "11": "God judgeth the righteous, and God is angry with the wicked every day.",
            "12": "If he turn not, he will whet his sword; he hath bent his bow, and made it ready.",
            "13": "He hath also prepared for him the instruments of death; he ordaineth his arrows against the persecutors.",
            "14": "Behold, he travaileth with iniquity, and hath conceived mischief, and brought forth falsehood.",
            "15": "He made a pit, and digged it, and is fallen into the ditch which he made.",
            "16": "His mischief shall return upon his own head, and his violent dealing shall come down upon his own pate.",
            "17": "I will praise the Lord according to his righteousness: and will sing praise to the name of the Lord most high."
        ]
        for (num, text) in psalm7KJVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm7KJV
            verse.translation = kjv
            modelContext.insert(verse)
        }
        // Psalm 7 (ESV)
        let psalm7ESV = Psalm(number: 7, title: "Psalm 7")
        modelContext.insert(psalm7ESV)
        let psalm7ESVV = [
            "1": "O Lord my God, in you do I take refuge; save me from all my pursuers and deliver me,",
            "2": "lest like a lion they tear my soul apart, rending it in pieces, with none to deliver.",
            "3": "O Lord my God, if I have done this, if there is wrong in my hands,",
            "4": "if I have repaid my friend with evil or plundered my enemy without cause,",
            "5": "let the enemy pursue my soul and overtake it, and let him trample my life to the ground and lay my glory in the dust. Selah",
            "6": "Arise, O Lord, in your anger; lift yourself up against the fury of my enemies; awake for me; you have appointed a judgment.",
            "7": "Let the assembly of the peoples be gathered about you; over it return on high.",
            "8": "The Lord judges the peoples; judge me, O Lord, according to my righteousness and according to the integrity that is in me.",
            "9": "Oh, let the evil of the wicked come to an end, and may you establish the righteous— you who test the minds and hearts, O righteous God!",
            "10": "My shield is with God, who saves the upright in heart.",
            "11": "God is a righteous judge, and a God who feels indignation every day.",
            "12": "If a man does not repent, God will whet his sword; he has bent and readied his bow;",
            "13": "he has prepared for him his deadly weapons, making his arrows fiery shafts.",
            "14": "Behold, the wicked man conceives evil and is pregnant with mischief and gives birth to lies.",
            "15": "He makes a pit, digging it out, and falls into the hole that he has made.",
            "16": "His mischief returns upon his own head, and on his own skull his violence descends.",
            "17": "I will give to the Lord the thanks due to his righteousness, and I will sing praise to the name of the Lord, the Most High."
        ]
        for (num, text) in psalm7ESVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm7ESV
            verse.translation = esv
            modelContext.insert(verse)
        }
        // Psalm 8 (KJV)
        let psalm8KJV = Psalm(number: 8, title: "Psalm 8")
        modelContext.insert(psalm8KJV)
        let psalm8KJVV = [
            "1": "O Lord, our Lord, how excellent is thy name in all the earth! who hast set thy glory above the heavens.",
            "2": "Out of the mouth of babes and sucklings hast thou ordained strength because of thine enemies, that thou mightest still the enemy and the avenger.",
            "3": "When I consider thy heavens, the work of thy fingers, the moon and the stars, which thou hast ordained;",
            "4": "What is man, that thou art mindful of him? and the son of man, that thou visitest him?",
            "5": "For thou hast made him a little lower than the angels, and hast crowned him with glory and honour.",
            "6": "Thou madest him to have dominion over the works of thy hands; thou hast put all things under his feet:",
            "7": "All sheep and oxen, yea, and the beasts of the field;",
            "8": "The fowl of the air, and the fish of the sea, and whatsoever passeth through the paths of the seas.",
            "9": "O Lord our Lord, how excellent is thy name in all the earth!"
        ]
        for (num, text) in psalm8KJVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm8KJV
            verse.translation = kjv
            modelContext.insert(verse)
        }
        // Psalm 8 (ESV)
        let psalm8ESV = Psalm(number: 8, title: "Psalm 8")
        modelContext.insert(psalm8ESV)
        let psalm8ESVV = [
            "1": "O Lord, our Lord, how majestic is your name in all the earth! You have set your glory above the heavens.",
            "2": "Out of the mouth of babies and infants, you have established strength because of your foes, to still the enemy and the avenger.",
            "3": "When I look at your heavens, the work of your fingers, the moon and the stars, which you have set in place,",
            "4": "what is man that you are mindful of him, and the son of man that you care for him?",
            "5": "Yet you have made him a little lower than the heavenly beings and crowned him with glory and honor.",
            "6": "You have given him dominion over the works of your hands; you have put all things under his feet,",
            "7": "all sheep and oxen, and also the beasts of the field,",
            "8": "the birds of the heavens, and the fish of the sea, whatever passes along the paths of the seas.",
            "9": "O Lord, our Lord, how majestic is your name in all the earth!"
        ]
        for (num, text) in psalm8ESVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm8ESV
            verse.translation = esv
            modelContext.insert(verse)
        }
        // Psalm 9 (KJV)
        let psalm9KJV = Psalm(number: 9, title: "Psalm 9")
        modelContext.insert(psalm9KJV)
        let psalm9KJVV = [
            "1": "I will praise thee, O Lord, with my whole heart; I will shew forth all thy marvellous works.",
            "2": "I will be glad and rejoice in thee: I will sing praise to thy name, O thou most High.",
            "3": "When mine enemies are turned back, they shall fall and perish at thy presence.",
            "4": "For thou hast maintained my right and my cause; thou satest in the throne judging right.",
            "5": "Thou hast rebuked the heathen, thou hast destroyed the wicked, thou hast put out their name for ever and ever.",
            "6": "O thou enemy, destructions are come to a perpetual end: and thou hast destroyed cities; their memorial is perished with them.",
            "7": "But the Lord shall endure for ever: he hath prepared his throne for judgment.",
            "8": "And he shall judge the world in righteousness, he shall minister judgment to the people in uprightness.",
            "9": "The Lord also will be a refuge for the oppressed, a refuge in times of trouble.",
            "10": "And they that know thy name will put their trust in thee: for thou, Lord, hast not forsaken them that seek thee.",
            "11": "Sing praises to the Lord, which dwelleth in Zion: declare among the people his doings.",
            "12": "When he maketh inquisition for blood, he remembereth them: he forgetteth not the cry of the humble.",
            "13": "Have mercy upon me, O Lord; consider my trouble which I suffer of them that hate me, thou that liftest me up from the gates of death:",
            "14": "That I may shew forth all thy praise in the gates of the daughter of Zion: I will rejoice in thy salvation.",
            "15": "The heathen are sunk down in the pit that they made: in the net which they hid is their own foot taken.",
            "16": "The Lord is known by the judgment which he executeth: the wicked is snared in the work of his own hands. Higgaion. Selah.",
            "17": "The wicked shall be turned into hell, and all the nations that forget God.",
            "18": "For the needy shall not alway be forgotten: the expectation of the poor shall not perish for ever.",
            "19": "Arise, O Lord; let not man prevail: let the heathen be judged in thy sight.",
            "20": "Put them in fear, O Lord: that the nations may know themselves to be but men. Selah."
        ]
        for (num, text) in psalm9KJVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm9KJV
            verse.translation = kjv
            modelContext.insert(verse)
        }
        // Psalm 9 (ESV)
        let psalm9ESV = Psalm(number: 9, title: "Psalm 9")
        modelContext.insert(psalm9ESV)
        let psalm9ESVV = [
            "1": "I will give thanks to the Lord with my whole heart; I will recount all of your wonderful deeds.",
            "2": "I will be glad and exult in you; I will sing praise to your name, O Most High.",
            "3": "When my enemies turn back, they stumble and perish before your presence.",
            "4": "For you have maintained my just cause; you have sat on the throne, giving righteous judgment.",
            "5": "You have rebuked the nations; you have made the wicked perish; you have blotted out their name forever and ever.",
            "6": "The enemy came to an end in everlasting ruins; their cities you rooted out; the very memory of them has perished.",
            "7": "But the Lord sits enthroned forever; he has established his throne for justice,",
            "8": "and he judges the world with righteousness; he judges the peoples with uprightness.",
            "9": "The Lord is a stronghold for the oppressed, a stronghold in times of trouble.",
            "10": "And those who know your name put their trust in you, for you, O Lord, have not forsaken those who seek you.",
            "11": "Sing praises to the Lord, who sits enthroned in Zion! Tell among the peoples his deeds!",
            "12": "For he who avenges blood is mindful of them; he does not forget the cry of the afflicted.",
            "13": "Be gracious to me, O Lord! See my affliction from those who hate me, O you who lift me up from the gates of death,",
            "14": "that I may recount all your praises, that in the gates of the daughter of Zion I may rejoice in your salvation.",
            "15": "The nations have sunk in the pit that they made; in the net that they hid, their own foot has been caught.",
            "16": "The Lord has made himself known; he has executed judgment; the wicked are snared in the work of their own hands. Higgaion. Selah",
            "17": "The wicked shall return to Sheol, all the nations that forget God.",
            "18": "For the needy shall not always be forgotten, and the hope of the poor shall not perish forever.",
            "19": "Arise, O Lord! Let not man prevail; let the nations be judged before you!",
            "20": "Put them in fear, O Lord! Let the nations know that they are but men! Selah"
        ]
        for (num, text) in psalm9ESVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm9ESV
            verse.translation = esv
            modelContext.insert(verse)
        }
        // Psalm 10 (KJV)
        let psalm10KJV = Psalm(number: 10, title: "Psalm 10")
        modelContext.insert(psalm10KJV)
        let psalm10KJVV = [
            "1": "Why standest thou afar off, O Lord? why hidest thou thyself in times of trouble?",
            "2": "The wicked in his pride doth persecute the poor: let them be taken in the devices that they have imagined.",
            "3": "For the wicked boasteth of his heart's desire, and blesseth the covetous, whom the Lord abhorreth.",
            "4": "The wicked, through the pride of his countenance, will not seek after God: God is not in all his thoughts.",
            "5": "His ways are always grievous; thy judgments are far above out of his sight: as for all his enemies, he puffeth at them.",
            "6": "He hath said in his heart, I shall not be moved: for I shall never be in adversity.",
            "7": "His mouth is full of cursing and deceit and fraud: under his tongue is mischief and vanity.",
            "8": "He sitteth in the lurking places of the villages: in the secret places doth he murder the innocent: his eyes are privily set against the poor.",
            "9": "He lieth in wait secretly as a lion in his den: he lieth in wait to catch the poor: he doth catch the poor, when he draweth him into his net.",
            "10": "He croucheth, and humbleth himself, that the poor may fall by his strong ones.",
            "11": "He hath said in his heart, God hath forgotten: he hideth his face; he will never see it.",
            "12": "Arise, O Lord; O God, lift up thine hand: forget not the humble.",
            "13": "Wherefore doth the wicked contemn God? he hath said in his heart, Thou wilt not require it.",
            "14": "Thou hast seen it; for thou beholdest mischief and spite, to requite it with thy hand: the poor committeth himself unto thee; thou art the helper of the fatherless.",
            "15": "Break thou the arm of the wicked and the evil man: seek out his wickedness till thou find none.",
            "16": "The Lord is King for ever and ever: the heathen are perished out of his land.",
            "17": "Lord, thou hast heard the desire of the humble: thou wilt prepare their heart, thou wilt cause thine ear to hear:",
            "18": "To judge the fatherless and the oppressed, that the man of the earth may no more oppress."
        ]
        for (num, text) in psalm10KJVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm10KJV
            verse.translation = kjv
            modelContext.insert(verse)
        }
        // Psalm 10 (ESV)
        let psalm10ESV = Psalm(number: 10, title: "Psalm 10")
        modelContext.insert(psalm10ESV)
        let psalm10ESVV = [
            "1": "Why, O Lord, do you stand far away? Why do you hide yourself in times of trouble?",
            "2": "In arrogance the wicked hotly pursue the poor; let them be caught in the schemes that they have devised.",
            "3": "For the wicked boasts of the desire of his soul, and the one greedy for gain curses and renounces the Lord.",
            "4": "In the pride of his face the wicked does not seek him; all his thoughts are, 'There is no God.'",
            "5": "His ways prosper at all times; your judgments are on high, out of his sight; as for all his foes, he puffs at them.",
            "6": "He says in his heart, 'I shall not be moved; throughout all generations I shall not meet adversity.'",
            "7": "His mouth is filled with cursing and deceit and oppression; under his tongue are mischief and iniquity.",
            "8": "He sits in ambush in the villages; in hiding places he murders the innocent. His eyes stealthily watch for the helpless;",
            "9": "he lurks in ambush like a lion in his den; he lurks that he may seize the poor; he seizes the poor when he draws him into his net.",
            "10": "The helpless are crushed, sink down, and fall by his might.",
            "11": "He says in his heart, 'God has forgotten, he has hidden his face, he will never see it.'",
            "12": "Arise, O Lord; O God, lift up your hand; forget not the afflicted.",
            "13": "Why does the wicked renounce God and say in his heart, 'You will not call to account'?",
            "14": "But you do see, for you note mischief and vexation, that you may take it into your hands; to you the helpless commits himself; you have been the helper of the fatherless.",
            "15": "Break the arm of the wicked and evildoer; call his wickedness to account till you find none.",
            "16": "The Lord is king forever and ever; the nations perish from his land.",
            "17": "O Lord, you hear the desire of the afflicted; you will strengthen their heart; you will incline your ear",
            "18": "to do justice to the fatherless and the oppressed, so that man who is of the earth may strike terror no more."
        ]
        for (num, text) in psalm10ESVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm10ESV
            verse.translation = esv
            modelContext.insert(verse)
        }
        
        // Psalm 11 (KJV)
        let psalm11KJV = Psalm(number: 11, title: "Psalm 11")
        modelContext.insert(psalm11KJV)
        let psalm11KJVV = [
            "1": "In the Lord put I my trust: how say ye to my soul, Flee as a bird to your mountain?",
            "2": "For, lo, the wicked bend their bow, they make ready their arrow upon the string, that they may privily shoot at the upright in heart.",
            "3": "If the foundations be destroyed, what can the righteous do?",
            "4": "The Lord is in his holy temple, the Lord's throne is in heaven: his eyes behold, his eyelids try, the children of men.",
            "5": "The Lord trieth the righteous: but the wicked and him that loveth violence his soul hateth.",
            "6": "Upon the wicked he shall rain snares, fire and brimstone, and an horrible tempest: this shall be the portion of their cup.",
            "7": "For the righteous Lord loveth righteousness; his countenance doth behold the upright."
        ]
        for (num, text) in psalm11KJVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm11KJV
            verse.translation = kjv
            modelContext.insert(verse)
        }
        // Psalm 11 (ESV)
        let psalm11ESV = Psalm(number: 11, title: "Psalm 11")
        modelContext.insert(psalm11ESV)
        let psalm11ESVV = [
            "1": "In the Lord I take refuge; how can you say to my soul, 'Flee like a bird to your mountain,'",
            "2": "for behold, the wicked bend the bow; they have fitted their arrow to the string to shoot in the dark at the upright in heart;",
            "3": "if the foundations are destroyed, what can the righteous do?'",
            "4": "The Lord is in his holy temple; the Lord's throne is in heaven; his eyes see, his eyelids test the children of man.",
            "5": "The Lord tests the righteous, but his soul hates the wicked and the one who loves violence.",
            "6": "Let him rain coals on the wicked; fire and sulfur and a scorching wind shall be the portion of their cup.",
            "7": "For the Lord is righteous; he loves righteous deeds; the upright shall behold his face."
        ]
        for (num, text) in psalm11ESVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm11ESV
            verse.translation = esv
            modelContext.insert(verse)
        }
        // Psalm 12 (KJV)
        let psalm12KJV = Psalm(number: 12, title: "Psalm 12")
        modelContext.insert(psalm12KJV)
        let psalm12KJVV = [
            "1": "Help, Lord; for the godly man ceaseth; for the faithful fail from among the children of men.",
            "2": "They speak vanity every one with his neighbour: with flattering lips and with a double heart do they speak.",
            "3": "The Lord shall cut off all flattering lips, and the tongue that speaketh proud things:",
            "4": "Who have said, With our tongue will we prevail; our lips are our own: who is lord over us?",
            "5": "For the oppression of the poor, for the sighing of the needy, now will I arise, saith the Lord; I will set him in safety from him that puffeth at him.",
            "6": "The words of the Lord are pure words: as silver tried in a furnace of earth, purified seven times.",
            "7": "Thou shalt keep them, O Lord, thou shalt preserve them from this generation for ever.",
            "8": "The wicked walk on every side, when the vilest men are exalted."
        ]
        for (num, text) in psalm12KJVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm12KJV
            verse.translation = kjv
            modelContext.insert(verse)
        }
        // Psalm 12 (ESV)
        let psalm12ESV = Psalm(number: 12, title: "Psalm 12")
        modelContext.insert(psalm12ESV)
        let psalm12ESVV = [
            "1": "Save, O Lord, for the godly one is gone; for the faithful have vanished from among the children of man.",
            "2": "Everyone utters lies to his neighbor; with flattering lips and a double heart they speak.",
            "3": "May the Lord cut off all flattering lips, the tongue that makes great boasts,",
            "4": "those who say, 'With our tongue we will prevail, our lips are with us; who is master over us?'",
            "5": "'Because the poor are plundered, because the needy groan, I will now arise,' says the Lord; 'I will place him in the safety for which he longs.'",
            "6": "The words of the Lord are pure words, like silver refined in a furnace on the ground, purified seven times.",
            "7": "You, O Lord, will keep them; you will guard us from this generation forever.",
            "8": "On every side the wicked prowl, as vileness is exalted among the children of man."
        ]
        for (num, text) in psalm12ESVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm12ESV
            verse.translation = esv
            modelContext.insert(verse)
        }
        // Psalm 13 (KJV)
        let psalm13KJV = Psalm(number: 13, title: "Psalm 13")
        modelContext.insert(psalm13KJV)
        let psalm13KJVV = [
            "1": "How long wilt thou forget me, O Lord? for ever? how long wilt thou hide thy face from me?",
            "2": "How long shall I take counsel in my soul, having sorrow in my heart daily? how long shall mine enemy be exalted over me?",
            "3": "Consider and hear me, O Lord my God: lighten mine eyes, lest I sleep the sleep of death;",
            "4": "Lest mine enemy say, I have prevailed against him; and those that trouble me rejoice when I am moved.",
            "5": "But I have trusted in thy mercy; my heart shall rejoice in thy salvation.",
            "6": "I will sing unto the Lord, because he hath dealt bountifully with me."
        ]
        for (num, text) in psalm13KJVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm13KJV
            verse.translation = kjv
            modelContext.insert(verse)
        }
        // Psalm 13 (ESV)
        let psalm13ESV = Psalm(number: 13, title: "Psalm 13")
        modelContext.insert(psalm13ESV)
        let psalm13ESVV = [
            "1": "How long, O Lord? Will you forget me forever? How long will you hide your face from me?",
            "2": "How long must I take counsel in my soul and have sorrow in my heart all the day? How long shall my enemy be exalted over me?",
            "3": "Consider and answer me, O Lord my God; light up my eyes, lest I sleep the sleep of death,",
            "4": "lest my enemy say, 'I have prevailed over him,' lest my foes rejoice because I am shaken.",
            "5": "But I have trusted in your steadfast love; my heart shall rejoice in your salvation.",
            "6": "I will sing to the Lord, because he has dealt bountifully with me."
        ]
        for (num, text) in psalm13ESVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm13ESV
            verse.translation = esv
            modelContext.insert(verse)
        }
        // Psalm 14 (KJV)
        let psalm14KJV = Psalm(number: 14, title: "Psalm 14")
        modelContext.insert(psalm14KJV)
        let psalm14KJVV = [
            "1": "The fool hath said in his heart, There is no God. They are corrupt, they have done abominable works, there is none that doeth good.",
            "2": "The Lord looked down from heaven upon the children of men, to see if there were any that did understand, and seek God.",
            "3": "They are all gone aside, they are all together become filthy: there is none that doeth good, no, not one.",
            "4": "Have all the workers of iniquity no knowledge? who eat up my people as they eat bread, and call not upon the Lord.",
            "5": "There were they in great fear: for God is in the generation of the righteous.",
            "6": "Ye have shamed the counsel of the poor, because the Lord is his refuge.",
            "7": "Oh that the salvation of Israel were come out of Zion! when the Lord bringeth back the captivity of his people, Jacob shall rejoice, and Israel shall be glad."
        ]
        for (num, text) in psalm14KJVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm14KJV
            verse.translation = kjv
            modelContext.insert(verse)
        }
        // Psalm 14 (ESV)
        let psalm14ESV = Psalm(number: 14, title: "Psalm 14")
        modelContext.insert(psalm14ESV)
        let psalm14ESVV = [
            "1": "The fool says in his heart, 'There is no God.' They are corrupt, they do abominable deeds; there is none who does good.",
            "2": "The Lord looks down from heaven on the children of man, to see if there are any who understand, who seek after God.",
            "3": "They have all turned aside; together they have become corrupt; there is none who does good, not even one.",
            "4": "Have they no knowledge, all the evildoers who eat up my people as they eat bread and do not call upon the Lord?",
            "5": "There they are in great terror, for God is with the generation of the righteous.",
            "6": "You would shame the plans of the poor, but the Lord is his refuge.",
            "7": "Oh, that salvation for Israel would come out of Zion! When the Lord restores the fortunes of his people, let Jacob rejoice, let Israel be glad."
        ]
        for (num, text) in psalm14ESVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm14ESV
            verse.translation = esv
            modelContext.insert(verse)
        }
        // Psalm 15 (KJV)
        let psalm15KJV = Psalm(number: 15, title: "Psalm 15")
        modelContext.insert(psalm15KJV)
        let psalm15KJVV = [
            "1": "Lord, who shall abide in thy tabernacle? who shall dwell in thy holy hill?",
            "2": "He that walketh uprightly, and worketh righteousness, and speaketh the truth in his heart.",
            "3": "He that backbiteth not with his tongue, nor doeth evil to his neighbour, nor taketh up a reproach against his neighbour.",
            "4": "In whose eyes a vile person is contemned; but he honoureth them that fear the Lord. He that sweareth to his own hurt, and changeth not.",
            "5": "He that putteth not out his money to usury, nor taketh reward against the innocent. He that doeth these things shall never be moved."
        ]
        for (num, text) in psalm15KJVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm15KJV
            verse.translation = kjv
            modelContext.insert(verse)
        }
        // Psalm 15 (ESV)
        let psalm15ESV = Psalm(number: 15, title: "Psalm 15")
        modelContext.insert(psalm15ESV)
        let psalm15ESVV = [
            "1": "O Lord, who shall sojourn in your tent? Who shall dwell on your holy hill?",
            "2": "He who walks blamelessly and does what is right and speaks truth in his heart;",
            "3": "who does not slander with his tongue and does no evil to his neighbor, nor takes up a reproach against his friend;",
            "4": "in whose eyes a vile person is despised, but who honors those who fear the Lord; who swears to his own hurt and does not change;",
            "5": "who does not put out his money at interest and does not take a bribe against the innocent. He who does these things shall never be moved."
        ]
        for (num, text) in psalm15ESVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm15ESV
            verse.translation = esv
            modelContext.insert(verse)
        }
        
        // Psalm 16 (KJV)
        let psalm16KJV = Psalm(number: 16, title: "Psalm 16")
        modelContext.insert(psalm16KJV)
        let psalm16KJVV = [
            "1": "Preserve me, O God: for in thee do I put my trust.",
            "2": "O my soul, thou hast said unto the Lord, Thou art my Lord: my goodness extendeth not to thee;",
            "3": "But to the saints that are in the earth, and to the excellent, in whom is all my delight.",
            "4": "Their sorrows shall be multiplied that hasten after another god: their drink offerings of blood will I not offer, nor take up their names into my lips.",
            "5": "The Lord is the portion of mine inheritance and of my cup: thou maintainest my lot.",
            "6": "The lines are fallen unto me in pleasant places; yea, I have a goodly heritage.",
            "7": "I will bless the Lord, who hath given me counsel: my reins also instruct me in the night seasons.",
            "8": "I have set the Lord always before me: because he is at my right hand, I shall not be moved.",
            "9": "Therefore my heart is glad, and my glory rejoiceth: my flesh also shall rest in hope.",
            "10": "For thou wilt not leave my soul in hell; neither wilt thou suffer thine Holy One to see corruption.",
            "11": "Thou wilt shew me the path of life: in thy presence is fulness of joy; at thy right hand there are pleasures for evermore."
        ]
        for (num, text) in psalm16KJVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm16KJV
            verse.translation = kjv
            modelContext.insert(verse)
        }
        // Psalm 16 (ESV)
        let psalm16ESV = Psalm(number: 16, title: "Psalm 16")
        modelContext.insert(psalm16ESV)
        let psalm16ESVV = [
            "1": "Preserve me, O God, for in you I take refuge.",
            "2": "I say to the Lord, 'You are my Lord; I have no good apart from you.'",
            "3": "As for the saints in the land, they are the excellent ones, in whom is all my delight.",
            "4": "The sorrows of those who run after another god shall multiply; their drink offerings of blood I will not pour out or take their names on my lips.",
            "5": "The Lord is my chosen portion and my cup; you hold my lot.",
            "6": "The lines have fallen for me in pleasant places; indeed, I have a beautiful inheritance.",
            "7": "I bless the Lord who gives me counsel; in the night also my heart instructs me.",
            "8": "I have set the Lord always before me; because he is at my right hand, I shall not be shaken.",
            "9": "Therefore my heart is glad, and my whole being rejoices; my flesh also dwells secure.",
            "10": "For you will not abandon my soul to Sheol, or let your holy one see corruption.",
            "11": "You make known to me the path of life; in your presence there is fullness of joy; at your right hand are pleasures forevermore."
        ]
        for (num, text) in psalm16ESVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm16ESV
            verse.translation = esv
            modelContext.insert(verse)
        }
        // Psalm 17 (KJV)
        let psalm17KJV = Psalm(number: 17, title: "Psalm 17")
        modelContext.insert(psalm17KJV)
        let psalm17KJVV = [
            "1": "Hear the right, O Lord, attend unto my cry, give ear unto my prayer, that goeth not out of feigned lips.",
            "2": "Let my sentence come forth from thy presence; let thine eyes behold the things that are equal.",
            "3": "Thou hast proved mine heart; thou hast visited me in the night; thou hast tried me, and shalt find nothing; I am purposed that my mouth shall not transgress.",
            "4": "Concerning the works of men, by the word of thy lips I have kept me from the paths of the destroyer.",
            "5": "Hold up my goings in thy paths, that my footsteps slip not.",
            "6": "I have called upon thee, for thou wilt hear me, O God: incline thine ear unto me, and hear my speech.",
            "7": "Shew thy marvellous lovingkindness, O thou that savest by thy right hand them which put their trust in thee from those that rise up against them.",
            "8": "Keep me as the apple of the eye, hide me under the shadow of thy wings,",
            "9": "From the wicked that oppress me, from my deadly enemies, who compass me about.",
            "10": "They are inclosed in their own fat: with their mouth they speak proudly.",
            "11": "They have now compassed us in our steps: they have set their eyes bowing down to the earth;",
            "12": "Like as a lion that is greedy of his prey, and as it were a young lion lurking in secret places.",
            "13": "Arise, O Lord, disappoint him, cast him down: deliver my soul from the wicked, which is thy sword:",
            "14": "From men which are thy hand, O Lord, from men of the world, which have their portion in this life, and whose belly thou fillest with thy hid treasure: they are full of children, and leave the rest of their substance to their babes.",
            "15": "As for me, I will behold thy face in righteousness: I shall be satisfied, when I awake, with thy likeness."
        ]
        for (num, text) in psalm17KJVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm17KJV
            verse.translation = kjv
            modelContext.insert(verse)
        }
        // Psalm 17 (ESV)
        let psalm17ESV = Psalm(number: 17, title: "Psalm 17")
        modelContext.insert(psalm17ESV)
        let psalm17ESVV = [
            "1": "Hear a just cause, O Lord; attend to my cry! Give ear to my prayer from lips free of deceit!",
            "2": "From your presence let my vindication come! Let your eyes behold the right!",
            "3": "You have tried my heart, you have visited me by night, you have tested me, and you will find nothing; I have purposed that my mouth will not transgress.",
            "4": "With regard to the works of man, by the word of your lips I have avoided the ways of the violent.",
            "5": "My steps have held fast to your paths; my feet have not slipped.",
            "6": "I call upon you, for you will answer me, O God; incline your ear to me; hear my words.",
            "7": "Wondrously show your steadfast love, O Savior of those who seek refuge from their adversaries at your right hand.",
            "8": "Keep me as the apple of your eye; hide me in the shadow of your wings,",
            "9": "from the wicked who do me violence, my deadly enemies who surround me.",
            "10": "They close their hearts to pity; with their mouths they speak arrogantly.",
            "11": "They have now surrounded our steps; they set their eyes to cast us to the ground.",
            "12": "He is like a lion eager to tear, as a young lion lurking in ambush.",
            "13": "Arise, O Lord! Confront him, subdue him! Deliver my soul from the wicked by your sword,",
            "14": "from men by your hand, O Lord, from men of the world whose portion is in this life. You fill their womb with treasure; they are satisfied with children, and they leave their abundance to their infants.",
            "15": "As for me, I shall behold your face in righteousness; when I awake, I shall be satisfied with your likeness."
        ]
        for (num, text) in psalm17ESVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm17ESV
            verse.translation = esv
            modelContext.insert(verse)
        }
        // Psalm 18 (KJV)
        let psalm18KJV = Psalm(number: 18, title: "Psalm 18")
        modelContext.insert(psalm18KJV)
        let psalm18KJVV = [
            "1": "I will love thee, O Lord, my strength.",
            "2": "The Lord is my rock, and my fortress, and my deliverer; my God, my strength, in whom I will trust; my buckler, and the horn of my salvation, and my high tower.",
            "3": "I will call upon the Lord, who is worthy to be praised: so shall I be saved from mine enemies.",
            "4": "The sorrows of death compassed me, and the floods of ungodly men made me afraid.",
            "5": "The sorrows of hell compassed me about: the snares of death prevented me.",
            "6": "In my distress I called upon the Lord, and cried unto my God: he heard my voice out of his temple, and my cry came before him, even into his ears.",
            "7": "Then the earth shook and trembled; the foundations also of the hills moved and were shaken, because he was wroth.",
            "8": "There went up a smoke out of his nostrils, and fire out of his mouth devoured: coals were kindled by it.",
            "9": "He bowed the heavens also, and came down: and darkness was under his feet.",
            "10": "And he rode upon a cherub, and did fly: yea, he did fly upon the wings of the wind.",
            "11": "He made darkness his secret place; his pavilion round about him were dark waters and thick clouds of the skies.",
            "12": "At the brightness that was before him his thick clouds passed, hail stones and coals of fire.",
            "13": "The Lord also thundered in the heavens, and the Highest gave his voice; hail stones and coals of fire.",
            "14": "Yea, he sent out his arrows, and scattered them; and he shot out lightnings, and discomfited them.",
            "15": "Then the channels of waters were seen, and the foundations of the world were discovered at thy rebuke, O Lord, at the blast of the breath of thy nostrils.",
            "16": "He sent from above, he took me, he drew me out of many waters.",
            "17": "He delivered me from my strong enemy, and from them which hated me: for they were too strong for me.",
            "18": "They prevented me in the day of my calamity: but the Lord was my stay.",
            "19": "He brought me forth also into a large place; he delivered me, because he delighted in me.",
            "20": "The Lord rewarded me according to my righteousness; according to the cleanness of my hands hath he recompensed me.",
            "21": "For I have kept the ways of the Lord, and have not wickedly departed from my God.",
            "22": "For all his judgments were before me, and I did not put away his statutes from me.",
            "23": "I was also upright before him, and I kept myself from mine iniquity.",
            "24": "Therefore hath the Lord recompensed me according to my righteousness, according to the cleanness of my hands in his eyesight.",
            "25": "With the merciful thou wilt shew thyself merciful; with an upright man thou wilt shew thyself upright;",
            "26": "With the pure thou wilt shew thyself pure; and with the froward thou wilt shew thyself froward.",
            "27": "For thou wilt save the afflicted people; but wilt bring down high looks.",
            "28": "For thou wilt light my candle: the Lord my God will enlighten my darkness.",
            "29": "For by thee I have run through a troop; and by my God have I leaped over a wall.",
            "30": "As for God, his way is perfect: the word of the Lord is tried: he is a buckler to all those that trust in him.",
            "31": "For who is God save the Lord? or who is a rock save our God?",
            "32": "It is God that girdeth me with strength, and maketh my way perfect.",
            "33": "He maketh my feet like hinds' feet, and setteth me upon my high places.",
            "34": "He teacheth my hands to war, so that a bow of steel is broken by mine arms.",
            "35": "Thou hast also given me the shield of thy salvation: and thy right hand hath holden me up, and thy gentleness hath made me great.",
            "36": "Thou hast enlarged my steps under me, that my feet did not slip.",
            "37": "I have pursued mine enemies, and overtaken them: neither did I turn again till they were consumed.",
            "38": "I have wounded them that they were not able to rise: they are fallen under my feet.",
            "39": "For thou hast girded me with strength unto the battle: thou hast subdued under me those that rose up against me.",
            "40": "Thou hast also given me the necks of mine enemies; that I might destroy them that hate me.",
            "41": "They cried, but there was none to save them: even unto the Lord, but he answered them not.",
            "42": "Then did I beat them small as the dust before the wind: I did cast them out as the dirt in the streets.",
            "43": "Thou hast delivered me from the strivings of the people; and thou hast made me the head of the heathen: a people whom I have not known shall serve me.",
            "44": "As soon as they hear of me, they shall obey me: the strangers shall submit themselves unto me.",
            "45": "The strangers shall fade away, and be afraid out of their close places.",
            "46": "The Lord liveth; and blessed be my rock; and let the God of my salvation be exalted.",
            "47": "It is God that avengeth me, and subdueth the people under me.",
            "48": "He delivereth me from mine enemies: yea, thou liftest me up above those that rise up against me: thou hast delivered me from the violent man.",
            "49": "Therefore will I give thanks unto thee, O Lord, among the heathen, and sing praises unto thy name.",
            "50": "Great deliverance giveth he to his king; and sheweth mercy to his anointed, to David, and to his seed for evermore."
        ]
        for (num, text) in psalm18KJVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm18KJV
            verse.translation = kjv
            modelContext.insert(verse)
        }
        // Psalm 18 (ESV)
        let psalm18ESV = Psalm(number: 18, title: "Psalm 18")
        modelContext.insert(psalm18ESV)
        let psalm18ESVV = [
            "1": "I love you, O Lord, my strength.",
            "2": "The Lord is my rock and my fortress and my deliverer, my God, my rock, in whom I take refuge, my shield, and the horn of my salvation, my stronghold.",
            "3": "I call upon the Lord, who is worthy to be praised, and I am saved from my enemies.",
            "4": "The cords of death encompassed me; the torrents of destruction assailed me;",
            "5": "the cords of Sheol entangled me; the snares of death confronted me.",
            "6": "In my distress I called upon the Lord; to my God I cried for help. From his temple he heard my voice, and my cry to him reached his ears.",
            "7": "Then the earth reeled and rocked; the foundations also of the mountains trembled and quaked, because he was angry.",
            "8": "Smoke went up from his nostrils, and devouring fire from his mouth; glowing coals flamed forth from him.",
            "9": "He bowed the heavens and came down; thick darkness was under his feet.",
            "10": "He rode on a cherub and flew; he came swiftly on the wings of the wind.",
            "11": "He made darkness his covering, his canopy around him, thick clouds dark with water.",
            "12": "Out of the brightness before him hailstones and coals of fire broke through his clouds.",
            "13": "The Lord also thundered in the heavens, and the Most High uttered his voice, hailstones and coals of fire.",
            "14": "And he sent out his arrows and scattered them; he flashed forth lightnings and routed them.",
            "15": "Then the channels of the sea were seen, and the foundations of the world were laid bare at your rebuke, O Lord, at the blast of the breath of your nostrils.",
            "16": "He sent from on high, he took me; he drew me out of many waters.",
            "17": "He rescued me from my strong enemy and from those who hated me, for they were too mighty for me.",
            "18": "They confronted me in the day of my calamity, but the Lord was my support.",
            "19": "He brought me out into a broad place; he rescued me, because he delighted in me.",
            "20": "The Lord dealt with me according to my righteousness; according to the cleanness of my hands he rewarded me.",
            "21": "For I have kept the ways of the Lord, and have not wickedly departed from my God.",
            "22": "For all his rules were before me, and his statutes I did not put away from me.",
            "23": "I was blameless before him, and I kept myself from my guilt.",
            "24": "So the Lord has rewarded me according to my righteousness, according to the cleanness of my hands in his sight.",
            "25": "With the merciful you show yourself merciful; with the blameless man you show yourself blameless;",
            "26": "with the purified you show yourself pure; and with the crooked you make yourself seem tortuous.",
            "27": "For you save a humble people, but the haughty eyes you bring down.",
            "28": "For it is you who light my lamp; the Lord my God lightens my darkness.",
            "29": "For by you I can run against a troop, and by my God I can leap over a wall.",
            "30": "This God—his way is perfect; the word of the Lord proves true; he is a shield for all those who take refuge in him.",
            "31": "For who is God, but the Lord? And who is a rock, except our God?",
            "32": "the God who equipped me with strength and made my way blameless.",
            "33": "He made my feet like the feet of a deer and set me secure on the heights.",
            "34": "He trains my hands for war, so that my arms can bend a bow of bronze.",
            "35": "You have given me the shield of your salvation, and your right hand supported me, and your gentleness made me great.",
            "36": "You gave a wide place for my steps under me, and my feet did not slip.",
            "37": "I pursued my enemies and overtook them, and did not turn back till they were consumed.",
            "38": "I thrust them through, so that they were not able to rise; they fell under my feet.",
            "39": "For you equipped me with strength for the battle; you made those who rise against me sink under me.",
            "40": "You made my enemies turn their backs to me, and those who hated me I destroyed.",
            "41": "They cried for help, but there was none to save; they cried to the Lord, but he did not answer them.",
            "42": "I beat them fine as dust before the wind; I cast them out like the mire of the streets.",
            "43": "You delivered me from strife with the people; you made me the head of the nations; people whom I had not known served me.",
            "44": "As soon as they heard of me they obeyed me; foreigners came cringing to me.",
            "45": "Foreigners lost heart and came trembling out of their fortresses.",
            "46": "The Lord lives, and blessed be my rock, and exalted be the God of my salvation—",
            "47": "the God who gave me vengeance and subdued peoples under me,",
            "48": "who delivered me from my enemies; yes, you exalted me above those who rose against me; you rescued me from the man of violence.",
            "49": "For this I will praise you, O Lord, among the nations, and sing to your name.",
            "50": "Great salvation he brings to his king, and shows steadfast love to his anointed, to David and his offspring forever."
        ]
        for (num, text) in psalm18ESVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm18ESV
            verse.translation = esv
            modelContext.insert(verse)
        }
        // Psalm 19 (KJV)
        let psalm19KJV = Psalm(number: 19, title: "Psalm 19")
        modelContext.insert(psalm19KJV)
        let psalm19KJVV = [
            "1": "The heavens declare the glory of God; and the firmament sheweth his handywork.",
            "2": "Day unto day uttereth speech, and night unto night sheweth knowledge.",
            "3": "There is no speech nor language, where their voice is not heard.",
            "4": "Their line is gone out through all the earth, and their words to the end of the world. In them hath he set a tabernacle for the sun,",
            "5": "Which is as a bridegroom coming out of his chamber, and rejoiceth as a strong man to run a race.",
            "6": "His going forth is from the end of the heaven, and his circuit unto the ends of it: and there is nothing hid from the heat thereof.",
            "7": "The law of the Lord is perfect, converting the soul: the testimony of the Lord is sure, making wise the simple.",
            "8": "The statutes of the Lord are right, rejoicing the heart: the commandment of the Lord is pure, enlightening the eyes.",
            "9": "The fear of the Lord is clean, enduring for ever: the judgments of the Lord are true and righteous altogether.",
            "10": "More to be desired are they than gold, yea, than much fine gold: sweeter also than honey and the honeycomb.",
            "11": "Moreover by them is thy servant warned: and in keeping of them there is great reward.",
            "12": "Who can understand his errors? cleanse thou me from secret faults.",
            "13": "Keep back thy servant also from presumptuous sins; let them not have dominion over me: then shall I be upright, and I shall be innocent from the great transgression.",
            "14": "Let the words of my mouth, and the meditation of my heart, be acceptable in thy sight, O Lord, my strength, and my redeemer."
        ]
        for (num, text) in psalm19KJVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm19KJV
            verse.translation = kjv
            modelContext.insert(verse)
        }
        // Psalm 19 (ESV)
        let psalm19ESV = Psalm(number: 19, title: "Psalm 19")
        modelContext.insert(psalm19ESV)
        let psalm19ESVV = [
            "1": "The heavens declare the glory of God, and the sky above proclaims his handiwork.",
            "2": "Day to day pours out speech, and night to night reveals knowledge.",
            "3": "There is no speech, nor are there words, whose voice is not heard.",
            "4": "Their voice goes out through all the earth, and their words to the end of the world. In them he has set a tent for the sun,",
            "5": "which comes out like a bridegroom leaving his chamber, and, like a strong man, runs its course with joy.",
            "6": "Its rising is from the end of the heavens, and its circuit to the end of them, and there is nothing hidden from its heat.",
            "7": "The law of the Lord is perfect, reviving the soul; the testimony of the Lord is sure, making wise the simple;",
            "8": "the precepts of the Lord are right, rejoicing the heart; the commandment of the Lord is pure, enlightening the eyes;",
            "9": "the fear of the Lord is clean, enduring forever; the rules of the Lord are true, and righteous altogether.",
            "10": "More to be desired are they than gold, even much fine gold; sweeter also than honey and drippings of the honeycomb.",
            "11": "Moreover, by them is your servant warned; in keeping them there is great reward.",
            "12": "Who can discern his errors? Declare me innocent from hidden faults.",
            "13": "Keep back your servant also from presumptuous sins; let them not have dominion over me! Then I shall be blameless, and innocent of great transgression.",
            "14": "Let the words of my mouth and the meditation of my heart be acceptable in your sight, O Lord, my rock and my redeemer."
        ]
        for (num, text) in psalm19ESVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm19ESV
            verse.translation = esv
            modelContext.insert(verse)
        }
        // Psalm 20 (KJV)
        let psalm20KJV = Psalm(number: 20, title: "Psalm 20")
        modelContext.insert(psalm20KJV)
        let psalm20KJVV = [
            "1": "The Lord hear thee in the day of trouble; the name of the God of Jacob defend thee;",
            "2": "Send thee help from the sanctuary, and strengthen thee out of Zion;",
            "3": "Remember all thy offerings, and accept thy burnt sacrifice; Selah.",
            "4": "Grant thee according to thine own heart, and fulfil all thy counsel.",
            "5": "We will rejoice in thy salvation, and in the name of our God we will set up our banners: the Lord fulfil all thy petitions.",
            "6": "Now know I that the Lord saveth his anointed; he will hear him from his holy heaven with the saving strength of his right hand.",
            "7": "Some trust in chariots, and some in horses: but we will remember the name of the Lord our God.",
            "8": "They are brought down and fallen: but we are risen, and stand upright.",
            "9": "Save, Lord: let the king hear us when we call."
        ]
        for (num, text) in psalm20KJVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm20KJV
            verse.translation = kjv
            modelContext.insert(verse)
        }
        // Psalm 20 (ESV)
        let psalm20ESV = Psalm(number: 20, title: "Psalm 20")
        modelContext.insert(psalm20ESV)
        let psalm20ESVV = [
            "1": "May the Lord answer you in the day of trouble! May the name of the God of Jacob protect you!",
            "2": "May he send you help from the sanctuary and give you support from Zion!",
            "3": "May he remember all your offerings and regard with favor your burnt sacrifices! Selah",
            "4": "May he grant you your heart's desire and fulfill all your plans!",
            "5": "May we shout for joy over your salvation, and in the name of our God set up our banners! May the Lord fulfill all your petitions!",
            "6": "Now I know that the Lord saves his anointed; he will answer him from his holy heaven with the saving might of his right hand.",
            "7": "Some trust in chariots and some in horses, but we trust in the name of the Lord our God.",
            "8": "They collapse and fall, but we rise and stand upright.",
            "9": "O Lord, save the king! May he answer us when we call."
        ]
        for (num, text) in psalm20ESVV.sorted(by: { Int($0.key)! < Int($1.key)! }) {
            let verse = Verse(number: Int(num)!, text: text)
            verse.psalm = psalm20ESV
            verse.translation = esv
            modelContext.insert(verse)
        }
        
        do {
            try modelContext.save()
            DiagnosticLogger.shared.logDataLoadCompleted(psalmCount: 20, verseCount: 400, translationCount: 2)
        } catch {
            DiagnosticLogger.shared.logError(error, context: "Data population save")
        }
    }
} 