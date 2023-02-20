//
//  ViewController.swift
//  realm
//
//  Created by 도헌 on 2023/02/14.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {
    
    let localRealm = try! Realm()
    
    var item: Results<Item>!
    var customBrands: Results<Brand>!

    override func viewDidLoad() {
        super.viewDidLoad()
        //1. fileURL
        print("FileURL: \(localRealm.configuration.fileURL!)")
//        do {
//            let version = try schemaVersionAtURL(realm.configuration.fileURL!)
//            print("SchemaVersion: \(version)")
//        } catch {
//            print(error)
//        }
        
//        do {
//            let task = Item(name: "셔츠 가디건")
//            try! localRealm.write {
//                localRealm.add(task)
//            }
//        }
        
        
    }


}

