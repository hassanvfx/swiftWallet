//
//  Codable+JSON.swift
//  swytUI
//
//  Created by Mark Maxwell on 12/11/19.
//  Copyright © 2019 eonflux. All rights reserved.
//
import UIKit

enum UIKitExt: Error {
    case Encodable(mssg: String)
}

extension Encodable {
    func asJSONStringOrEmpty() -> String {
        let result = try? asJSONString()

        return result ?? ""
    }

    func asJSONString() throws -> String {
        let jsonEncoder = JSONEncoder()
        let data = try jsonEncoder.encode(self)
        guard let string = String(data: data, encoding: .utf8) else {
            throw UIKitExt.Encodable(mssg: "Failure building String out of data")
        }
        return string
    }

    func asJSONStringOptional() -> String? {
        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func asJSONData() throws -> Data {
        let jsonEncoder = JSONEncoder()
        return try jsonEncoder.encode(self)
    }

    func asJSONData() -> Data? {
        let jsonEncoder = JSONEncoder()
        let data = try? jsonEncoder.encode(self)
        return data
    }
}

extension Encodable {
    func asJSONObject() throws -> [String: Any] {
        let jsonString: String = try asJSONString()
        guard let data = jsonString.data(using: .utf8) else {
            throw UIKitExt.Encodable(mssg: "Failure converting Data into String")
        }
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let dictionary = jsonObject as? [String: Any] else {
            throw UIKitExt.Encodable(mssg: "Failure converting jsonObject to Dictionary")
        }
        return dictionary
    }

    func asJSONObject() -> [String: Any]? {
        do {
            guard let data = asJSONStringOptional()?.data(using: .utf8) else { return nil }
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]

        } catch let error as NSError {
            // Log.main.debug( error.localizedDescription)
        }

        return nil
    }
}

typealias JSONString = String

enum Codec {
    static func json<T: Codable>(from object: T) -> JSONString? {
        let jsonEncoder = JSONEncoder()
        do {
            let data = try jsonEncoder.encode(object)
            return String(data: data, encoding: .utf8)
        } catch {
            // Log.main.assert( error.localizedDescription)
        }
        return nil
    }

    static func object<T: Codable>(fromJSON json: JSONString) -> T? {
        let jsonDecoder = JSONDecoder()
        let data = json.data(using: .utf8)

        do {
            return try jsonDecoder.decode(T.self, from: data!)

        } catch {
            // Log.main.assert( error.localizedDescription)
        }
        return nil
    }

    static func object<T: Codable>(from data: Data) -> T? {
        let jsonDecoder = JSONDecoder()

        do {
            return try jsonDecoder.decode(T.self, from: data)

        } catch {
            // Log.main.assert( error.localizedDescription)
        }
        return nil
    }

    static func dictionary<T: Codable>(from object: T) -> [String: Any?] {
        let data = try! JSONEncoder().encode(object)
        let dictionary = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]

        return dictionary!
    }

    static func jsonObject(from string: JSONString) -> [String: Any] {
        do {
            let data = string.data(using: .utf8)!
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]

        } catch let error as NSError {
            // Log.main.debug(error.localizedDescription)
        }

        return [:]
    }

    static func json(fromJSONObject object: AnyObject) -> String? {
        do {
            let data1 = try JSONSerialization.data(withJSONObject: object, options: JSONSerialization.WritingOptions.prettyPrinted) // first of all convert json to the data
            return String(data: data1, encoding: String.Encoding.utf8) // the data will be converted to the string
        } catch let error as NSError {
            // Log.main.debug( error.localizedDescription)
        }

        return ""
    }
}
