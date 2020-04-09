//
//  prove.swift
//  ProveYourWorthDennis
//
//  Created by Dennis Mostajo on 4/6/20.
//  Copyright © 2020 Dennis Mostajo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSoup
import SwiftyJSON
import WebKit

class prove: UIViewController {
    
    @IBOutlet var webView: WKWebView!
    @IBOutlet var imageView: UIImageView!
    var globalPHPSESSID:String = ""
    static let policy = ServerTrustPolicy.pinCertificates(certificates: ServerTrustPolicy.certificates(), validateCertificateChain: true, validateHost: true)
    static let serverTrustPolicies: [String: ServerTrustPolicy] = [
        "proveyourworth.net": .disableEvaluation
    ]
    static let manager:SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.urlCredentialStorage = nil
        return SessionManager(configuration: configuration,serverTrustPolicyManager:ServerTrustPolicyManager(policies:serverTrustPolicies))
    }()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        debugPrint("path Documentary:\(self.getDocumentsDirectory())")
        prove.manager.request("http://www.proveyourworth.net/level3/start", method:.get).response
        { response in
//            debugPrint(String(data: response.data!, encoding: String.Encoding.utf8) as Any)
            if let jsonHeaders = response.response?.allHeaderFields
            {
                let headers = JSON(jsonHeaders)
//                debugPrint("headers:\(headers)")
                let setCookie = headers["Set-Cookie"].stringValue
                debugPrint("Set-Cookie:\(setCookie)")
                if let headerFields = response.response?.allHeaderFields as? [String: String], let URL = response.request?.url
                {
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: URL)
                    for cookie in cookies
                    {
                    //debugPrint(cookie)
                        let name = cookie.name
                        if name == "PHPSESSID"
                        {
                            let value = cookie.value
                            debugPrint("start PHPSESSID:\(value)")
                            self.globalPHPSESSID = value
                        }
                    }
                }
            }
            do {
                let html = String(data: response.data!, encoding: String.Encoding.utf8)?.replacingOccurrences(of: "hidden", with: "text")
                self.webView.loadHTMLString(html!, baseURL: nil)
                let doc: Document = try SwiftSoup.parse(html!)
//                debugPrint(doc)
                let sqlloginChildElement:Element = try (doc.body()?.getElementsByClass("sqllogin").first()?.children().first())!
//                debugPrint(sqlloginChildElement)
                let statefulhashElement:Element = (sqlloginChildElement.children().first()?.children().first())!
                debugPrint("Hacking name and hash:\(statefulhashElement)")
                let name = try statefulhashElement.attr("name")
                let hash = try statefulhashElement.attr("value")
                debugPrint("name:\(name)")
                debugPrint("hash:\(hash)")
                let parametersToActive: Parameters = [
                name: hash
                ]
                prove.manager.request("http://www.proveyourworth.net/level3/activate", method: .get, parameters: parametersToActive).response
                { response in
                    if let jsonHeaders = response.response?.allHeaderFields
                    {
                        let headers = JSON(jsonHeaders)
//                      debugPrint("headers:\(headers)")
                        let payloadUrl = headers["X-Payload-URL"].stringValue
                        debugPrint("X-Payload-URL:\(payloadUrl)")
                        if let headerFields = response.response?.allHeaderFields as? [String: String], let URL = response.request?.url
                        {
                            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: URL)
                            for cookie in cookies
                            {
//                              debugPrint(cookie)
                                let name = cookie.name
                                if name == "PHPSESSID"
                                {
                                    let value = cookie.value
                                    debugPrint("activate PHPSESSID:\(value)")
                                    self.globalPHPSESSID = value
                                }
                            }
                        }
                        prove.manager.request(payloadUrl, method: .get).response
                        { response in
                            if let data = response.data
                            {
                                self.imageView.image = self.textToImage(drawText: "Dennis Mostajo Maldonado\nHash:\(hash)\nmostygt@gmail.com\niOS & Android Developer", inImage: UIImage(data: data)!, atPoint: CGPoint(x:20,y:70))
                                self.saveImageOnDirectory(image: self.imageView.image!)
                                UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                                self.copyFileToDocumentsFolder(nameForFile: "resume", extForFile: "pdf")
                                self.saveAllCode()
                                 if let jsonHeaders = response.response?.allHeaderFields
                                {
                                    let headers = JSON(jsonHeaders)
                                    //  debugPrint("headers:\(headers)")
                                    let reaperUrl = headers["X-Post-Back-To"].stringValue
                                    debugPrint("X-Post-Back-To:\(reaperUrl)")
                                    let setCookie = headers["Set-Cookie"].stringValue
                                    debugPrint("Set-Cookie:\(setCookie)")
                                    if let headerFields = response.response?.allHeaderFields as? [String: String], let URL = response.request?.url
                                    {
                                        let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: URL)
                                        for cookie in cookies
                                        {
//                                          debugPrint(cookie)
                                            let name = cookie.name
                                            if name == "PHPSESSID"
                                            {
                                                let value = cookie.value
                                                debugPrint("payload PHPSESSID:\(value)")
                                                self.globalPHPSESSID = value
                                            }
                                        }
                                    }
//                                    let parametersToProvide: Parameters = ["email": "mostygt@gmail.com",
//                                                                           "name": "Dennis Mostajo Maldonado"]
                                    let postHeaders: HTTPHeaders = ["Content-type": "multipart/form-data; application/pdf; image.jpg; text/plain; application/swift"]
//                                    let postHeaders: HTTPHeaders = ["Content-type": "multipart/form-data",
//                                    "Cookie":self.globalPHPSESSID]
//                                    let payload: Parameters = [
//                                    "email": "mostygt@gmail.com",
//                                    "name": "Dennis Mostajo Maldonado",
//                                    "aboutme": "Special forces on iOS and Android development",
//                                    "code": "https://github.com/DennisMostajo/ProveYourWorthDennisLevel3/blob/master/ProveYourWorthDennis/ProveYourWorthDennis/code.py",
//                                    "resume": "https://www.linkedin.com/in/dennis-mostajo-maldonado-536b9a68",
//                                    "image": "https://github.com/DennisMostajo/ProveYourWorthDennisLevel3/blob/master/ProveYourWorthDennis/ProveYourWorthDennis/image.jpg"
//                                    ]
//                                    prove.manager.request(reaperUrl, method: .post, parameters: payload).response
//                                    { response in
//                                        debugPrint("response data:\(String(data: response.data!, encoding: String.Encoding.utf8) as Any)")
//                                    }
                                    
                                    prove.manager.upload(multipartFormData:
                                    {multipartFormData in
//                                        for (key, value) in parametersToProvide
//                                        {
//                                            multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
//                                        }
//                                        multipartFormData.append(self.getDocumentsDirectory().appendingPathComponent("image.jpg"), withName:"image")
//                                        multipartFormData.append(self.getDocumentsDirectory().appendingPathComponent("resume.pdf"), withName:"resume")
//                                        multipartFormData.append(self.getDocumentsDirectory().appendingPathComponent("code.swift"), withName:"code")
                                        multipartFormData.append(self.getDocumentsDirectory().appendingPathComponent("image.jpg"), withName:"image", fileName:"image.jpg", mimeType: "image/jpeg")
                                        multipartFormData.append(self.getDocumentsDirectory().appendingPathComponent("resume.pdf"), withName:"resume", fileName:"resume.pdf", mimeType: "application/pdf")
                                        multipartFormData.append(self.getDocumentsDirectory().appendingPathComponent("code.swift"), withName:"code", fileName:"code.swift", mimeType: "application/swift")
                                        multipartFormData.append("mostygt@gmail.com".data(using: String.Encoding.utf8)!,withName: "email")
                                        multipartFormData.append("Dennis Mostajo Maldonado".data(using: String.Encoding.utf8)!,withName: "name")
                                        multipartFormData.append("I'm an iOS & Android developer with extensive experience in building high quality mobile Apps".data(using: String.Encoding.utf8)!,withName: "aboutme")
//                                        multipartFormData.append("https://github.com/DennisMostajo/ProveYourWorthDennisLevel3/blob/master/ProveYourWorthDennis/ProveYourWorthDennis/code.py".data(using: String.Encoding.utf8)!,withName: "code" as String)
//                                        multipartFormData.append("https://www.linkedin.com/in/dennis-mostajo-maldonado-536b9a68".data(using: String.Encoding.utf8)!,withName: "resume" as String)
//                                        multipartFormData.append("https://github.com/DennisMostajo/ProveYourWorthDennisLevel3/blob/master/ProveYourWorthDennis/ProveYourWorthDennis/image.jpg".data(using: String.Encoding.utf8)!,withName: "image" as String)
                                    }, usingThreshold:UInt64.init(), to: reaperUrl, method: .post, headers: postHeaders, encodingCompletion:
                                    { (response) in
                                        debugPrint("upload response:\(response)")
                                        switch response
                                        {
                                            case .failure:
                                                debugPrint("fail")
                                            case .success(let upload, _, _):
                                            upload.responseJSON { response in
                                                debugPrint("response result value:\(String(describing: response.result.value))")
                                                debugPrint("responseJSON:\(response)")
                                                debugPrint("response data:\(String(data: response.data!, encoding: String.Encoding.utf8) as Any)")
                                            }
                                        }
                                    })
                                }
                            }
                        }
                    }

                }
                
            } catch Exception.Error(_, let message) {
                print(message)
            } catch {
                print("error")
            }
        }
    }
    
