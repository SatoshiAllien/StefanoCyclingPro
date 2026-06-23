import SwiftUI

struct AnimatedNumber: View, Animatable {
    var value: Double
    var format: String

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        Text(String(format: format, value))
            .monospacedDigit()
    }
}