//
//  ListViewController.swift
//  DocumentsCoreData
//
//  Created by Ryan Glascock on 9/20/19.
//  Copyright © 2019 Ryan Glascock. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var documentsTableView: UITableView!
    
   
    
    struct Document {
        let url: URL
        let name: String
        let size: UInt64
        let modificationDate: Date
        
        var content: String? {
            get {
                return try? String(contentsOf: url, encoding: .utf8)
            }
        }
    }
    class Documents {
        
        class func get() -> [Document] {
            var documents = [Document]()
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            if let urls = try? FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil) {
                for url in urls {
                    let name = url.lastPathComponent
                    if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
                        let size = attributes[FileAttributeKey.size] as? UInt64,
                        let modificationDate = attributes[FileAttributeKey.modificationDate] as? Date {
                        documents.append(Document(url: url, name: name, size: size, modificationDate: modificationDate))
                    }
                }
            }
            
            return documents
        }
        
        class func delete(url: URL) {
            try? FileManager.default.removeItem(at: url)
        }
        
        class func save(name: String, content: String) {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = documentsURL.appendingPathComponent(name)
            
            try? content.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    var documents = [Document]()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Documents"
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
    }
    
    override func viewWillAppear(_ animated: Bool) {
        documents = Documents.get()
        documentsTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell", for: indexPath)
        
        if let cell = cell as? ListTableViewCell {
            let document = documents[indexPath.row]
            cell.nameLabel.text = document.name
            cell.sizeLabel.text = String(document.size) + " bytes"
            cell.modifiedLabel.text = dateFormatter.string(from: document.modificationDate)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let document = self.documents[indexPath.row]
            Documents.delete(url: document.url)
            self.documents = Documents.get()
            self.documentsTableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        return [delete]
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectDoc" {
            if let destination = segue.destination as? ViewController,
                let row = documentsTableView.indexPathForSelectedRow?.row {
                destination.document = documents[row]
            }
        }
    }
    
}

