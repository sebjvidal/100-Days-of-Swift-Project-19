//
//  ActionViewController.swift
//  Extension
//
//  Created by Seb Vidal on 29/12/2021.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UITableViewController {
    var pageTitle = ""
    var pageURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavBar()
        handleJS()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    func setupNavBar() {
        title = "Test"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addScript))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    }
    
    func handleJS() {
        if let inputItem = extensionContext!.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [unowned self] (dict, error) in
                    let itemDictionary = dict as! NSDictionary
                    let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! NSDictionary

                    self.pageTitle = javaScriptValues["title"] as! String
                    self.pageURL = javaScriptValues["URL"] as! String

                    DispatchQueue.main.async {
                        self.title = self.pageTitle
                    }
                }
            }
        }
    }
    
    @objc func addScript() {
        if let editorView = storyboard?.instantiateViewController(withIdentifier: "EditorView") {
            navigationController?.pushViewController(editorView, animated: true)
        }
    }

    @objc func done() {
//        let item = NSExtensionItem()
//        let argument: NSDictionary = ["customJavaScript": script.text]
//        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
//        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
//        item.attachments = [customJavaScript]
//
//        extensionContext?.completeRequest(returningItems: [item])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let scripts = UserDefaults.standard.array(forKey: "scripts") as? [String] else {
            return 0
        }
        
        return scripts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let scripts = UserDefaults.standard.array(forKey: "scripts") as? [String] else {
            fatalError("Failed to load scripts")
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = scripts[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let scripts = UserDefaults.standard.array(forKey: "scripts") as? [String] else {
            fatalError("Failed to load scripts")
        }
        
        let script = scripts[indexPath.row]
        
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]

        extensionContext?.completeRequest(returningItems: [item])
    }
    
}
