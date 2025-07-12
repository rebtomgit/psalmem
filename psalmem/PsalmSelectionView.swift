import SwiftUI
import SwiftData

struct PsalmSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var psalms: [Psalm]
    @State private var selectedPsalm: Psalm?
    @State private var selectedTranslation: String?
    @State private var showMemorization = false
    
    var body: some View {
        VStack {
            PsalmSelectionHeaderView()
            if psalms.isEmpty {
                Text("No psalms available. Please add psalms to the database.")
                    .foregroundColor(.red)
                    .padding()
            } else {
                PsalmSelectionListView(psalms: Array(psalms.prefix(20)), selectedPsalm: selectedPsalm, onSelect: { selectedPsalm = $0 })
                if let selectedPsalm = selectedPsalm {
                    PsalmTranslationSectionView(selectedTranslation: $selectedTranslation)
                }
                if let selectedPsalm = selectedPsalm, let selectedTranslation = selectedTranslation {
                    Button("Start Memorization") {
                        showMemorization = true
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
        }
#if os(iOS)
        .navigationBarTitleDisplayMode(.large)
#endif
        .sheet(isPresented: $showMemorization) {
            if let selectedPsalm = selectedPsalm, let selectedTranslation = selectedTranslation {
                // Replace with your actual MemorizationView
                Text("Memorization for Psalm \(selectedPsalm.number) - \(selectedTranslation)")
            }
        }
    }
}

struct PsalmSelectionHeaderView: View {
    var body: some View {
        Text("Select a Psalm to Memorize")
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding(.top)
    }
}

struct PsalmSelectionListView: View {
    let psalms: [Psalm]
    let selectedPsalm: Psalm?
    let onSelect: (Psalm) -> Void
    var body: some View {
        List(psalms, id: \.id) { psalm in
            PsalmRowView(psalm: psalm, isSelected: selectedPsalm?.id == psalm.id) {
                onSelect(psalm)
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct PsalmTranslationSectionView: View {
    @Binding var selectedTranslation: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose Translation")
                .font(.headline)
            TranslationButtonRowView(selectedTranslation: $selectedTranslation)
        }
        .padding(.vertical)
    }
}

struct PsalmRowView: View {
    let psalm: Psalm
    let isSelected: Bool
    let onSelect: () -> Void
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading) {
                Text("Psalm \(psalm.number)")
                    .font(.headline)
                Text(psalm.title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
    }
}

struct TranslationButtonRowView: View {
    @Binding var selectedTranslation: String?
    var body: some View {
        HStack(spacing: 10) {
            Button("King James") {
                selectedTranslation = "King James"
            }
            .padding()
            .background(selectedTranslation == "King James" ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
            .cornerRadius(8)
            Button("English Standard") {
                selectedTranslation = "English Standard"
            }
            .padding()
            .background(selectedTranslation == "English Standard" ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
            .cornerRadius(8)
        }
    }
} 