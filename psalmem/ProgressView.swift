import SwiftUI
import SwiftData
import Charts

struct ProgressOverviewView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allProgress: [Progress]
    @Query private var allPsalms: [Psalm]
    @Query private var users: [User]
    
    @State private var selectedTimeRange: TimeRange = .week
    @State private var showingDetailedProgress = false
    
    private var user: User? {
        users.first
    }
    
    private var recentProgress: [Progress] {
        let calendar = Calendar.current
        let now = Date()
        
        return allProgress.filter { progress in
            switch selectedTimeRange {
            case .week:
                return calendar.isDate(progress.lastPracticed, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(progress.lastPracticed, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate(progress.lastPracticed, equalTo: now, toGranularity: .year)
            case .all:
                return true
            }
        }.sorted { $0.lastPracticed > $1.lastPracticed }
    }
    
    private var totalQuizAttempts: Int {
        allProgress.reduce(0) { $0 + $1.totalQuizAttempts }
    }
    
    private var totalTimeSpent: Int {
        allProgress.reduce(0) { $0 + $1.timeSpentMinutes }
    }
    
    private var averageAccuracy: Double {
        let totalCorrect = allProgress.reduce(0) { $0 + $1.correctAnswers }
        let totalAnswers = allProgress.reduce(0) { $0 + $1.totalAnswers }
        guard totalAnswers > 0 else { return 0.0 }
        return Double(totalCorrect) / Double(totalAnswers) * 100.0
    }
    
    private var currentStreak: Int {
        allProgress.max { $0.streakDays < $1.streakDays }?.streakDays ?? 0
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with user info
                    headerView
                    
                    // Quick stats
                    quickStatsView
                    
                    // Progress chart
                    progressChartView
                    
                    // Memorization levels
                    memorizationLevelsView
                    
                    // Recent activity
                    recentActivityView
                    
                    // Detailed progress button
                    Button("View Detailed Progress") {
                        showingDetailedProgress = true
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Progress Overview")
            .sheet(isPresented: $showingDetailedProgress) {
                DetailedProgressView()
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Welcome back, \(user?.name ?? "User")!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Keep up the great work memorizing the Psalms")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var quickStatsView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            ProgressStatCard(
                title: "Quiz Attempts",
                value: "\(totalQuizAttempts)",
                icon: "questionmark.circle.fill",
                color: .blue
            )
            
            ProgressStatCard(
                title: "Time Spent",
                value: "\(totalTimeSpent) min",
                icon: "clock.fill",
                color: .green
            )
            
            ProgressStatCard(
                title: "Accuracy",
                value: "\(Int(averageAccuracy))%",
                icon: "target",
                color: .orange
            )
            
            ProgressStatCard(
                title: "Current Streak",
                value: "\(currentStreak) days",
                icon: "flame.fill",
                color: .red
            )
        }
    }
    
    private var progressChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress Over Time")
                .font(.headline)
                .padding(.horizontal)
            
            if !recentProgress.isEmpty {
                Chart(recentProgress) { progress in
                    LineMark(
                        x: .value("Date", progress.lastPracticed),
                        y: .value("Progress", progress.overallProgress * 100)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    AreaMark(
                        x: .value("Date", progress.lastPracticed),
                        y: .value("Progress", progress.overallProgress * 100)
                    )
                    .foregroundStyle(.blue.opacity(0.2))
                }
                .frame(height: 200)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            } else {
                Text("No progress data available")
                    .foregroundColor(.secondary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
        }
    }
    
    private var memorizationLevelsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Memorization Levels")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(MemorizationLevel.allCases, id: \.self) { level in
                    let count = allProgress.filter { $0.memorizationLevel == level }.count
                    
                    HStack {
                        Image(systemName: level.icon)
                            .foregroundColor(Color(level.color))
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(level.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("\(count) psalms")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var recentActivityView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
                .padding(.horizontal)
            
            if recentProgress.isEmpty {
                Text("No recent activity")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            } else {
                ForEach(recentProgress.prefix(5), id: \.id) { progress in
                    RecentActivityRow(progress: progress)
                }
            }
        }
    }
}

struct ProgressStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct RecentActivityRow: View {
    let progress: Progress
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Psalm \(progress.psalm?.number ?? 0)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(Int(progress.overallProgress * 100))% complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: progress.memorizationLevel.icon)
                    .foregroundColor(Color(progress.memorizationLevel.color))
                
                Text(progress.lastPracticed, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct DetailedProgressView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var allProgress: [Progress]
    @Query private var allPsalms: [Psalm]
    
    @State private var selectedPsalm: Psalm?
    @State private var sortOption: SortOption = .progress
    
    enum SortOption: String, CaseIterable {
        case progress = "Progress"
        case recent = "Recent"
        case accuracy = "Accuracy"
        case level = "Level"
    }
    
    private var sortedProgress: [Progress] {
        let progress = allProgress.sorted { progress1, progress2 in
            switch sortOption {
            case .progress:
                return progress1.overallProgress > progress2.overallProgress
            case .recent:
                return progress1.lastPracticed > progress2.lastPracticed
            case .accuracy:
                return progress1.accuracyPercentage > progress2.accuracyPercentage
            case .level:
                return progress1.memorizationLevel.rawValue < progress2.memorizationLevel.rawValue
            }
        }
        return progress
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Sort options
                Picker("Sort by", selection: $sortOption) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Progress list
                List(sortedProgress, id: \.id) { progress in
                    ProgressDetailRow(progress: progress)
                        .onTapGesture {
                            selectedPsalm = progress.psalm
                        }
                }
            }
            .navigationTitle("Detailed Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedPsalm) { psalm in
                if let progress = allProgress.first(where: { $0.psalm?.id == psalm.id }) {
                    PsalmProgressDetailView(progress: progress)
                }
            }
        }
    }
}

