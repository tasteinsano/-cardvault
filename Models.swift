import Foundation

struct MagicCard: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let setName: String
    let rarity: String
    let imageURL: String?
    let priceUSD: Double?
    var quantity: Int = 1
}

final class CollectionStore: ObservableObject {
    @Published var cards: [MagicCard] = [
        MagicCard(id:"demo-1", name:"Lightning Bolt", setName:"Ravnica: City of Guilds", rarity:"common", imageURL:nil, priceUSD:1.24, quantity:4),
        MagicCard(id:"demo-2", name:"Force of Will", setName:"Iconic Masters", rarity:"rare", imageURL:nil, priceUSD:89.99, quantity:2)
    ]

    var totalValue: Double {
        cards.reduce(0) { $0 + (($1.priceUSD ?? 0) * Double($1.quantity)) }
    }

    func add(_ card: MagicCard) {
        if let i = cards.firstIndex(where: {$0.id == card.id}) {
            cards[i].quantity += 1
        } else {
            cards.append(card)
        }
    }
}
