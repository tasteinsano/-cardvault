import SwiftUI

@main
struct CardVaultApp: App {
    @StateObject private var store = CollectionStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
