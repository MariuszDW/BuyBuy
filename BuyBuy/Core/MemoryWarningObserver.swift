//
//  MemoryWarningObserver.swift
//  BuyBuy
//
//  Created by MDW on 07/06/2025.
//

import UIKit
import Combine

final class MemoryWarningObserver: ObservableObject {
    private var cancellable: AnyCancellable?
    private let onMemoryWarning: () -> Void

    init(onMemoryWarning: @escaping () -> Void) {
        self.onMemoryWarning = onMemoryWarning

        cancellable = NotificationCenter.default
            .publisher(for: UIApplication.didReceiveMemoryWarningNotification)
            .sink { [weak self] _ in
                self?.onMemoryWarning()
            }
    }
}
