import Observation
import Sparkle

/// Checks GitHub for a newer Paste. The only network use in the app, and it never sends Bindings or personal data.
@MainActor
@Observable
final class Updates {
    @ObservationIgnored private let controller = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)

    var checksAutomatically: Bool {
        didSet { controller.updater.automaticallyChecksForUpdates = checksAutomatically }
    }

    init() {
        checksAutomatically = controller.updater.automaticallyChecksForUpdates
    }

    func checkNow() { controller.checkForUpdates(nil) }
}
