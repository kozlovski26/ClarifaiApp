//
//  ViewController.swift
//  ClarifaiApp
//
//  Created by Bar kozlovski on 29/05/2019.
//  Copyright © 2019 Bar kozlovski. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum ImageSource {
    case photoLibrary
    case camera
}

class ViewController: UIViewController , UINavigationControllerDelegate {
    

    //MARK: Varibels
    
    
   //Image
    
    @IBOutlet weak var genderImage: UIImageView!
    var base64Image:String = " "
    var imageToCheck = UIImage()
    var getImage:Bool = false
    
    let strokeTextAttributes = [
        NSAttributedString.Key.strokeColor : UIColor.blue,
        NSAttributedString.Key.foregroundColor : UIColor.red,
        NSAttributedString.Key.strokeWidth : -4.0,
        NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 30)]
        as [NSAttributedString.Key : Any]
    
 //Concepts classes
    
    var ageAppearance = [concepts]()
    var genderAppearance = [concepts]()

    
//Network URL and HTTPHeaders
    
    let networkInfo = Network()
    var imagePicker: UIImagePickerController!
    
    
    
    @IBOutlet weak var ageLbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    
   
    
    @IBAction func takeFromLibrary(_ sender: Any) {
        self.selectImageFrom(.photoLibrary)
    }
    
    @IBAction func takePhoto(_ sender: UIButton) {
        self.selectImageFrom(.camera)
        
    }
    

    
    func selectImageFrom(_ source: ImageSource){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
            
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }

    
    func GetDataFromCustomCamera(){
        
        if getImage == true {
            ImageView.image = imageToCheck
            getImageDetailsAndSend()
            getImage = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        cleanAll()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        GetDataFromCustomCamera()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Launch.png")!)
        self.title = "Main"
        cleanAll()
      
     
        }

   
    //Making outline here
    

    func getImageDetailsAndSend()
    {
     
        let imgBase64String = self.GetDataWithBase64(imageToConvert: imageToCheck)
        self.sendPostRequest(json: imgBase64String)
    }
    
    
    
    //Prepare all the Data with the base64 image before sending it
    
    func GetDataWithBase64(imageToConvert:UIImage) -> String {
       
        base64Image = ConvertImageToBase64String(img: imageToConvert)
        let imageObj = ImageObj(base64: base64Image)
        let dataObj = DataObj(image: imageObj)
        let inputObj = InputObj(data: dataObj)
        let inputsContainerObj = InputsContainerObj(inputs: [inputObj])
        
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(inputsContainerObj)
            
            return String(data: jsonData, encoding: .utf8)!
            
        } catch _ as NSError {
            
        }
        
        return ""
    }
    //Convert my image to base64
    
    func ConvertImageToBase64String (img: UIImage) -> String {
        return img.jpegData(compressionQuality: 0.8)?.base64EncodedString() ?? ""
    }
    
    
    
    //Sending Post request
    
    func sendPostRequest(json:String)
    {
        Alamofire.request(networkInfo.urlObj!, method: .post, parameters: self.convertToDictionary(text: json), encoding: JSONEncoding.default, headers: networkInfo.headers).responseJSON { response in
    
            let swiftyJsonVar = JSON(response.result.value!)
            print(swiftyJsonVar)
            self.jsonParsing(json: swiftyJsonVar)
        }
       
    }
    
    
    //String to Dictionary
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    
    //Parsing the JSON to array of age and gender
    
    func jsonParsing(json:JSON){
        
        let face = json["outputs"][0]["data"]["regions"][0]["data"]["face"]
        print(face)
        let gender = face["gender_appearance"]["concepts"]
        let age = face["age_appearance"]["concepts"]
        
        for obj in gender.arrayValue {
            
            let value = obj["value"].double
            let name =  obj["name"].string
            
            let consept = concepts(value: value!, name: name!)
            
            self.genderAppearance.append(consept)
        }
        
        for obj in age.arrayValue {
            
            let value = obj["value"].double
            let name =  obj["name"].string
            
            let consept = concepts(value: value!, name: name!)
            
            self.ageAppearance.append(consept)
        }
        self.getMaxPredictGenderAndAge()
    }
   
    

    //Filter by highest values
    
    func getMaxPredictGenderAndAge()  {
     
        if ageAppearance.isEmpty == false || genderAppearance.isEmpty == false{
           
            //self.ageLbl.text = ageAppearance[0].name
            ageLbl.attributedText = NSMutableAttributedString(string: ageAppearance[0].name, attributes: strokeTextAttributes)
            if genderAppearance[0].name == "masculine" {
                
                genderImage.image = UIImage(named: "Male")
                                 genderLbl.attributedText = NSMutableAttributedString(string: "Male", attributes: strokeTextAttributes)
            }
            else {
                
                genderImage.image = UIImage(named: "Female")
                 genderLbl.attributedText = NSMutableAttributedString(string: "Female", attributes: strokeTextAttributes)
                
            }
            
            //self.genderLbl.text = genderAppearance[0].name
            ageAppearance.removeAll()
            genderAppearance.removeAll()
            getImage = false
        } else {
            
            let alert = UIAlertController(title: "Please Choose new Image!", message: nil, preferredStyle: .alert)
           
    
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                
                self.cleanAll()
               
            }))
            self.present(alert, animated: true)
//            self.ageLbl.text = "invalid Picture"
//            self.genderLbl.text = "Please choose new one"
            
            
        }
       
    
    }
    
    func cleanAll(){
        
        ImageView.image = UIImage()
        ageLbl.text = " "
        genderLbl.text = " "
        genderImage.image = UIImage()
    }
    
}

extension ViewController: UIImagePickerControllerDelegate{
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        
        ImageView.image = selectedImage
        
        imageToCheck = ImageView.image!
    
        getImageDetailsAndSend()
}
    

}
extension UIImage {
    func imageWithBorder(width: CGFloat, color: UIColor) -> UIImage? {
        let square = CGSize(width: min(size.width, size.height) + width * 2, height: min(size.width, size.height) + width * 2)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = .center
        imageView.image = self
        imageView.layer.borderWidth = width
        imageView.layer.borderColor = color.cgColor
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    

    
}



