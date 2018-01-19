/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class GroceryListTableViewController: UITableViewController {

  // MARK: Constants
  let listToUsers = "ListToUsers"
  
  // MARK: Properties 
  var items = [GroceryItem]()
  var filteredItems = [GroceryItem]()
  var user: User!
  var userCountBarButtonItem: UIBarButtonItem!
  
  let searchController = UISearchController(searchResultsController: nil)
  
  //This is a Firebase reference that points to an online location that stores a list of online users.
  let usersRef = FIRDatabase.database().reference(withPath: "online")
  
  let ref = FIRDatabase.database().reference(withPath: "list-items")
  
  
  // MARK: - Private instance methods
  
  func searchBarIsEmpty() -> Bool {
    // Returns true if the text is empty or nil
    return searchController.searchBar.text?.isEmpty ?? true
  }
  
  func filterContentForSearchText(_ searchText: String, scope: String = "All") {
    filteredItems = items.filter({( groceryItem : GroceryItem) -> Bool in
      return groceryItem.name.lowercased().contains(searchText.lowercased())
    })
    
    tableView.reloadData()
  }
  
  func isFiltering() -> Bool {
    return searchController.isActive && !searchBarIsEmpty()
  }
  
  // MARK: UIViewController Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    // Setup the Search Controller
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search Items"
    searchController.searchBar.setValue("Add", forKey: "_cancelButtonText")
    
    //searchController.searchBar.setShowsCancelButton(true, animated: true)
    
    searchController.searchBar.delegate = self
    
    
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    definesPresentationContext = true
    
    
    tableView.allowsMultipleSelectionDuringEditing = false
    
    userCountBarButtonItem = UIBarButtonItem(title: "1",
                                             style: .plain,
                                             target: self,
                                             action: #selector(userCountButtonDidTouch))
    userCountBarButtonItem.tintColor = UIColor.white
    navigationItem.leftBarButtonItem = userCountBarButtonItem
    
    user = User(uid: "FakeId", email: "hungry@person.food")
    
//    Below function takes two parameters: an instance of FIRDataEventType and a closure.
//    The event type specifies what event you want to listen for. The code listens for a .value event type,
//    which in turn listens for all types of changes to the data in your Firebase database—add, removed, and changed.
//    When the change occurs, the database updates the app with the most recent data.
//    The app is notified of the change via the closure, which is passed an instance of FIRDataSnapshot.
//    The snapshot, as its name suggests, represents the data at that specific moment in time.
//    To access the data in the snapshot, you use the value property.
    
//    ref.observe(.value, with: { snapshot in
//      print(snapshot.value)
//    })
    
    // 1 Attach a listener to receive updates whenever the grocery-items endpoint is modified.
    //ref.observe(.value, with: { snapshot in
    // now adding sorting by ordering data by the completed value
    ref.queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
      
      // 2 Store the latest version of the data in a local variable inside the listener’s closure.
      var newItems: [GroceryItem] = []
      
      // 3 The listener’s closure returns a snapshot of the latest set of data.
      //    Using children, you loop through the grocery items.
      for item in snapshot.children {
        // 4 The GroceryItem struct has an initializer that populates its properties using a FIRDataSnapshot.
        //    A snapshot’s value is of type AnyObject, and can be a dictionary, array, number, or string.
        //    After creating an instance of GroceryItem, it’s added it to the array that contains the latest version of the data.
        let groceryItem = GroceryItem(snapshot: item as! FIRDataSnapshot)
        newItems.append(groceryItem)
      }
      
      // 5 Reassign items to the latest version of the data, then reload the table view so it displays the latest version.
      self.items = newItems
      self.tableView.reloadData()
    })
    
    // Here you attach an authentication observer to the Firebase auth object,
    // that in turn assigns the user property when a user successfully signs in.
    
    FIRAuth.auth()!.addStateDidChangeListener { auth, user in
      guard let user = user else { return }
      self.user = User(authData: user)
      
      // 1 Create a child reference using a user’s uid, which is generated when Firebase creates an account.
      let currentUserRef = self.usersRef.child(self.user.uid)
      
      // 2 Use this reference to save the current user’s email.
      currentUserRef.setValue(self.user.email)
      
      // 3 Call onDisconnectRemoveValue() on currentUserRef. This removes the value at the reference’s location
      // after the connection to Firebase closes, for instance when a user quits your app.
      // This is perfect for monitoring users who have gone offline.
      currentUserRef.onDisconnectRemoveValue()
      
    }
    
    
    // This creates an observer that is used to monitor online users. When users go on-and-offline,
    // the title of userCountBarButtonItem updates with the current user count.
    usersRef.observe(.value, with: { snapshot in
  if snapshot.exists() {
    self.userCountBarButtonItem?.title = snapshot.childrenCount.description
  } else {
    self.userCountBarButtonItem?.title = "0"
  }
})
  }
  
  // MARK: UITableView Delegate methods
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isFiltering() {
      return filteredItems.count
    } else {
      return items.count
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
    
    
    let groceryItem: GroceryItem
    if isFiltering() {
      groceryItem = filteredItems[indexPath.row]
    } else {
      groceryItem = items[indexPath.row]
    }
    
    cell.textLabel?.text = groceryItem.name
    cell.detailTextLabel?.text = groceryItem.addedByUser
    
    toggleCellCheckbox(cell, isCompleted: groceryItem.completed)
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      //items.remove(at: indexPath.row)
      //tableView.reloadData()
      
      
//      Firebase follows a unidirectional data flow model, so the listener in viewDidLoad()
//      notifies the app of the latest value of the grocery list. A removal of an item triggers a value change.
//      The index path’s row is used to retrieve the corresponding grocery item.
//      Each GroceryItem has a Firebase reference property named ref, and calling removeValue()
//      on that reference causes the listener you defined in viewDidLoad() to fire.
//      The listener has a closure attached that reloads the table view using the latest data.
      
      
      let groceryItem = items[indexPath.row]
      groceryItem.ref?.removeValue()
      
    }
  }
  
