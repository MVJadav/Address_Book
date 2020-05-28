//
//  UserModel.swift
//  MehulJadavTestDemo
//


import Foundation
import ObjectMapper

class UserModel: NSObject,Mappable {

    private let kname        = "name"
    private let knumber      = "number"
    private let kimage       = "image"

    var name        : String? = ""
    var number      : String? = ""
    var image       : Data?

    required override init() {
        
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        self.name       <- map[kname]
        self.number     <- map[knumber]
        self.image      <- map[kimage]

    }
}

public final class ContactResponseModel: NSObject, Mappable , NSCoding, NSCopying {
    
    // MARK: Declaration for string constants to be used to decode and also serialize.
    private struct SerializationKeys {
        static let key          = "key"
        static let value        = "value"
    }
    
    // MARK: Properties
    var key     : String? = ""
    var value   : [User]? = []
    
    public required override init() {
    }
    // MARK: ObjectMapper Initializers
    /// Map a JSON object to this class using ObjectMapper.
    ///
    /// - parameter map: A mapping from ObjectMapper.
    public required init?(map: Map){
    }
    
    /// Map a JSON object to this class using ObjectMapper.
    ///
    /// - parameter map: A mapping from ObjectMapper.
    public func mapping(map: Map) {
        self.key       <- map[SerializationKeys.key]
        self.value        <- map[SerializationKeys.value]
    }
    
    /// Generates description of the object in the form of a NSDictionary.
    ///
    /// - returns: A Key value pair containing all valid values in the object.
    public func dictionaryRepresentation() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let value = self.key { dictionary[SerializationKeys.key] = value }
        if let value = self.value { dictionary[SerializationKeys.value] = value }
        return dictionary
    }
    
    // MARK: NSCoding Protocol
    required public init(coder aDecoder: NSCoder) {
        self.key    = aDecoder.decodeObject(forKey: SerializationKeys.key) as? String
        self.value  = aDecoder.decodeObject(forKey: SerializationKeys.value) as? [User] ?? []
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.key, forKey: SerializationKeys.key)
        aCoder.encode(self.value, forKey: SerializationKeys.value)
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = ContactResponseModel()
        copy.key    = self.key
        copy.value  = self.value
        return copy
    }
    
}
