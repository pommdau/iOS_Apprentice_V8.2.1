//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by HIROKI IKEUCHI on 2020/04/23.
//  Copyright © 2020 hikeuchi. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    
    //    var locations = [Location]()  // NSManagedObject型
    lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
        /*
         Get all Location objects from the data store and sort them by date.
         */
        // fetching: data storeからデータを取得すること
        // fetchRequest: fetchするためのオブジェクト。
        let fetchRequest = NSFetchRequest<Location>()  // DataStoreから引き出すオブジェクトを設定する
        
        // 引き出したいLocationのentityを設定
        let entity = Location.entity()
        fetchRequest.entity = entity
        
        // 引き出すデータをソート
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchRequest.fetchBatchSize = 20  // 一度に読み込むオブジェクトの数を設定する（多すぎるとメモリの無駄になる）
        
        // cacheName: キャッシュしておくことで、次回起動時にNSFetchedResultsControllerがデータを検索する必要がなくなる
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.managedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: "Locations")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performFetch()
    }
    
    // NSFetchedResultsControllerが必要なくなったときにnilにしておく
    // 無駄な通知を受け取らないようにするため
    // 実質的には必要ないが、defensive programmingである。書く習慣をつけておくと良い。
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    // MARK:- Helper Methods
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let location = fetchedResultsController.object(at: indexPath)
                controller.locationToEdit = location
            }
        }
    }
    
    
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // NSFetchedResultsControllerはsectionsプロパティを持つ
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        
        let location = fetchedResultsController.object(at: indexPath)
        cell.configure(for: location)
        
        return cell
    }
}


// MARK:- NSFetchedResultsController Delegate Extension
// いろいろ長く書いてあるけど、コピペして流用するから大体でOKよ！
extension LocationsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    // オブジェクトに変更があった際に呼ばれる
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRow(at: indexPath!)as? LocationCell {
                let location = controller.object(at: indexPath!) as! Location
                cell.configure(for: location)
            }
            
        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        @unknown default:
            fatalError("Unhandled switch case of NSFetchedResultsChangeType")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (section)")
        case .move:
            print("*** NSFetchedResultsChangeMove (section)")
        @unknown default:
            fatalError("Unhandled switch case of NSFetchedResultsChangeType")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}
