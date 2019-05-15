//
//  DataManager.swift
//  iOS-Chatty
//
//  Created by Alvin Ling on 5/10/19.
//  Copyright © 2019 iOSPlayground. All rights reserved.
//

import CoreData

class DataManager {
    
    private init() {}
    static let shared = DataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "iOS_Chatty")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext (context: NSManagedObjectContext? = nil) {
        let context = context ?? persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension DataManager {

    func createMessage(chatID: String, sender: String?, avatarID: Int, body: String, isSent: Bool) {
        guard !body.isEmpty else { return }
        let message = Message(context: mainContext)
        message.timestamp = Date()
        message.chatID = chatID
        message.avatarID = Int32(avatarID)
        message.body = body
        message.isSent = isSent
        message.sender = sender
        saveContext()
    }

}


extension DataManager {
    
    func messageFRC(chatID: String) -> NSFetchedResultsController<Message> {
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.predicate = NSPredicate(format: "chatID == %@", chatID)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        return NSFetchedResultsController<Message>(fetchRequest: request, managedObjectContext: mainContext, sectionNameKeyPath: nil, cacheName: nil)
    }
}
