//
//  UserDefaults.swift
//  iOSProject
//
//

import Foundation

struct UserDefaultsKey {
    
    static let Name         = "Name"
    static let Number       = "Email"
    static let Image        = "Password"
    static let IsFirstTime  = "IsFirstTime"
}

class Preference {
    
    static let defaults = UserDefaults.standard
    
    static func PutInteger(key : String , value : Int? = 0){
        defaults.set(value, forKey: key)
    }
    
    static func GetInteger(key : String) -> Int? {
        if(isKeyNull(key: key) == true)
        {
            return 0
        }
        else
        {
            return defaults.integer(forKey: key)
        }
       
    }
    
    static func PutDouble(key : String , value : Double){
        defaults.set(value, forKey: key)
    }
    
    static func GetDouble(key : String) -> Double {
        if(isKeyNull(key: key) == true)
        {
            return 0
        }
        else
        {
            return defaults.double(forKey:key)
        }
        
    }
    
    static func PutString(key : String , value : String? = ""){
        defaults.set(value, forKey: key)
    }
    static func PutObject(key : String , value : String? = ""){
        defaults.set(value, forKey: key)
    }
    
    static func GetString(key : String) -> String? {
        if(isKeyNull(key: key) == true) {
            return ""
        } else {
            return defaults.string(forKey: key)!
        }
    }
    
    static func PutImage(key : String , value : String){
        defaults.set(value, forKey: key)}
    
    static func GetImage(key : String) -> String? {
        if(isKeyNull(key: key) == true) {
            return ""
        } else {
            return defaults.string(forKey: key)!
        }
    }
    
    static func PutBool(key : String , value : Bool) {
        defaults.set(value, forKey: key)
    }
    
    static func GetBool(key : String ) -> Bool {
        if(isKeyNull(key: key) == true) {
            return false
        } else {
           return defaults.bool(forKey: key)
        }
    }
    
    static func isKeyNull (key: String) -> Bool
    {
        if(defaults.object(forKey: key) != nil) {
            return false
        }
        return true
    }
    
    static func prefrenceClearAll(){
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
    }
    
    static func prefrenceClear() {
        Preference.PutString (key: UserDefaultsKey.Name, value: "")
        Preference.PutString (key: UserDefaultsKey.Number, value: "")
        Preference.PutString (key: UserDefaultsKey.Image, value: "")
        Preference.PutBool (key: UserDefaultsKey.IsFirstTime, value: false)
    }
}
