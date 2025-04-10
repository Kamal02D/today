//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    var items  : [ListItem] = []

    @IBOutlet weak var searchBar: UISearchBar!
    
    
    let defaults = UserDefaults.standard
    let customPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent( "items.plist" )
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadData()
        
        
        searchBar.delegate = self
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDpItemCell",for: indexPath)
        
        cell.textLabel?.text = items[indexPath.row].text
        cell.accessoryType = items[indexPath.row].isSelected ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(items[indexPath.row])  was selected")
        
        tableView.deselectRow(at: indexPath, animated: true)
        

        if items[indexPath.row].isSelected {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            items[indexPath.row].isSelected  = false
        }else{
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
            items[indexPath.row].isSelected = true
        }

        
        tableView.reloadData()
        //saveToPrefrences()
        saveData()
    }
    
    
    
    
    @IBAction func onAddClicked(_ sender: Any) {
        let uiAlert = UIAlertController(title: "add", message: "are you sure bro?", preferredStyle: .alert)
        
        var textField : UITextField? = nil
        let alterAction = UIAlertAction(title: "adding item", style: UIAlertAction.Style.default) { action in
            print("action adding chossen",textField?.text?.description ?? "no text")

            //let item = ListItem(text: textField?.text ?? "",isSelected:false)
            
            let item = ListItem(context: self.context)
            item.text = textField?.text ?? ""
            item.isSelected = false
            self.items.append(item)
            self.tableView.reloadData()
            //saveToPrefrences()
            self.saveData()
        }
        uiAlert.addTextField { txtfield in
            txtfield.placeholder = "enter item man"
            textField = txtfield
        }
        uiAlert.addAction(alterAction)
        present(uiAlert, animated: true)
        
    }
    
    
    
    func saveData(){
        do {
            try self.context.save()
            print("mybe success?")
        }catch {
            print("error happend bro : \(error)")
        }
    }
    
    func loadData(with request : NSFetchRequest<ListItem> = ListItem.fetchRequest()){
        do{
            let data = try context.fetch(request)
            //print("got data : \(data)")
            items = data
            tableView.reloadData()
        }catch {
            print("error happend reading the stored data : \(error)")
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try context.save()
        }catch {
            print("can't save context at the end")
        }
    }
    
    
    func deleteItem(index : Int){
        context.delete(items[index])
        items.remove(at: index)
    }
}



extension ToDoListViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("ToDoListViewController clicked \(searchBar.text!)")
        let currentTextOnSearchBar = searchBar.text!
        let predicat = NSPredicate(format: "text CONTAINS[cd] %@",currentTextOnSearchBar)
        let request : NSFetchRequest<ListItem> = ListItem.fetchRequest()
        request.predicate = predicat
        
        print(request)
        
        loadData(with: request)
    
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if  searchBar.text == ""{
            loadData()
            searchBar.resignFirstResponder()
        }
    }

}
