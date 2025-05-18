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
    
    @FocusState private var focusedNameField: Bool?

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
                    iconAndColorSection
                    iconsGridSection
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
            .font(designSystem.fonts.boldDynamic(style: .title3))
            .focused($focusedNameField, equals: true)
            .task {
                focusedNameField = viewModel.isNew
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var iconAndColorSection: some View {
        let screenSize = UIScreen.main.bounds.size
        let shortSide = min(screenSize.width, screenSize.height)
        let iconSize = shortSide * 0.32

        return VStack {
            HStack(alignment: .top, spacing: 24) {
                Image(systemName: viewModel.list.icon.rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, viewModel.list.color.color)

                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible()), count: 4),
                    spacing: 4
                ) {
                    ForEach(ListColor.allCases, id: \.self) { color in
                        ZStack {
                            Circle()
                                .stroke(designSystem.colors.selection, lineWidth: 3)
                                .opacity(viewModel.list.color == color ? 1 : 0)
                                .frame(width: 44, height: 44)

                            Circle()
                                .fill(color.color)
                                .frame(width: 32, height: 32)
                        }
                        .frame(width: 42, height: 42)
                        .contentShape(Circle())
                        .onTapGesture {
                            viewModel.list.color = color
                        }
                    }
                }
                .frame(height: iconSize)
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }


    private var iconsGridSection: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 5),
            spacing: 16
        ) {
            ForEach(ListIcon.allCases, id: \.self) { icon in
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
                .onTapGesture {
                    viewModel.list.icon = icon
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Preview

class PreviewMockListsRepository: ListsRepositoryProtocol {
    func fetchAllLists() -> [ShoppingList] { return [] }
    func deleteList(with id: UUID) {}
    func addList(_ list: ShoppingList) {}
    func updateList(_ list: ShoppingList) {}
}

struct ListSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        var sample: ShoppingList {
            ShoppingList(
                id: UUID(), name: "Sample List", items: [], order: 0, icon: .cart, color: .blue
            )
        }
        
        Group {
            ListSettingsView(
                viewModel: ListSettingsViewModel(
                    list: sample,
                    repository: PreviewMockListsRepository(),
                    isNew: false
                )
            )
            .environmentObject(AppDependencies())
            .preferredColorScheme(.light)
            .previewDisplayName("Light Mode")
            
            ListSettingsView(
                viewModel: ListSettingsViewModel(
                    list: sample,
                    repository: PreviewMockListsRepository(),
                    isNew: false
                )
            )
            .environmentObject(AppDependencies())
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
