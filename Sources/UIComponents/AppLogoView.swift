import SwiftUI

struct AppLogoView: View {
    var size: CGFloat = 36

    var body: some View {
        Image("Logo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
            .shadow(color: Theme.neonGreen.opacity(0.25), radius: 6)
    }
}