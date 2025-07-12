import SwiftUI
import SwiftData
import Charts

struct ProgressReportView: View {
    let psalm: Psalm
    let user: User
    let translation: Translation
    let memorizedVerses: Set<Int>
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allProgress: [Progress]
    @Query private var allVerses: [Verse]
    
    private var verses: [Verse] {
        allVerses.filter { $0.psalm?.id == psalm.id && $0.translation?.id == translation.id }.sorted { $0.number < $1.number }
    }
    
    private var progress: Double {
        guard !verses.isEmpty else { return 0 }
        return Double(memorizedVerses.count) / Double(verses.count)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Overall progress
                    overallProgressSection
                    
                    // Verse-by-verse progress
                    verseProgressSection
                    
                    // Recommendations
                    recommendationsSection
                    
                    // Statistics
                    statisticsSection
                }
                .padding()
            }
            .navigationTitle("Progress Report")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
#else
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
#endif
            }
        }
    }
    
    private var overallProgressSection: some View {
        VStack(spacing: 15) {
            Text("Psalm \(psalm.number) Progress")
                .font(.title)
                .fontWeight(.bold)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 15)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: progress)
                
                VStack {
                    Text("\(Int(progress * 100))%")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("\(memorizedVerses.count) of \(verses.count) verses memorized")
                .font(.headline)
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    
    private var verseProgressSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Verse-by-Verse Progress")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                ForEach(verses, id: \.id) { verse in
                    VStack(spacing: 5) {
                        Text("\(verse.number)")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Image(systemName: memorizedVerses.contains(verse.number) ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundColor(memorizedVerses.contains(verse.number) ? .green : .gray)
                    }
                    .padding()
                    .background(memorizedVerses.contains(verse.number) ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recommendations")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                if progress < 0.25 {
                    recommendationCard(
                        icon: "target",
                        title: "Start with Short Verses",
                        description: "Focus on memorizing shorter verses first to build confidence and momentum.",
                        color: .blue
                    )
                }
                
                if progress >= 0.25 && progress < 0.75 {
                    recommendationCard(
                        icon: "repeat",
                        title: "Practice Regularly",
                        description: "Review memorized verses daily to strengthen retention and prevent forgetting.",
                        color: .orange
                    )
                }
                
                if progress >= 0.75 {
                    recommendationCard(
                        icon: "star",
                        title: "Almost There!",
                        description: "You're close to completing this psalm. Focus on the remaining verses with extra practice.",
                        color: .green
                    )
                }
                
                // Memory strength based recommendations
                if user.memoryStrengths.contains(.visual) {
                    recommendationCard(
                        icon: "eye",
                        title: "Visual Learning",
                        description: "Try creating mental images for each verse to enhance visual memory.",
                        color: .purple
                    )
                }
                
                if user.memoryStrengths.contains(.auditory) {
                    recommendationCard(
                        icon: "speaker.wave.2",
                        title: "Auditory Learning",
                        description: "Read verses aloud or listen to audio recordings to strengthen auditory memory.",
                        color: .red
                    )
                }
                
                if user.memoryStrengths.contains(.kinesthetic) {
                    recommendationCard(
                        icon: "hand.raised",
                        title: "Kinesthetic Learning",
                        description: "Use hand gestures or write verses down to engage physical memory.",
                        color: .brown
                    )
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func recommendationCard(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(color)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Statistics")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                StatCard(
                    title: "Current Streak",
                    value: "\(calculateStreak()) days",
                    icon: "flame",
                    color: .orange
                )
                
                StatCard(
                    title: "Total Practice Time",
                    value: "\(calculateTotalTime()) min",
                    icon: "clock",
                    color: .blue
                )
                
                StatCard(
                    title: "Accuracy Rate",
                    value: "\(calculateAccuracy())%",
                    icon: "target",
                    color: .green
                )
                
                StatCard(
                    title: "Psalms Completed",
                    value: "\(calculateCompletedPsalms())",
                    icon: "book",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func calculateStreak() -> Int {
        // This would be calculated based on daily practice records
        // For now, return a sample value
        return Int.random(in: 1...7)
    }
    
    private func calculateTotalTime() -> Int {
        // This would be calculated based on practice session records
        // For now, return a sample value
        return Int.random(in: 30...120)
    }
    
    private func calculateAccuracy() -> Int {
        // This would be calculated based on puzzle completion records
        // For now, return a sample value
        return Int.random(in: 70...95)
    }
    
    private func calculateCompletedPsalms() -> Int {
        let completedPsalms = allProgress.filter { $0.overallProgress >= 1.0 }
        return completedPsalms.count
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Charts (iOS 16+)
struct ProgressChart: View {
    let data: [(String, Double)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Progress Over Time")
                .font(.headline)
            
            if #available(iOS 16.0, *) {
                Chart(data, id: \.0) { item in
                    LineMark(
                        x: .value("Date", item.0),
                        y: .value("Progress", item.1)
                    )
                    .foregroundStyle(.blue)
                    
                    AreaMark(
                        x: .value("Date", item.0),
                        y: .value("Progress", item.1)
                    )
                    .foregroundStyle(.blue.opacity(0.1))
                }
                .frame(height: 200)
                .chartYScale(domain: 0...1)
            } else {
                // Fallback for older iOS versions
                Text("Progress tracking requires iOS 16 or later")
                    .foregroundColor(.secondary)
                    .frame(height: 200)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
} 