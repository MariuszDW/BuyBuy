//
//  ListSettingsView.swift
//  BuyBuy
//
//  Created by MDW on 17/05/2025.
//

import SwiftUI

struct ListSettingsView: View {
    @StateObject var viewModel: ListSettingsViewModel
    @EnvironmentObject private var dependencies: AppDependencies
    @Environment(\.dismiss) private var dismiss

    private var designSystem: DesignSystem {
        dependencies.designSystem
    }
    
    init(viewModel: ListSettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    nameSection
                    iconSection
                    colorSection
                }
                .padding()
            }
            .navigationTitle("List settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") {
                        viewModel.applyChanges()
                        dismiss()
                    }
                    .disabled(viewModel.list.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(
                "List name",
                text: $viewModel.list.name
            )
            .textInputAutocapitalization(.sentences)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(ListIcon.allCases, id: \.self) { icon in
                        Button {
                            viewModel.list.icon = icon
                        } label: {
                            ZStack {
                                if viewModel.list.icon == icon {
                                    Circle()
                                        .stroke(designSystem.colors.selection, lineWidth: 3)
                                        .frame(width: 48, height: 48)
                                }

                                Image(systemName: icon.rawValue)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36, height: 36)
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.white, viewModel.list.color.color)
                            }
                            .frame(width: 48, height: 48)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(4)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6)) {
                ForEach(ListColor.allCases, id: \.self) { color in
                    Button {
                        viewModel.list.color = color
                    } label: {
                        ZStack {
                            Circle()
                                .stroke(designSystem.colors.selection, lineWidth: 3)
                                .opacity(viewModel.list.color == color ? 1 : 0)
                                .frame(width: 44, height: 44)

                            Circle()
                                .fill(color.color)
                                .frame(width: 32, height: 32)
                        }
                    }
                    .frame(width: 44, height: 44)
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical, 4)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
