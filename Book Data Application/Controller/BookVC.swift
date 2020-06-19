//
//  ViewController.swift
//  Book Data Application
//
//  Created by Mohammad Kiani on 2020-06-13.
//  Copyright © 2020 mohammadkiani. All rights reserved.
//

import UIKit
import CoreData

class BookVC: UIViewController {
    
    //MARK: - CoreData manipulation - appDelegate and the context
    
    // 1 - creating an instance of AppDelage
    /// appDelegaet instance
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // 2 - create the context
    var managedContext: NSManagedObjectContext!
    
    var books: [Book]?

    @IBOutlet var textFields: [UITextField]!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 2 - create the context
        /// the context to use for the coreData
        managedContext = appDelegate.persistentContainer.viewContext
        
//        NotificationCenter.default.addObserver(self, selector: #selector(saveData), name: UIApplication.willResignActiveNotification, object: nil)
        
//        loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveCoreData), name: UIApplication.willResignActiveNotification, object: nil)
        
        loadCoreData()
    }
    
    func getDataFilePath() -> String {
        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = documentPath.appending("/book-data.txt")
        return filePath
    }

    @IBAction func addBookInfo(_ sender: UIBarButtonItem) {
        let title = textFields[0].text ?? ""
        let author = textFields[1].text ?? ""
        let pages = Int(textFields[2].text ?? "0") ?? 0
        let year = Int(textFields[3].text ?? "1900") ?? 1900
        
        let book = Book(title: title, author: author, pages: pages, year: year)
        books?.append(book)
        
        for textField in textFields {
            textField.text = ""
            textField.resignFirstResponder()
        }
    }
    
    func loadData() {
        books = [Book]()
        
        let filePath = getDataFilePath()
        
        if FileManager.default.fileExists(atPath: filePath) {
            
            do {
                // creating string of the file path
                let fileContent = try String(contentsOfFile: filePath)
                // seperating the books from each other
                let contentArray = fileContent.components(separatedBy: "\n")
                for content in contentArray {
                    // seperating each book's contents
                    let bookContent = content.components(separatedBy: ",")
                    if bookContent.count == 4 {
                        let book = Book(title: bookContent[0], author: bookContent[1], pages: Int(bookContent[2])!, year: Int(bookContent[3])!)
                        books?.append(book)
                    }
                }
            } catch {
                print(error)
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let bookListTableVC = segue.destination as? BookListTVC {
            bookListTableVC.books = self.books
        }
    }
    
    @objc func saveData() {
        let filePath = getDataFilePath()
        
        var saveString = ""
        for book in books! {
            saveString = "\(saveString)\(book.title),\(book.author),\(book.pages),\(book.year)\n"
        }
        
        do {
            try saveString.write(toFile: filePath, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
    }
    
    //MARK: - CoreData functions
    
    func loadCoreData() {
        books = [Book]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookModel")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            if results is [NSManagedObject] {
                for result in (results as! [NSManagedObject]) {
                    let title = result.value(forKey: "title") as! String
                    let author = result.value(forKey: "author") as! String
                    let pages = result.value(forKey: "pages") as! Int
                    let year = result.value(forKey: "year") as! Int
                    
                    books?.append(Book(title: title, author: author, pages: pages, year: year))
                }
            }
            
        } catch {
            print(error)
        }
    }
    
    @objc func saveCoreData() {
        clearCoreData()
        for book in books! {
            let bookEntity = NSEntityDescription.insertNewObject(forEntityName: "BookModel", into: managedContext)
            bookEntity.setValue(book.title, forKey: "title")
            bookEntity.setValue(book.author, forKey: "author")
            bookEntity.setValue(book.pages, forKey: "pages")
            bookEntity.setValue(book.year, forKey: "year")
        }
        
        do {
            try managedContext.save()
        } catch {
            print(error)
        }
    }
    
    func clearCoreData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BookModel")
//        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try managedContext.fetch(fetchRequest)
            for result in results {
                if let managedObject = result as? NSManagedObject {
                    managedContext.delete(managedObject)
                }
            }
        } catch {
            print("Error deleting records \(error)")
        }
        
    }
    
}

