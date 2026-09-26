#if DEBUG
import SwiftUI

/// Native component checkpoint. Inspect on a Mac; HTML cannot validate these controls.
@MainActor
private struct ComponentLab: View {
    @State private var address = ""
    @State private var enabled = false

    var body: some View {
        NavigationStack {
            Form {
                Section("reader.howTo") {
                    Text("Wristbeam").font(.headline)
                    Text("reader.helpBody").font(.body)
                    Text("reader.openWatch").font(.caption).foregroundStyle(.secondary)
                }
                Section("reader.address") {
                    TextField("reader.address", text: $address).textContentType(.URL)
                    Button("reader.open") {}.disabled(address.isEmpty)
                    Text("reader.invalidURL").font(.callout)
                }
                Section("remote.ready") {
                    Button("remote.next") {}.buttonStyle(.borderedProminent)
                    Button("remote.previous") {}.buttonStyle(.bordered)
                    Button("remote.retry") {}.disabled(true)
                    ProgressView()
                    Toggle("reader.keepAwake", isOn: $enabled)
                }
            }
            .navigationTitle("Wristbeam")
        }
    }
}

#Preview("Native controls") { ComponentLab() }
#Preview("Large text / dark") {
    ComponentLab().environment(\.dynamicTypeSize, .accessibility2).preferredColorScheme(.dark)
}
#endif
