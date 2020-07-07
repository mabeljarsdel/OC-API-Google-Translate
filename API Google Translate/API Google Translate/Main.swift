//
//  Main.swift
//  API Google Translate
//
//  Created by Fabien Dietrich on 06/07/2020.
//  Copyright © 2020 Fabien Dietrich. All rights reserved.
//

import Foundation

public var textToShow: String = ""
// ce que on récupère de l'API
struct TranslateResponse : Decodable {
    let text : String
}
class Translate {
    
    static var shared = Translate()
    private init() {}
    
    private var task: URLSessionDataTask?
    private var translateSession = URLSession(configuration: .default)
    
    init(translateSession: URLSession){
        self.translateSession = translateSession
    }
    
     private static let translateUrl = URL(string: "http://data.fixer.io/api/latest?access_key=bf34b73ea045d5497e74fe133b2846a2")!
    
    // Creation de la requete
    func getTranslation(callback : @escaping (Bool, TranslateResponse?) -> Void ){
        let request = Translate.createTranslateRequest()
        
        task?.cancel()
        task = translateSession.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    callback(false, nil)
                    return
                }
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    callback(false, nil)
                    return
                }

                guard (try? JSONDecoder().decode(TranslateResponse.self, from: data)) != nil
                    else{
                        callback(false,nil)
                        return
                }
                print("data : \(String(describing: data))")
                print("response \(String(describing: response))")
                print("error : \(String(describing: error))")
                              
                // réponse de l'API
                guard let responseJSON = try? JSONDecoder().decode(TranslateResponse.self, from: data) else{
                    callback(false,nil)
                    print("error")
                    return
                }
                              
                textToShow = responseJSON.text
                print(responseJSON.text)
                let translateResponse = TranslateResponse(text: responseJSON.text)
                callback(true,translateResponse)
                print(translateResponse)
                sendNotification(name: "updatePickerView")
                              
                print("data : \(String(describing: data))")
                print("response \(String(describing: response))")
                print("error : \(String(describing: error))")
                print(data)
            }
        }
    task?.resume()
    }
    
    private static func createTranslateRequest() -> URLRequest {
        var request = URLRequest(url: translateUrl)
        request.httpMethod = "Post"
        
        let body = "method=getTranslation&format=json&lang=en"
        request.httpBody = body.data(using: .utf8)

        return request
    }
    
}

/// Method created to simplify sending a notification
 func sendNotification(name: String) {
    let name = Notification.Name(rawValue: name)
    let notification = Notification(name: name)
    NotificationCenter.default.post(notification)
}
