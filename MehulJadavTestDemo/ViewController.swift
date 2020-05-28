//
//  ViewController.swift
//  MehulJadavTestDemo
//
//  Created by Mehul Jadav on 28/05/20.
//  Copyright © 2020 mac. All rights reserved.
//

// name, number & userimage  

import UIKit
import Foundation
import ContactsUI
import SVProgressHUD
import CoreData
import AddressBook
import Contacts

class ViewController: UIViewController {

    @IBOutlet weak var IBuserTbl        : UITableView!
    @IBOutlet var lblTitle              : UILabel!
    @IBOutlet var txtSearchContact      : UITextField!
    @IBOutlet var searchImage           : UIImageView!
    @IBOutlet var btnSearchContact      : UIButton!
    
    let contactStore        = CNContactStore()
    var array_users         : [User] = []
    var objContacts         : [ContactResponseModel]    = []
    var objContactsFilter   : [ContactResponseModel]    = []
    var isSerching = false
    
    let contactNumberToAdd = 500
    let dt = UIImage(named: "ic_loginUser")!.jpegData(compressionQuality: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*if let isFirst = Preference.GetBool(key: UserDefaultsKey.IsFirstTime) as? Bool, isFirst == false {
            for i in 0..<contactNumberToAdd {
                self.createContact(index: i+1)
            }
        }*/
        
        self.IBuserTbl.tableFooterView = UIView()
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: self.txtSearchContact.frame.height))
        self.txtSearchContact.leftView = paddingView
        self.txtSearchContact.leftViewMode = UITextField.ViewMode.always
        
        if let isFirst = Preference.GetBool(key: UserDefaultsKey.IsFirstTime) as? Bool, isFirst == false {
            self.storeData()
        } else {
            self.manageContacts()
        }
        
    }

    func getMyContacts() {
        self.requestForAccess { (accessGranted) -> Void in      //Contact Access Permission Method
            if accessGranted {
                 let contacts = PhoneContacts.getContacts()
                print(contacts)
            }
        }
    }
}

//MARK:- IBAction Methods
extension ViewController {

    @IBAction func btnSearchTapepd(_ sender: UIButton) {
        self.hiddeShowSearchBar(isShow: !sender.isSelected)
    }
}

//MARK:- Other Methods
extension ViewController {
    
    func hiddeShowSearchBar(isShow : Bool = false) {
        
        self.btnSearchContact.isSelected    = isShow
        self.lblTitle.isHidden              = self.btnSearchContact.isSelected
        self.txtSearchContact.isHidden      = !self.btnSearchContact.isSelected
        self.searchImage.isHidden           = !self.btnSearchContact.isSelected
        
        if self.btnSearchContact.isSelected == false {
            self.txtSearchContact.resignFirstResponder()
            self.txtSearchContact.text = ""
            self.isSerching = false
            self.objContactsFilter.removeAll()
            self.IBuserTbl.reloadData()
        } else {
            self.txtSearchContact.becomeFirstResponder()
        }
    }

    func createContact(index : Int) {
        // Create a mutable object to add to the contact
        let contact = CNMutableContact()

        // Store the profile picture as data
        let image = UIImage(systemName: "ic_loginUser")
        contact.imageData = image?.jpegData(compressionQuality: 1.0)

        contact.givenName = "\(self.randomString(length: 5)) \(index)"
        contact.familyName = "\(self.randomString(length: 10)) \(index)"

        let homeEmail = CNLabeledValue(label: CNLabelHome, value: "john\(index)@example.com" as NSString)
        let workEmail = CNLabeledValue(label: CNLabelWork, value: "j\(index).appleseed@icloud.com" as NSString)
        contact.emailAddresses = [homeEmail, workEmail]

        contact.phoneNumbers = [CNLabeledValue(
            label: CNLabelPhoneNumberiPhone,
            value: CNPhoneNumber(stringValue: "(408) 555-012\(index)"))]

        let homeAddress = CNMutablePostalAddress()
        homeAddress.street = "One Apple Park Way"
        homeAddress.city = "Cupertino"
        homeAddress.state = "CA"
        homeAddress.postalCode = "9501\(index)"
        contact.postalAddresses = [CNLabeledValue(label: CNLabelHome, value: homeAddress)]

        var birthday = DateComponents()
        birthday.day = 1
        birthday.month = 4
        birthday.year = 1988  // (Optional) Omit the year value for a yearless birthday
        contact.birthday = birthday

        // Save the newly created contact
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)

        do {
            try store.execute(saveRequest)
        } catch {
            print("Saving contact failed, error: \(error)")
            // Handle the error
        }
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
 
 //MARK: TableView DataSource, Data Delegate Method and Cell Click Event
 extension ViewController : UITableViewDelegate, UITableViewDataSource {
     
     func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
         10
     }
     