struct ProgressDetailRow: View {
    let progress: Progress
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Psalm \(progress.psalm?.number ?? 0)")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Image(systemName: progress.memorizationLevel.icon)
                        .foregroundColor(Color(progress.memorizationLevel.color))
                        .font(.title2)
                }
                
                // Progress bar
                ProgressView(value: progress.overallProgress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .tint(Color(progress.memorizationLevel.color))
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(Int(progress.overallProgress * 100))% Complete")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("\(progress.totalQuizAttempts) attempts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Int(progress.accuracyPercentage))% Accuracy")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("\(progress.timeSpentMinutes) min")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if progress.streakDays > 0 {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.red)
                        Text("\(progress.streakDays) day streak")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct PsalmProgressDetailView: View {
    let progress: Progress
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    statsSection
                    memorizedVersesSection
                    recentScoresSection
                }
                .padding()
            }
            .navigationTitle("Progress Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Psalm \(progress.psalm?.number ?? 0)")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(progress.memorizationLevel.rawValue)
                .font(.title2)
                .foregroundColor(Color(progress.memorizationLevel.color))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(progress.memorizationLevel.color).opacity(0.2))
                .cornerRadius(20)
        }
    }
    
    private var statsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            DetailStatCard(title: "Overall Progress", value: "\(Int(progress.overallProgress * 100))%", color: .blue)
            DetailStatCard(title: "Quiz Attempts", value: "\(progress.totalQuizAttempts)", color: .green)
            DetailStatCard(title: "Accuracy", value: "\(Int(progress.accuracyPercentage))%", color: .orange)
            DetailStatCard(title: "Time Spent", value: "\(progress.timeSpentMinutes) min", color: .purple)
            DetailStatCard(title: "Best Score", value: "\(Int(progress.bestScore))%", color: .red)
            DetailStatCard(title: "Average Score", value: "\(Int(progress.averageScore))%", color: .teal)
        }
    }
    
    @ViewBuilder
    private var memorizedVersesSection: some View {
        if !progress.memorizedVerses.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Memorized Verses")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                    ForEach(progress.memorizedVerses.sorted(), id: \.self) { verseNumber in
                        Text("\(verseNumber)")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.green)
                            .cornerRadius(20)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    private var recentScoresSection: some View {
        if !progress.quizScores.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Quiz Scores")
                    .font(.headline)
                
                ForEach(progress.quizScores.suffix(5).reversed(), id: \.id) { score in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(Int(score.score))%")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                            Text(score.quizType)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(score.date, style: .date)
                                .font(.caption)
                            
                            Text("\(score.timeSpent) min")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct DetailStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

enum TimeRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    case all = "All Time"
}

#Preview {
    ProgressOverviewView()
        .modelContainer(for: [Progress.self, Psalm.self, User.self, QuizScore.self])
}
