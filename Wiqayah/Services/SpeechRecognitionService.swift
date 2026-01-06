import Foundation
import AVFoundation
import Speech

/// Manages speech recognition using Apple's Speech framework and Google Cloud Speech-to-Text
final class SpeechRecognitionService: NSObject, ObservableObject {
    static let shared = SpeechRecognitionService()

    // MARK: - Published Properties
    @Published var isRecording = false
    @Published var isProcessing = false
    @Published var recognizedText = ""
    @Published var audioLevel: Float = 0.0
    @Published var error: SpeechError?

    // MARK: - Audio Properties
    private var audioEngine: AVAudioEngine?
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private var levelTimer: Timer?

    // MARK: - Speech Recognition Properties
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ar-SA"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    // MARK: - Error Types
    enum SpeechError: LocalizedError {
        case notAuthorized
        case notAvailable
        case recordingFailed
        case recognitionFailed
        case networkError
        case noSpeechDetected

        var errorDescription: String? {
            switch self {
            case .notAuthorized:
                return "Microphone access not authorized"
            case .notAvailable:
                return "Speech recognition not available"
            case .recordingFailed:
                return "Failed to start recording"
            case .recognitionFailed:
                return "Failed to recognize speech"
            case .networkError:
                return "Network error occurred"
            case .noSpeechDetected:
                return "No speech detected"
            }
        }
    }

    // MARK: - Initialization
    override private init() {
        super.init()
    }

    // MARK: - Authorization

    /// Request microphone and speech recognition permissions
    func requestAuthorization() async -> Bool {
        // Request microphone permission
        let micGranted = await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }

        guard micGranted else {
            error = .notAuthorized
            return false
        }

        // Request speech recognition permission
        let speechGranted = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }

        if !speechGranted {
            error = .notAuthorized
        }

        return micGranted && speechGranted
    }

    /// Check current authorization status
    var isAuthorized: Bool {
        let micStatus = AVAudioApplication.shared.recordPermission == .granted
        let speechStatus = SFSpeechRecognizer.authorizationStatus() == .authorized
        return micStatus && speechStatus
    }

    // MARK: - Recording

    /// Start recording audio
    func startRecording() {
        guard !isRecording else { return }

        error = nil
        recognizedText = ""

        do {
            try setupAudioSession()
            try startAudioEngine()

            isRecording = true
            startLevelMonitoring()

            HapticManager.shared.recordingStarted()
        } catch {
            self.error = .recordingFailed
            isRecording = false
        }
    }

    /// Stop recording and process the audio
    func stopRecording() async -> String {
        guard isRecording else { return "" }

        HapticManager.shared.recordingStopped()

        stopLevelMonitoring()
        isRecording = false
        isProcessing = true

        // Stop recognition
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)

        // Wait a moment for final results
        try? await Task.sleep(nanoseconds: 500_000_000)

        isProcessing = false
        return recognizedText
    }

    /// Cancel recording without processing
    func cancelRecording() {
        stopLevelMonitoring()
        isRecording = false
        isProcessing = false

        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)

        recognizedText = ""
    }

    // MARK: - Audio Setup

    private func setupAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func startAudioEngine() throws {
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            throw SpeechError.recordingFailed
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechError.recordingFailed
        }

        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.addsPunctuation = false

        // Configure for Arabic
        if #available(iOS 16.0, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self?.recognizedText = result.bestTranscription.formattedString
                }
            }

            if let error = error {
                print("Recognition error: \(error.localizedDescription)")
            }
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
            self?.updateAudioLevel(buffer: buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    // MARK: - Audio Level Monitoring

    private func startLevelMonitoring() {
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            // Audio level is updated in the tap callback
            self?.objectWillChange.send()
        }
    }

    private func stopLevelMonitoring() {
        levelTimer?.invalidate()
        levelTimer = nil
        audioLevel = 0.0
    }

    private func updateAudioLevel(buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }

        let channelDataValue = channelData.pointee
        let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride)
            .map { channelDataValue[$0] }

        let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
        let avgPower = 20 * log10(rms)

        DispatchQueue.main.async {
            // Normalize to 0-1 range
            self.audioLevel = max(0, min(1, (avgPower + 50) / 50))
        }
    }

    // MARK: - Google Cloud Speech-to-Text (Alternative)

    /// Use Google Cloud Speech-to-Text for recognition
    func recognizeWithGoogle(audioData: Data) async -> String? {
        let apiKey = Constants.API.googleSpeechToTextKey

        guard apiKey != "YOUR_GOOGLE_SPEECH_API_KEY" else {
            print("Google Speech API key not configured")
            return nil
        }

        let url = URL(string: "\(Constants.API.googleSpeechEndpoint)?key=\(apiKey)")!

        let requestBody: [String: Any] = [
            "config": [
                "encoding": "LINEAR16",
                "sampleRateHertz": Constants.SpeechRecognition.sampleRate,
                "languageCode": Constants.SpeechRecognition.languageCode,
                "alternativeLanguageCodes": Constants.SpeechRecognition.alternativeLanguages
            ],
            "audio": [
                "content": audioData.base64EncodedString()
            ]
        ]

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(GoogleSpeechResponse.self, from: data)

            return response.results?.first?.alternatives?.first?.transcript
        } catch {
            print("Google Speech API error: \(error)")
            self.error = .networkError
            return nil
        }
    }
}

// MARK: - Google Speech Response Models
private struct GoogleSpeechResponse: Codable {
    let results: [SpeechResult]?

    struct SpeechResult: Codable {
        let alternatives: [Alternative]?
    }

    struct Alternative: Codable {
        let transcript: String?
        let confidence: Double?
    }
}
