//
//  Persistence.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        for i in 0..<5 {
            let list = ShoppingListEntity(context: viewContext)
            list.id = UUID()
            list.name = "Lista \(i)"
            list.note = "Notatka do listy \(i)"
            list.order = Int64(i)
            list.icon = ListIcon.default.rawValue
            list.color = ListColor.default.rawValue

            // Możesz tu dodać przykładowe ShoppingItemEntity, np:
            for j in 0..<3 {
                let item = ShoppingItemEntity(context: viewContext)
                item.id = UUID()
                item.list = list
                item.name = "Przedmiot \(j)"
                item.note = nil
                item.status = ShoppingItemStatus.pending.rawValue
                item.order = Int64(j)
                // Powiąż relację jeśli masz (np. item.list = list)
                item.list = list
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Model")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
