import SwiftUI
import SwiftData

struct PsalmSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var psalms: [Psalm]
    @State private var selectedPsalm: Psalm?
    
    var body: some View {
        VStack {
            PsalmSelectionHeaderView()
            PsalmSelectionListView(psalms: Array(psalms.prefix(20)), selectedPsalm: selectedPsalm, onSelect: { selectedPsalm = $0 })
            if let selectedPsalm = selectedPsalm {
                PsalmTranslationSectionView(psalm: selectedPsalm)
            }
        }
#if os(iOS)
        .navigationBarTitleDisplayMode(.large)
#endif
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
    let psalm: Psalm
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose Translation")
                .font(.headline)
            TranslationButtonRowView()
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
    var body: some View {
        HStack(spacing: 10) {
            Button("King James") {
                // handle selection
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
            Button("English Standard") {
                // handle selection
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
        }
    }
} 