//  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    guard let cell = tableView.cellForRow(at: indexPath) else { return }
//    var groceryItem = items[indexPath.row]
//    let toggledCompletion = !groceryItem.completed
//
//    toggleCellCheckbox(cell, isCompleted: toggledCompletion)
//    groceryItem.completed = toggledCompletion
//    tableView.reloadData()
//  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // 1 Find the cell the user tapped using cellForRow(at:).
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    
    // 2 Get the corresponding GroceryItem by using the index path’s row.
    let groceryItem = items[indexPath.row]
    
    // 3 Negate completed on the grocery item to toggle the status.
    let toggledCompletion = !groceryItem.completed
    
    // 4 Call toggleCellCheckbox(_:isCompleted:) to update the visual properties of the cell.
    toggleCellCheckbox(cell, isCompleted: toggledCompletion)
    
    // 5 Use updateChildValues(_:), passing a dictionary, to update Firebase.
    // This method is different than setValue(_:) because it only applies updates, whereas setValue(_:)
    // is destructive and replaces the entire value at that reference.
    groceryItem.ref?.updateChildValues([
      "completed": toggledCompletion
      ])
  }
  
  func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
    if !isCompleted {
      cell.accessoryType = .none
      cell.textLabel?.textColor = UIColor.black
      cell.detailTextLabel?.textColor = UIColor.black
    } else {
      cell.accessoryType = .checkmark
      cell.textLabel?.textColor = UIColor.gray
      cell.detailTextLabel?.textColor = UIColor.gray
    }
  }
  
  // MARK: Add Item
  
  @IBAction func addButtonDidTouch(_ sender: AnyObject) {
    let alert = UIAlertController(title: "Grocery Item",
                                  message: "Add an Item",
                                  preferredStyle: .alert)
    
//    let saveAction = UIAlertAction(title: "Save",
//                                   style: .default) { action in
//      let textField = alert.textFields![0]
//      let groceryItem = GroceryItem(name: textField.text!,
//                                    addedByUser: self.user.email,
//                                    completed: false)
//      self.items.append(groceryItem)
//      self.tableView.reloadData()
//    }

    let saveAction = UIAlertAction(title: "Save",
                                   style: .default) { _ in
                      // 1 Get the text field (and its text) from the alert controller.
                              guard let textField = alert.textFields?.first,
                              let text = textField.text else { return }
                                    
                      // 2 Using the current user’s data, create a new GroceryItem that is not completed by default.
                                    let groceryItem = GroceryItem(name: text,
                                                                  addedByUser: self.user.email,
                                                                  completed: false)
                      // 3 Create a child reference using child(_:). The key value of this reference is the item’s name in lowercase, so when users add duplicate items (even if they capitalize it, or use mixed case) the database saves only the latest entry.
                                    let groceryItemRef = self.ref.child(text.lowercased())
                                    
                      // 4 Use setValue(_:) to save data to the database. This method expects a Dictionary. GroceryItem has a helper function called toAnyObject() to turn it into a Dictionary.
                                    groceryItemRef.setValue(groceryItem.toAnyObject())
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .default)
    
    alert.addTextField()
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
  }
  
  @objc func userCountButtonDidTouch() {
    performSegue(withIdentifier: listToUsers, sender: nil)
  }
  
}

extension GroceryListTableViewController: UISearchBarDelegate {
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    print("Cancel button clicked...")
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    print("Text Begin Editing...")
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    print("Text End Editing...")
  }
  
}

extension GroceryListTableViewController: UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    
    filterContentForSearchText(searchController.searchBar.text!)
    
  }
}

