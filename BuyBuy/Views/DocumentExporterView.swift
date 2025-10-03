//
//  DocumentExporterView.swift
//  BuyBuy
//
//  Created by MDW on 16/06/2025.
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct DocumentExporterView: UIViewControllerRepresentable {
    let data: Data
    let fileName: String
    let fileExtension: String

    func makeCoordinator() -> Coordinator {
        Coordinator(data: data, fileName: fileName, fileExtension: fileExtension)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let tempURL = context.coordinator.tempFileURL
        AppLogger.general.info("Using temp file URL: \(tempURL.path, privacy: .public)")

        let picker = UIDocumentPickerViewController(forExporting: [tempURL], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let tempFileURL: URL

        init(data: Data, fileName: String, fileExtension: String) {
            let sanitizedFileName = fileName.replacingOccurrences(of: "[^a-zA-Z0-9_-]", with: "_", options: .regularExpression)
            let fileURL = FileManager.default.temporaryDirectory
                .appending(path: sanitizedFileName, directoryHint: .notDirectory)
                .appendingPathExtension(fileExtension)

            do {
                try data.write(to: fileURL, options: .atomic)
                AppLogger.general.info("File written at: \(fileURL.path, privacy: .public)")
            } catch {
                AppLogger.general.error("Failed to write file: \(error, privacy: .public)")
            }

            self.tempFileURL = fileURL
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            AppLogger.general.debug("Picker cancelled")
            try? FileManager.default.removeItem(at: tempFileURL)
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            AppLogger.general.debug("User picked document(s): \(urls, privacy: .public)")
            try? FileManager.default.removeItem(at: tempFileURL)
        }
    }
}
