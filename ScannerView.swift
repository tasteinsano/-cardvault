import SwiftUI
import AVFoundation
import Vision

struct ScannerView: View {
    @EnvironmentObject var store: CollectionStore
    @State private var showingCamera = false
    @State private var recognizedText = ""
    @State private var match: MagicCard?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing:20) {
                Spacer()
                Image(systemName:"camera.viewfinder")
                    .font(.system(size:72))
                    .foregroundStyle(.purple)
                Text("Scan a Magic Card")
                    .font(.largeTitle.bold())
                Text("Center the card in the camera. CardVault will read the name and look it up.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                Button {
                    showingCamera = true
                } label: {
                    Label("Open Camera", systemImage:"camera.fill")
                        .frame(maxWidth:.infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)

                if !recognizedText.isEmpty {
                    Text("Detected: \(recognizedText)")
                        .font(.caption)
                }
                if let match {
                    CardMatchView(card: match) {
                        store.add(match)
                        self.match = nil
                    }
                }
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red).font(.caption)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Scan")
            .sheet(isPresented:$showingCamera) {
                CameraView { image in
                    showingCamera = false
                    recognize(image: image)
                }
                .ignoresSafeArea()
            }
        }
    }

    private func recognize(image: UIImage) {
        errorMessage = nil
        guard let cg = image.cgImage else { return }
        let request = VNRecognizeTextRequest { request, error in
            DispatchQueue.main.async {
                if let error { errorMessage = error.localizedDescription; return }
                let strings = (request.results as? [VNRecognizedTextObservation] ?? [])
                    .compactMap { $0.topCandidates(1).first?.string }
                recognizedText = strings.joined(separator:" ")
                let possibleName = strings.first(where: { $0.count > 3 }) ?? ""
                Task {
                    match = await ScryfallAPI.lookup(name: possibleName)
                    if match == nil {
                        errorMessage = "I couldn't confidently identify that card. Try a clearer photo with the card name visible."
                    }
                }
            }
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        VNImageRequestHandler(cgImage: cg, options: [:]).perform([request])
    }
}

struct CardMatchView: View {
    let card: MagicCard
    let add: () -> Void
    var body: some View {
        VStack(alignment:.leading, spacing:8) {
            Text(card.name).font(.title2.bold())
            Text(card.setName).foregroundStyle(.secondary)
            Text(card.priceUSD ?? 0, format:.currency(code:"USD"))
                .font(.title3.bold())
            Button("Add to Collection", action:add)
                .buttonStyle(.borderedProminent).tint(.purple)
        }
        .frame(maxWidth:.infinity, alignment:.leading)
        .padding()
        .background(.purple.opacity(0.12), in:RoundedRectangle(cornerRadius:18))
    }
}