     func numberOfSections(in tableView: UITableView) -> Int {
        //return self.objContacts.count
        return ((self.isSerching == true) ? self.objContactsFilter.count : self.objContacts.count)
         
     }
     
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (self.objContacts[section].key ?? "").capitalized
     }
     
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         //return self.objContacts[section].value?.count ?? 0
        return ((self.isSerching == true) ? self.objContactsFilter[section].value?.count ?? 0 : self.objContacts[section].value?.count ?? 0)
     }
     
     func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var strArr : [String] = []
        let contData = (self.isSerching == true) ? self.objContactsFilter : self.objContacts
         contData.forEach { (cont) in
             strArr.append(cont.key ?? "")
         }
         return strArr.map { $0.capitalized}
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let contactData = (self.isSerching == true) ? self.objContactsFilter[indexPath.section].value?[indexPath.row] : self.objContacts[indexPath.section].value?[indexPath.row]
                
             var cell:userCell? = tableView.dequeueReusableCell(withIdentifier: "userCell") as? userCell
             if (cell == nil) {
                 let nib: NSArray = Bundle.main.loadNibNamed("userCell", owner: self, options: nil)! as NSArray
                 cell = nib.object(at: 0) as? userCell
             }
             cell?.selectionStyle = .none
             cell?.userInfo = contactData
        
             return cell!
     }
 }
 
 //MARK:- Search Methods
 extension ViewController : UITextFieldDelegate {
     
     func textFieldDidBeginEditing(_ textField: UITextField) {
     }
     
     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         
         let currentString: NSString     = textField.text! as NSString
         let newString: NSString         = currentString.replacingCharacters(in: range, with: string) as NSString
         print(newString)
         self.searchText(searchText: newString as String)
         return true
     }
     //    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
     //        return true
     //    }
     
     func searchText(searchText : String) {
         
        if (searchText.isValid) {
            let list = self.objContacts.map{$0.copy()} as? [ContactResponseModel]
            isSerching = true
            self.objContactsFilter = list?.filter({ (objContact) -> Bool in
                let valueCont = objContact.value?.filter { ($0.name)?.range(of: searchText, options: [.diacriticInsensitive, .caseInsensitive]) != nil }
                objContact.value = valueCont
                return (objContact.value?.count ?? 0 > 0)
            }) ?? []
            self.IBuserTbl.reloadData()
        } else {
            isSerching = false
            self.IBuserTbl.reloadData()
        }
     }
     
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         _ = self.txtSearchContact.resignFirstResponder()
         self.searchText(searchText: textField.text!)
         return true
     }
     
 }


//MARK: - Strore Get Data
extension ViewController {
    
    func storeData() {
        SVProgressHUD.show()
        self.requestForAccess { (accessGranted) -> Void in      //Contact Access Permission Method
            if accessGranted {
                 
                let contacts = PhoneContacts.getContacts() // here calling the getContacts methods
                var contactArray    : [UserModel] = []
                
                contacts.forEach { (contact) in
                        
                    let userTmp : UserModel = UserModel()

                    contact.phoneNumbers.forEach { (ContctNumVar) in
                        if let fulMobNumVar  = ContctNumVar.value as? CNPhoneNumber, let countryCode = fulMobNumVar.value(forKey: "countryCode"), let MccNamVar = fulMobNumVar.value(forKey: "digits") as? String {
                            userTmp.number = MccNamVar
                        }
                    }
                    if contact.givenName != "" {
                        userTmp.name = ((contact.familyName.capitalizingFirstLetter() != "") ? ("\(contact.givenName.capitalizingFirstLetter()) \(contact.familyName.capitalizingFirstLetter())") : contact.givenName.capitalizingFirstLetter())//.capitalizingFirstLetter()
                    }
                    if let imgDt = contact.thumbnailImageData {
                        userTmp.image = imgDt
                    }
                    
                    if let name = userTmp.name, name != "", name.isValid {
                        contactArray.append(userTmp) //append contact in array model.
                    }
                }
                
                
                //store data inti core data
                contactArray.forEachEnumerated { (index, userInfo) in
                    if let no = userInfo.number, no.isValid {
                        self.storeUser(name: userInfo.name ?? "", number: userInfo.number ?? "", image: userInfo.image ?? self.dt!)
                    }
                }
                
                Preference.PutBool (key: UserDefaultsKey.IsFirstTime, value: true)
                self.getUsers()
                
            }
        }
        SVProgressHUD.dismiss()
        
    }
    
