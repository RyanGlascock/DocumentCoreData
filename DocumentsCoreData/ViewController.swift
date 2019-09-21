//
//  ViewController.swift
//  DocumentsCoreData
//
//  Created by Ryan Glascock on 9/20/19.
//  Copyright © 2019 Ryan Glascock. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var documentTextView: UITextView!
    
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
    
    var document: Document?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let document = document {
            documentTextView.text = document.content ?? ""
            nameTextField.text = document.name
            
            title = document.name
        } else {
            title = ""
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func nameChanged(_ sender: Any) {
        title = nameTextField.text
    }
    
    @IBAction func save(_ sender: Any) {
        guard let name = nameTextField.text else {
            return
        }
        
        Documents.save(name: name, content: documentTextView.text)
        
        navigationController?.popViewController(animated: true)
    }
}

