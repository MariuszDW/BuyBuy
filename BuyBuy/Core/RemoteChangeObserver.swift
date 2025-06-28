//
//  RemoteChangeObserver.swift
//  BuyBuy
//
//  Created by MDW on 28/06/2025.
//

import Foundation

final class RemoteChangeObserver {

    /// Waits until a remote change notification is received (no timeout).
    func waitForRemoteChange() async {
        for await _ in NotificationCenter.default.notifications(named: .NSPersistentStoreRemoteChange) {
            print("Remote change notification received.")
            break
        }
    }

    /// Waits for a remote change notification or times out after the given number of seconds.
    /// - Parameter seconds: How long to wait before giving up.
    /// - Returns: `true` if a remote change was received before timeout, otherwise `false`.
    func waitForRemoteChange(timeout seconds: TimeInterval) async -> Bool {
        await withTaskGroup(of: Bool.self) { group in
            // Task: wait for the remote change notification.
            group.addTask {
                for await _ in NotificationCenter.default.notifications(named: .NSPersistentStoreRemoteChange) {
                    print("Remote change notification received before timeout.")
                    return true
                }
                return false
            }

            // Task: wait for the timeout duration.
            group.addTask {
                try? await Task.sleep(for: .seconds(seconds))
                guard !Task.isCancelled else { return false }
                print("Timeout reached. No remote change received.")
                return false
            }

            // Return the result of the first task that finishes (notification or timeout).
            for await result in group {
                group.cancelAll()
                return result
            }

            return false
        }
    }
}