    func manageContacts() {
    
        SVProgressHUD.show()
        self.getUsers(isFirstTime: false)
        self.requestForAccess { (accessGranted) -> Void in      //Contact Access Permission Method
            if accessGranted {
                let contacts = PhoneContacts.getContacts()
                
                contacts.forEach { (contact) in
                        
                    let userTmp : UserModel = UserModel()
                    contact.phoneNumbers.forEach { (ContctNumVar) in
                        if let fulMobNumVar  = ContctNumVar.value as? CNPhoneNumber, let countryCode = fulMobNumVar.value(forKey: "countryCode"), let MccNamVar = fulMobNumVar.value(forKey: "digits") as? String {
                            userTmp.number = MccNamVar
                        }
                    }
                    if contact.givenName != "" {
                        userTmp.name = ((contact.familyName.capitalizingFirstLetter() != "") ? ("\(contact.givenName.capitalizingFirstLetter()) \(contact.familyName.capitalizingFirstLetter())") : contact.givenName.capitalizingFirstLetter())//.capitalizingFirstLetter()
                    }
                    if let imgDt = contact.thumbnailImageData {
                        userTmp.image = imgDt
                    }
                    var isNew = true
                    var usr : User = User()
                    self.array_users.forEachEnumerated { (ind, user) in
                        
                        if user.number == userTmp.number {
                            isNew = false
                            usr = user
                        }
                    }
                    
                    if isNew == true {
                        if let no = userTmp.number, no.isValid {
                            self.storeUser(name: userTmp.name ?? "", number: userTmp.number ?? "", image: userTmp.image ?? self.dt!)
                            return
                        }
                    } else {
                        if let no = userTmp.number, no.isValid {
                            self.updateUser(name: userTmp.name ?? "", number: userTmp.number ?? "", image: userTmp.image ?? self.dt!, user: usr)
                            return
                        }
                    }
                }
            }
        }
        SVProgressHUD.dismiss()
        self.IBuserTbl.reloadData()
    }
    
}


//MARK: - Contact Delegate Methods
extension ViewController {
    
    func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined, .restricted:
            self.contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access)
                } else {
                    var displayName: String? {
                        return Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String
                    }
                    if authorizationStatus == CNAuthorizationStatus.denied {
                        let alertVC = UIAlertController(title: displayName, message: "Allow app to access your contacts through settings.", preferredStyle: .alert)
                        alertVC.addAction(UIAlertAction(title: "Settings", style: .default)
                        { value in
                            
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                    print("Settings opened: \(success)") // Prints true
                                })
                            }
                        })
                        alertVC.addAction(UIAlertAction(title: "Cancel", style: .destructive , handler: nil))
                        self.present(alertVC, animated: true, completion: nil)
                    }
                    completionHandler(false)
                }
            })
        default:
            completionHandler(false)
        }
    }
}

enum ContactsFilter {
    case none
    case mail
    case message
}
class PhoneContacts {

    class func getContacts(filter: ContactsFilter = .none) -> [CNContact] { //  ContactsFilter is Enum find it below

        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactThumbnailImageDataKey] as [Any]

        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        var results: [CNContact] = []
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching containers")
            }
        }
        return results
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}

//MARK: - Core data

extension ViewController {
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    
    func storeUser (name: String, number: String, image: Data) {
        let context = getContext()
        
        //retrieve the entity that we just created
        let entity =  NSEntityDescription.entity(forEntityName: "User", in: context)
        let user = NSManagedObject(entity: entity!, insertInto: context)
        
        //set the entity values
        user.setValue(name, forKey: "name")
        user.setValue(number, forKey: "number")
        user.setValue(image, forKey: "image")
        
        //save the object
        do {
            try context.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
    }
    
    func updateUser (name:String, number:String, image : Data, user : User) {
        
        let context = getContext()
        //let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            //let array_users = try getContext().fetch(fetchRequest)
            //let user = array_users[0]
            
            user.setValue(name, forKey: "name")
            user.setValue(number, forKey: "number")
            user.setValue(image, forKey: "image")
            
            //save the context
            do {
                try context.save()
                print("updated!")
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
            }
            
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    func getUsers (isFirstTime : Bool = true) {
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        var responseArr     : [ContactResponseModel] = []
        
        do {
            //go get the results
            
            //let array_users = try getContext().fetch(fetchRequest)
            self.array_users = try getContext().fetch(fetchRequest)
            
            //I like to check the size of the returned results!
            print ("num of users = \(array_users.count)")
            
            //array_users[0].value(forKey: "email")
            //You need to convert to NSManagedObject to use 'for' loops
            for user in array_users as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                print("\(user.value(forKey: "name"))")
            }
            
            //data into section
            if self.array_users.count > 0 {
                let dictionary = Dictionary(grouping: self.array_users, by: { ($0.name ?? " ").first! })
                dictionary.forEach { (cont) in
                    let respTmp : ContactResponseModel = ContactResponseModel()
                    respTmp.key = cont.key.string
                    respTmp.value = cont.value
                    
                    responseArr.append(respTmp)
                }
                self.objContacts =  responseArr.sorted { ($0.key ?? "").lowercased() < ($1.key ?? "").lowercased() } // here array has all contact numbers.
            } else {
                self.objContacts = responseArr
            }
            if isFirstTime == true {
                
                DispatchQueue.main.async {
                    self.IBuserTbl.reloadData()
                }
            }
            
        } catch {
            print("Error with request: \(error)")
        }
    }
}
