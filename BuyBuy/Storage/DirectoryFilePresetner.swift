//
//  DirectoryFilePresetner.swift
//  BuyBuy
//
//  Created by MDW on 25/06/2025.
//

import Foundation

final class DirectoryFilePresenter: NSObject, NSFilePresenter {
    let presentedItemURL: URL?
    let presentedItemOperationQueue: OperationQueue = OperationQueue()

    private let onChange: @Sendable () -> Void

    init(directoryURL: URL, onChange: @Sendable @escaping () -> Void) {
        self.presentedItemURL = directoryURL
        self.onChange = onChange
        super.init()
    }

    func presentedSubitemDidChange(at url: URL) {
        onChange()
    }

    func presentedItemDidChange() {
        onChange()
    }
}
