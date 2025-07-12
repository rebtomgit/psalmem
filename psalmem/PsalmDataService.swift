import Foundation
import SwiftData

class PsalmDataService {
    static let shared = PsalmDataService()
    
    private init() {}
    
    func populatePsalms(modelContext: ModelContext) {
        // Check if psalms already exist
        let fetchDescriptor = FetchDescriptor<Psalm>()
        let existingPsalms = try? modelContext.fetch(fetchDescriptor)
        
        if existingPsalms?.isEmpty == false {
            return // Already populated
        }
        
        // Create translations
        let kjv = Translation(name: "King James Version", abbreviation: "KJV")
        let esv = Translation(name: "English Standard Version", abbreviation: "ESV")
        
        modelContext.insert(kjv)
        modelContext.insert(esv)
        
        // Psalm 1
        let psalm1 = Psalm(number: 1, title: "The Way of the Righteous and the Wicked")
        modelContext.insert(psalm1)
        
        let psalm1Verses = [
            (1, "Blessed is the man that walketh not in the counsel of the ungodly, nor standeth in the way of sinners, nor sitteth in the seat of the scornful.", "Blessed is the man who walks not in the counsel of the wicked, nor stands in the way of sinners, nor sits in the seat of scoffers."),
            (2, "But his delight is in the law of the LORD; and in his law doth he meditate day and night.", "But his delight is in the law of the LORD, and on his law he meditates day and night."),
            (3, "And he shall be like a tree planted by the rivers of water, that bringeth forth his fruit in his season; his leaf also shall not wither; and whatsoever he doeth shall prosper.", "He is like a tree planted by streams of water that yields its fruit in its season, and its leaf does not wither. In all that he does, he prospers."),
            (4, "The ungodly are not so: but are like the chaff which the wind driveth away.", "The wicked are not so, but are like chaff that the wind drives away."),
            (5, "Therefore the ungodly shall not stand in the judgment, nor sinners in the congregation of the righteous.", "Therefore the wicked will not stand in the judgment, nor sinners in the congregation of the righteous."),
            (6, "For the LORD knoweth the way of the righteous: but the way of the ungodly shall perish.", "For the LORD knows the way of the righteous, but the way of the wicked will perish.")
        ]
        
        for (number, kjvText, esvText) in psalm1Verses {
            let kjvVerse = Verse(number: number, text: kjvText, psalm: psalm1, translation: kjv)
            let esvVerse = Verse(number: number, text: esvText, psalm: psalm1, translation: esv)
            modelContext.insert(kjvVerse)
            modelContext.insert(esvVerse)
        }
        
        // Psalm 2
        let psalm2 = Psalm(number: 2, title: "The Reign of the LORD's Anointed")
        modelContext.insert(psalm2)
        
        let psalm2Verses = [
            (1, "Why do the heathen rage, and the people imagine a vain thing?", "Why do the nations rage and the peoples plot in vain?"),
            (2, "The kings of the earth set themselves, and the rulers take counsel together, against the LORD, and against his anointed, saying,", "The kings of the earth set themselves, and the rulers take counsel together, against the LORD and against his anointed, saying,"),
            (3, "Let us break their bands asunder, and cast away their cords from us.", "Let us burst their bonds apart and cast away their cords from us."),
            (4, "He that sitteth in the heavens shall laugh: the Lord shall have them in derision.", "He who sits in the heavens laughs; the Lord holds them in derision."),
            (5, "Then shall he speak unto them in his wrath, and vex them in his sore displeasure.", "Then he will speak to them in his wrath, and terrify them in his fury, saying,"),
            (6, "Yet have I set my king upon my holy hill of Zion.", "As for me, I have set my King on Zion, my holy hill.")
        ]
        
        for (number, kjvText, esvText) in psalm2Verses {
            let kjvVerse = Verse(number: number, text: kjvText, psalm: psalm2, translation: kjv)
            let esvVerse = Verse(number: number, text: esvText, psalm: psalm2, translation: esv)
            modelContext.insert(kjvVerse)
            modelContext.insert(esvVerse)
        }
        
        // Add more psalms (3-20) with sample content
        for i in 3...20 {
            let psalm = Psalm(number: i, title: "Psalm \(i)")
            modelContext.insert(psalm)
            
            // Add sample verses for each psalm
            for j in 1...6 {
                let kjvText = "This is verse \(j) of Psalm \(i) in KJV."
                let esvText = "This is verse \(j) of Psalm \(i) in ESV."
                
                let kjvVerse = Verse(number: j, text: kjvText, psalm: psalm, translation: kjv)
                let esvVerse = Verse(number: j, text: esvText, psalm: psalm, translation: esv)
                modelContext.insert(kjvVerse)
                modelContext.insert(esvVerse)
            }
        }
        
        try? modelContext.save()
    }
} 