// MARK: - Custom Methods
    
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.green
        let textFont = UIFont(name: "Helvetica Bold", size: 12)!
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    //MARK: - Documents Directory Methods
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    func saveImageOnDirectory(image:UIImage)
    {
        if let data = image.jpegData(compressionQuality: 1.0)
        {
            let filename = self.getDocumentsDirectory().appendingPathComponent("image.jpg")
            try? data.write(to: filename)
        }
    }
    
    func copyFileToDocumentsFolder(nameForFile: String, extForFile: String) {

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let destURL = documentsURL!.appendingPathComponent(nameForFile).appendingPathExtension(extForFile)
        guard let sourceURL = Bundle.main.url(forResource: nameForFile, withExtension: extForFile)
            else {
                debugPrint("Source File \(nameForFile).\(extForFile) not found.")
                return
        }
            let fileManager = FileManager.default
            do {
                try fileManager.copyItem(at: sourceURL, to: destURL)
            } catch {
                debugPrint("Unable to copy file")
            }
    }
    
    func saveAllCode()
    {
        let str = "/* You were hacked Prove_Your_Worth by Dennis Mostajo :B */"
        let url = self.getDocumentsDirectory().appendingPathComponent("code.swift")
        do {
            try str.write(to: url, atomically: true, encoding: .utf8)
            let input = try String(contentsOf: url)
            debugPrint(input)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    

//MARK: - Save Image callback

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {

        if let error = error {
            print(error.localizedDescription)
        } else {
            print("Success")
        }
    }
}

extension Foundation.URLRequest {
    static func allowsAnyHTTPSCertificateForHost(_ host: String) -> Bool {
        return true
    }
}
