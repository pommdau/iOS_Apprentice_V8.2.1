//
//  AppDelegate.swift
//  MyLocations
//
//  Created by HIROKI IKEUCHI on 2020/04/22.
//  Copyright © 2020 hikeuchi. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    // 以下のややこしい手順をNSPersistentContainerが簡単にしてくれるのだ
/*
    The goal here is to create an NSManagedObjectContext object. That is the object you’ll use to talk to Core Data. To get that NSManagedObjectContext object, the app needs to do several things:
    1. Create an NSManagedObjectModel from the Core Data model you created earlier. This object represents the data model during runtime. You can ask it what sort of entities it has, what attributes these entities have, and so on. In most apps, you don’t need to use the NSManagedObjectModel object directly.
    2. Create an NSPersistentStoreCoordinator object. This object is in charge of the SQLite database.
    3. Finally, create the NSManagedObjectContext object and connect it to the persistent store coordinator.
    Together, these objects are also known as the “Core Data stack.”
 */
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")

        container.loadPersistentStores {(storeDescription, error) in
            if let error = error {
                fatalError("Could not load data store: \(error)")
            }
        }
        return container
    }()
    
    // NSManagedObjectContextはNSPersistentContainerから取得できる
    lazy var managedObjectContext = persistentContainer.viewContext

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

