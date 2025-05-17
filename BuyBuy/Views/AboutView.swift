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
                .font(.title.bold())

            Text(Bundle.main.appVersion)
                .font(.footnote)
                .foregroundColor(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("OK") {
                    dismiss()
                }
            }
        }
    }
}
