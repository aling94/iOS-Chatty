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
    func createChatLog(recipientID: String) -> ChatLog {
        let log = ChatLog(context: mainContext)
        log.userID = recipientID
        saveContext()
        return log
    }
    
    func createMessage(log: ChatLog, sender: String?, body: String, isSent: Bool) -> Message? {
        guard !body.isEmpty else { return nil }
        let message = Message(context: mainContext)
        message.timestamp = Date()
        message.body = body
        message.isSent = isSent
        message.sender = log.userID
        log.addToMessages(message)
        saveContext()
        return message
    }
    
    func createMessage(chatID: String, sender: String?, body: String, isSent: Bool) -> Message? {
        guard !body.isEmpty else { return nil }
        let message = Message(context: mainContext)
        message.timestamp = Date()
        message.chatID = chatID
        message.body = body
        message.isSent = isSent
        message.sender = sender
        saveContext()
        return message
    }
    
    func getChatLog(userID: String) -> ChatLog? {
        let request: NSFetchRequest<ChatLog> = NSFetchRequest<ChatLog>()
        request.predicate = NSPredicate(format: "userID == %@", userID)
        guard let logs = try? mainContext.fetch(request) else { return nil }
        return logs.first
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
