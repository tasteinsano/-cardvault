import Foundation

enum ScryfallAPI {
    static func lookup(name: String) async -> MagicCard? {
        let cleaned = name.trimmingCharacters(in:.whitespacesAndNewlines)
        guard !cleaned.isEmpty,
              let encoded = cleaned.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed),
              let url = URL(string:"https://api.scryfall.com/cards/named?fuzzy=\(encoded)") else { return nil }
        do {
            var request = URLRequest(url:url)
            request.setValue("CardVault/1.0", forHTTPHeaderField:"User-Agent")
            let (data, response) = try await URLSession.shared.data(for:request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
            let decoded = try JSONDecoder().decode(ScryfallCard.self, from:data)
            return MagicCard(id:decoded.id, name:decoded.name, setName:decoded.set_name,
                             rarity:decoded.rarity, imageURL:decoded.image_uris?.normal,
                             priceUSD:Double(decoded.prices.usd ?? ""))
        } catch { return nil }
    }

    struct ScryfallCard: Codable {
        let id: String
        let name: String
        let set_name: String
        let rarity: String
        let image_uris: ImageURIs?
        let prices: Prices
    }
    struct ImageURIs: Codable { let normal: String? }
    struct Prices: Codable { let usd: String? }
}
