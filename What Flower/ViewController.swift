//
//  ViewController.swift
//  What Flower
//
//  Created by Luis M Gonzalez on 8/28/18.
//  Copyright © 2018 Luis M Gonzalez. All rights reserved.
//

import UIKit
import Vision
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - API Constants
    
    let wikipediaAPIUrl = "https://en.wikipedia.org/w/api.php"
    
    // MARK: - Other Properties
    
    let imagePicker = UIImagePickerController()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var pickedImageView: UIImageView!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImagePicker()
    }
    
    // MARK: - IBActions
    
    @IBAction func takePicture(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - Image Picker Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            pickedImageView.image = userPickedImage
            
            guard let ciUserPickedImage = CIImage(image: userPickedImage) else {
                fatalError("Error converting userPickedImage into a CIImage")
            }
            
            detect(image: ciUserPickedImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
    }
    
    // MARK: - MLModel Methods
    
    func detect(image: CIImage) {
        guard let flowerClassifierModel = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Error loading CoreML model")
        }
        
        let request = VNCoreMLRequest(model: flowerClassifierModel) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            if let classification = results.first?.identifier {
                self.title = classification.capitalized
                self.getWikipediaData(flowerName: classification)
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    // MARK: Networking
    
    func getWikipediaData(flowerName: String) {
        
        let requestParameters = ["format": "json",
                                 "action": "query",
                                 "prop": "extracts",
                                 "exintro": "",
                                 "explaintext" : "",
                                 "titles": flowerName,
                                 "indexpageids": "",
                                 "redirects": "1"]
        
        Alamofire.request(wikipediaAPIUrl, method: .get, parameters: requestParameters).responseJSON { (response) in
            if response.result.isSuccess {
                print("Success! Got the wikipedia data")
                let wikipediaJSON: JSON = JSON(response.result.value!)
                print(wikipediaJSON)
            } else {
                print("\nERROR: \(response.result.error ?? "retrieving data from servers" as! Error)")
            }
        }
        
    }
    
    
    
}

