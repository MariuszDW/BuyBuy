//
//  SharingControllerWrapper.swift
//  BuyBuy
//
//  Created by MDW on 10/09/2025.
//

import Foundation
import SwiftUI
import UIKit
import CloudKit

struct SharingControllerWrapper: UIViewControllerRepresentable {
    let share: CKShare
    let shoppingListTitle: String
    
    init(share: CKShare, shoppingListTitle: String) {
        self.share = share
        self.shoppingListTitle = shoppingListTitle
        AppLogger.general.debug("SharingControllerWrapper(): \(share.detailedDescription(), privacy: .public)")
    }

    func makeUIViewController(context: Context) -> UICloudSharingController {
        let controller = UICloudSharingController(share: share, container: CKContainer.default())
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {
        // None.
    }

    func makeCoordinator() -> SharingControllerCoordinator {
        SharingControllerCoordinator(itemTitle: shoppingListTitle)
    }

    class SharingControllerCoordinator: NSObject, UICloudSharingControllerDelegate {
        private let itemTitle: String
        
        init(itemTitle: String) {
            self.itemTitle = itemTitle
        }
        
        func itemTitle(for csc: UICloudSharingController) -> String? {
            return itemTitle
        }

        func cloudSharingController(_ csc: UICloudSharingController,
                                    failedToSaveShareWithError error: Error) {
            AppLogger.general.info("UICloudSharingControllerDelegate - Cloud sharing failed: \(error, privacy: .public)")
            AppLogger.general.debug("\(csc.share?.detailedDescription() ?? "CKShare = nil", privacy: .public)")
        }

        func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
            AppLogger.general.info("UICloudSharingControllerDelegate - Share saved successfully")
            AppLogger.general.debug("\(csc.share?.detailedDescription() ?? "CKShare = nil", privacy: .public)")
        }

        func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
            AppLogger.general.info("UICloudSharingControllerDelegate - Sharing stopped")
            AppLogger.general.debug("\(csc.share?.detailedDescription() ?? "CKShare = nil", privacy: .public)")
        }
    }
}
