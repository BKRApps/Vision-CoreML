//
//  ViewController.swift
//  SimpleCoreMLExample
//
//  Created by Birapuram Kumar Reddy on 11/18/17.
//  Copyright © 2017 KRSimpleApps. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var selectedImage: UIImageView!

    @IBOutlet weak var coremlPredictionLabel: UILabel!
    @IBOutlet weak var visionClassificationLabel: UILabel!
    var cObservations :[VNClassificationObservation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }


    @IBAction func clickedOnCamera(_ sender: Any) {
        if (UIImagePickerController .isSourceTypeAvailable(.camera)){
            let showCameraVC = UIImagePickerController()
            showCameraVC.sourceType = .camera;
            showCameraVC.delegate = self;
            present(showCameraVC, animated: true, completion: {
                print("completed presenting the camera")
            })
        }
    }

    @IBAction func clieckOnGallery(_ sender: Any) {
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary)){
            let pickImageVC = UIImagePickerController()
            pickImageVC.delegate = self;
            pickImageVC.sourceType = .photoLibrary;
            present(pickImageVC, animated: true, completion: nil)
        }
    }

    @IBAction func viewClassificationResults(_ sender: Any) {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let cController = storyBoard.instantiateViewController(withIdentifier: "results") as! ClassificationViewController
        cController.classificationObservations = self.cObservations;
        self.show(cController, sender: self)
    }


}

extension ViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        if let newImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage.image = newImage
            if let pixelBuffer = newImage.pixelBuffer(width: 227, height: 227) {
                predictImageUsingSqueezenetModel(imageInPF: pixelBuffer)
                classifyImageUsingSqueezenetModel(imageInPF: pixelBuffer)
            }
        }
    }
}

//coreML
extension ViewController {
    func predictImageUsingSqueezenetModel(imageInPF:CVPixelBuffer) -> Void {
        let model = SqueezeNet()
        guard let squeezeOutput = try? model.prediction(image: imageInPF) else {
            fatalError("Unexpected runtime error.")
        }
        coremlPredictionLabel.text = "\(squeezeOutput.classLabel) Confidence : \(squeezeOutput.classLabelProbs[squeezeOutput.classLabel]!)";
//        print("sorted lables \(sortedClassLabelProbs)")
    }
}

extension ViewController {
    func classifyImageUsingSqueezenetModel(imageInPF:CVPixelBuffer) -> Void {
        performClassification(image: imageInPF)
    }

    func createClassificationRequest() -> VNCoreMLRequest? {
        do{
            let model = try VNCoreMLModel(for: SqueezeNet().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                if(error != nil){
                    //unable to process the request
                }else{
                    //get the data from the request.
                    DispatchQueue.main.async {
                        guard let results = request.results else {
                           // print("we haven't got enough results...\(error?.localizedDescription)")
                            return
                        }
                        let classifications = results as! [VNClassificationObservation];
                        self.visionClassificationLabel.text = "\(classifications[0].identifier)  Confidence : \(classifications[0].confidence)"
                        self.cObservations.removeAll()
                        self.cObservations.append(contentsOf: classifications)
                    }
                }
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        }catch(let error){
            fatalError(error.localizedDescription)
        }
    }

    func performClassification(image:CVPixelBuffer) {
        DispatchQueue.global(qos:.userInitiated).async { [weak self] in
            let handler = VNImageRequestHandler(cvPixelBuffer: image, orientation: CGImagePropertyOrientation.up, options: [:])
            do{
                if let request = self?.createClassificationRequest() {
                    try handler.perform([request])
                }
            }catch{
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
}


extension UIImage {
    /**
     Resizes the image to width x height and converts it to an RGB CVPixelBuffer.
     */
    public func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        return pixelBuffer(width: width, height: height,
                           pixelFormatType: kCVPixelFormatType_32ARGB,
                           colorSpace: CGColorSpaceCreateDeviceRGB(),
                           alphaInfo: .noneSkipFirst)
    }

    /**
     Resizes the image to width x height and converts it to a grayscale CVPixelBuffer.
     */
    public func pixelBufferGray(width: Int, height: Int) -> CVPixelBuffer? {
        return pixelBuffer(width: width, height: height,
                           pixelFormatType: kCVPixelFormatType_OneComponent8,
                           colorSpace: CGColorSpaceCreateDeviceGray(),
                           alphaInfo: .none)
    }

    func pixelBuffer(width: Int, height: Int, pixelFormatType: OSType,
                     colorSpace: CGColorSpace, alphaInfo: CGImageAlphaInfo) -> CVPixelBuffer? {
        var maybePixelBuffer: CVPixelBuffer?
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue]
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         pixelFormatType,
                                         attrs as CFDictionary,
                                         &maybePixelBuffer)

        guard status == kCVReturnSuccess, let pixelBuffer = maybePixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)

        guard let context = CGContext(data: pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                                      space: colorSpace,
                                      bitmapInfo: alphaInfo.rawValue)
            else {
                return nil
        }

        UIGraphicsPushContext(context)
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1, y: -1)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()

        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        return pixelBuffer
    }
}
