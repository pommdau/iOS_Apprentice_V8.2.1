//
//  SceneDelegate.swift
//  MyLocations
//
//  Created by HIROKI IKEUCHI on 2020/04/22.
//  Copyright © 2020 hikeuchi. All rights reserved.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    // 以下のややこしい手順をNSPersistentContainerが簡単にしてくれるのだ
    /*
     The goal here is to create an NSManagedObjectContext object. That is the object you’ll use to talk to Core Data. To get that NSManagedObjectContext object, the app needs to do several things:
     1. Create an NSManagedObjectModel from the Core Data model you created earlier. This object represents the data model during runtime. You can ask it what sort of entities it has, what attributes these entities have, and so on. In most apps, you don’t need to use the NSManagedObjectModel object directly.
     2. Create an NSPersistentStoreCoordinator object. This object is in charge of the SQLite database.
     3. Finally, create the NSManagedObjectContext object and connect it to the persistent store coordinator.
     Together, these objects are also known as the “Core Data stack.”
     */
    // またこの書き方だと一箇所にまとめられるのが良い。通常の変数だと定義・initやらに分散してしまう。
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        
        container.loadPersistentStores {(storeDescription, error) in  // データベースから情報をメモリに読み込む
            if let error = error {
                fatalError("Could not load data store: \(error)")
            }
        }
        return container
    }()
    
    // NSManagedObjectContextはNSPersistentContainerから取得できる
    lazy var managedObjectContext = persistentContainer.viewContext
    
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // CoreDataのエラーハンドリング用
        print(applicationDocumentsDirectory)
        listenForFatalCoreDataNotification()
        
        // managedObjectContextを渡すために、階層を下がっていく
        let tabController = window!.rootViewController as! UITabBarController
        if let tabViewControllers = tabController.viewControllers {
            // First Tab
            var navController = tabViewControllers[0] as! UINavigationController
            let controller1 = navController.viewControllers.first as! CurrentLocationViewController
            controller1.managedObjectContext = managedObjectContext
            
            // Second Tab
            navController = tabViewControllers[1] as! UINavigationController
            let controller2 = navController.viewControllers.first as! LocationsViewController
            controller2.managedObjectContext = managedObjectContext
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    // MARK:- Helper Methods
    // AppDelegateは常に存在するのでエラーハンドリングを書くクラスとして適している
    func listenForFatalCoreDataNotification() {
        // CoreDataSaveFailedNotificationが呼ばれたときに反応するように設定
        NotificationCenter.default.addObserver(
            forName: CoreDataSaveFailedNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { notification in
                // 以下が通知された際の実際の処理
                let message = """
    There was a fatal error in the app and it cannot continue.

    Press OK to terminate the app. Sorry for the inconvenience.
    """
                let alert = UIAlertController(title: "Internal Error",
                                              message: message,
                                              preferredStyle: .alert)
                let action = UIAlertAction(
                    title: "OK",
                    style: .default) { _ in
                        // アプリを終了させる。NSExtectionを使うことでクラッシュログに情報を追加できるように。
                        let exception = NSException(name: NSExceptionName.internalInconsistencyException,
                                                    reason: "Fatal Core Data error",
                                                    userInfo: nil)
                        exception.raise()
                }
                alert.addAction(action)
                
                let tabController = self.window!.rootViewController!
                tabController.present(alert, animated: true, completion: nil)
        })
    }
}

