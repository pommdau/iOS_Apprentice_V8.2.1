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
    var locations = [Location]()  // NSManagedObject型
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         Get all Location objects from the data store and sort them by date.
        */
        // fetching: data storeからデータを取得すること
        // fetchRequest: fetchするためのオブジェクト。
        let fetchRequest = NSFetchRequest<Location>()  // データから引き出すオブジェクトを設定する
        let entity = Location.entity()
        fetchRequest.entity = entity  // 引き出したいLocationのentityを設定
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            locations = try managedObjectContext.fetch(fetchRequest)
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell

        let location = locations[indexPath.row]
        cell.configure(for: location)
        
        return cell
    }
}
