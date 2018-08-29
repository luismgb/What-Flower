//
//  ViewController.swift
//  What Flower
//
//  Created by Luis M Gonzalez on 8/28/18.
//  Copyright © 2018 Luis M Gonzalez. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var pickedImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImagePicker()
    }
    
    @IBAction func takePicture(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
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
    
    func detect(image: CIImage) {
        guard let flowerClassifierModel = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Error loading CoreML model")
        }
        
        let request = VNCoreMLRequest(model: flowerClassifierModel) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            let classification = results.first?.identifier
            self.title = classification?.capitalized
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
}

