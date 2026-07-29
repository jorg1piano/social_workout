import SwiftUI

/// Colours and formatting shared across the app.
///
/// The plan/record pair is carried over from the model explorer's palette
/// deliberately: the same two colours mean the same two things in both apps, so
/// a glance at any screen tells you which side of the model you're looking at.
enum Theme {
    /// Plan side — templates, variants, planned sets. Mutable suggestions.
    static let plan = Color(red: 0.886, green: 0.592, blue: 0.353)
    /// Record side — workouts, performed exercises, logged sets. What happened.
    static let record = Color(red: 0.200, green: 0.749, blue: 0.682)
    static let accent = Color(red: 0.357, green: 0.549, blue: 1.0)

    static func color(for setType: SetType) -> Color {
        switch setType {
        case .warmup: return .orange
        case .regularSet: return .secondary
        case .dropSet: return .purple
        case .failure: return .red
        }
    }
}

/// Which half of the data model something belongs to.
enum ModelSide: String {
    case plan = "PLAN"
    case record = "RECORD"

    var color: Color { self == .plan ? Theme.plan : Theme.record }
}

enum Format {
    /// Weights read as "80", "82.5" — never "80.0". Negative weight is
    /// assistance (the machine takes load off you), so it's shown as "−20".
    static func weight(_ value: Double?, unit: String? = nil) -> String {
        guard let value else { return "—" }
        let number = value.rounded() == value
            ? String(Int(value))
            : String(format: "%.1f", value)
        let signed = value < 0 ? "−" + number.replacingOccurrences(of: "-", with: "") : number
        guard let unit, !unit.isEmpty else { return signed }
        return "\(signed) \(unit)"
    }

    static func reps(_ value: Int?) -> String {
        value.map(String.init) ?? "—"
    }

    /// "8 × 80 kg", or "Bodyweight" when the load is exactly zero.
    static func setSummary(reps: Int?, weight: Double?, unit: String?) -> String {
        let repText = reps.map { "\($0)" } ?? "—"
        guard let weight else { return "\(repText) reps" }
        if weight == 0 { return "\(repText) × bodyweight" }
        return "\(repText) × \(Self.weight(weight, unit: unit))"
    }

    /// "1h 15m" / "45m" / "20s".
    static func duration(_ interval: TimeInterval?) -> String {
        guard let interval, interval > 0 else { return "—" }
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        if minutes > 0 { return "\(minutes)m" }
        return "\(seconds)s"
    }

    /// Rest between sets, as planned: "90s", "2m", "2m 30s".
    static func rest(_ seconds: Int) -> String {
        guard seconds > 0 else { return "no rest" }
        if seconds < 60 { return "\(seconds)s" }
        let minutes = seconds / 60
        let remainder = seconds % 60
        return remainder == 0 ? "\(minutes)m" : "\(minutes)m \(remainder)s"
    }

    static func date(_ date: Date?) -> String {
        guard let date else { return "—" }
        return date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
    }

    static func relative(_ date: Date?) -> String {
        guard let date else { return "—" }
        return date.formatted(.relative(presentation: .named))
    }

    /// Compact volume: "12.4k kg".
    static func volume(_ value: Double) -> String {
        guard value > 0 else { return "—" }
        if value >= 1000 { return String(format: "%.1fk", value / 1000) }
        return String(Int(value))
    }
}
