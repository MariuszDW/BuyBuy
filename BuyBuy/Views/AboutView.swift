//
//  AboutView.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 8) {
            Spacer()

            Text("BuyBuy")
                .font(.boldDynamic(style: .title))

            Text(Bundle.main.appVersion)
                .font(.regularDynamic(style: .footnote))
                .foregroundColor(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle")
                        .accessibilityLabel("Close")
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Light") {
    NavigationStack {
        AboutView()
    }
    .preferredColorScheme(.light)
}

#Preview("Dark") {
    NavigationStack {
        AboutView()
    }
    .preferredColorScheme(.dark)
}
