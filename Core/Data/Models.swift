import Foundation
import SwiftUI

enum WorkoutLevel: String, Codable, CaseIterable, Identifiable {
    case beginner, intermediate, advanced
    var id: String { rawValue }
}

enum Equipment: String, Codable, CaseIterable, Identifiable {
    case bodyweight, dumbbells, kettlebell, bands, bench
    var id: String { rawValue }
}

struct WorkoutPhase: Codable, Identifiable {
    struct Block: Codable, Identifiable {
        let id = UUID()
        let branch: String?
        let exercise: String
        let duration: Int
        let rest: Int?
        let video: String?
        let cues: [String]?
    }

    let id = UUID()
    let name: String
    let blocks: [Block]
}

struct Workout: Codable, Identifiable {
    struct MusicBinding: Codable {
        let playlistAdminId: String
        let bpmTarget: [Double]
        let energy: [Double]
    }

    let id: String
    let title: String
    let duration: Int
    let level: WorkoutLevel
    let equipment: [Equipment]
    let phases: [WorkoutPhase]
    let music: MusicBinding
}

struct Exercise: Codable, Identifiable {
    let id: String
    let name: String
    let muscles: [String]
    let equipment: [Equipment]
    let difficulty: WorkoutLevel
    let video: String
}

struct VoiceCue: Codable, Hashable, Identifiable {
    enum Priority: Int, Codable {
        case encouragement = 1
        case countdown = 2
        case safety = 3
    }

    let id: String
    let text: String
    let type: Priority
    let locale: String
    let prebundledAsset: String?
}

struct PlaylistBinding {
    let spotifyURI: String
    let defaultCriteria: TrackCriteria
}

struct TrackCriteria {
    let bpm: ClosedRange<Double>
    let energy: ClosedRange<Double>
}

struct WorkoutSession {
    let workout: Workout
    let startDate: Date
    let intensity: TrackCriteria
}

struct UserAccount: Identifiable {
    let id: String
    let name: String
}

struct AnalyticsEvent {
    let name: String
    let metadata: [String: String]
}
