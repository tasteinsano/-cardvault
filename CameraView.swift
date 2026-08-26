import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    let onPhoto: (UIImage) -> Void
    func makeUIViewController(context: Context) -> CameraViewController {
        let vc = CameraViewController()
        vc.onPhoto = onPhoto
        return vc
    }
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

final class CameraViewController: UIViewController {
    var onPhoto: ((UIImage) -> Void)?
    private let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var preview: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        checkPermission()
    }

    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: setup()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for:.video) { [weak self] ok in
                DispatchQueue.main.async { ok ? self?.setup() : self?.showDenied() }
            }
        default: showDenied()
        }
    }

    private func setup() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for:.video, position:.back),
              let input = try? AVCaptureDeviceInput(device:device) else { return }
        session.beginConfiguration()
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) { session.addOutput(output) }
        session.commitConfiguration()

        preview = AVCaptureVideoPreviewLayer(session:session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = view.bounds
        view.layer.insertSublayer(preview, at:0)

        let button = UIButton(type:.system)
        button.setTitle("●", for:.normal)
        button.titleLabel?.font = .systemFont(ofSize:72)
        button.tintColor = .white
        button.addTarget(self, action:#selector(takePhoto), for:.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo:view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor, constant:-20)
        ])
        DispatchQueue.global(qos:.userInitiated).async { self.session.startRunning() }
    }

    @objc private func takePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with:settings, delegate:self)
    }

    private func showDenied() {
        let label = UILabel()
        label.text = "Camera access is required. Enable Camera for CardVault in Settings."
        label.textColor = .white; label.numberOfLines = 0; label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo:view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo:view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo:view.leadingAnchor, constant:30),
            label.trailingAnchor.constraint(equalTo:view.trailingAnchor, constant:-30)
        ])
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data:data) else { return }
        DispatchQueue.main.async { self.onPhoto?(image) }
    }
}
