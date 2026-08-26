import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: CollectionStore
    @State private var tab = 0

    var body: some View {
        TabView(selection: $tab) {
            ScannerView()
                .tabItem { Label("Scan", systemImage: "camera.viewfinder") }
                .tag(0)
            CollectionView()
                .tabItem { Label("Collection", systemImage: "square.stack.3d.up") }
                .tag(1)
            DeckView()
                .tabItem { Label("Decks", systemImage: "rectangle.3.group") }
                .tag(2)
            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(3)
        }
        .tint(Color(red: 0.55, green: 0.35, blue: 1.0))
    }
}

struct CollectionView: View {
    @EnvironmentObject var store: CollectionStore
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment:.leading, spacing:6) {
                        Text("Total Collection Value").foregroundStyle(.secondary)
                        Text(store.totalValue, format: .currency(code: "USD"))
                            .font(.system(size:34, weight:.bold))
                    }
                    .padding(.vertical,8)
                }
                Section("Your Cards") {
                    ForEach(store.cards) { card in
                        HStack {
                            RoundedRectangle(cornerRadius:7).fill(.purple.opacity(0.25))
                                .frame(width:44,height:58)
                                .overlay(Text("🃏").font(.title2))
                            VStack(alignment:.leading) {
                                Text(card.name).font(.headline)
                                Text("\(card.setName) • ×\(card.quantity)")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(card.priceUSD ?? 0, format: .currency(code:"USD"))
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .navigationTitle("CardVault")
        }
    }
}

struct DeckView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment:.leading, spacing:18) {
                Text("Deck Builder").font(.largeTitle.bold())
                Text("Build decks from the cards you own.")
                    .foregroundStyle(.secondary)
                GroupBox {
                    VStack(alignment:.leading, spacing:10) {
                        Text("Rakdos Midrange").font(.headline)
                        Text("Modern • 60 / 60 cards")
                        ProgressView(value:1)
                        Text("CardVault can prioritize cards already in your collection and show what you're missing.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct SearchView: View {
    @EnvironmentObject var store: CollectionStore
    @State private var query = ""
    var results: [MagicCard] {
        query.isEmpty ? store.cards : store.cards.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.setName.localizedCaseInsensitiveContains(query)
        }
    }
    var body: some View {
        NavigationStack {
            List(results) { card in
                VStack(alignment:.leading) {
                    Text(card.name).font(.headline)
                    Text(card.setName).font(.caption).foregroundStyle(.secondary)
                }
            }
            .searchable(text:$query, prompt:"Search cards")
            .navigationTitle("Search")
        }
    }
}
