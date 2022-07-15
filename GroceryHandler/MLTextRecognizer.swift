//
//  MLTextRecognizer.swift
//  GroceryHandler
//
//  Created by Victor Micha on 6/27/22.
//

import Foundation
//import UIKit
import MLKitTextRecognition
import MLKitVision

//code for this file is taken/copied from https://developers.google.com/ml-kit/vision/text-recognition/ios


func getPricesAsArray(image:UIImage){
    var prices1 = [Double]()
    let textRecognizer = TextRecognizer.textRecognizer()
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation
    textRecognizer.process(visionImage) { result, error in
        guard error == nil, let result = result else {
            // Error handling
            print("Error getting text from picture")
            return
        }
        // Recognized text
        print("Text recognized")
        //let resultText = result.text
        var i = 0
        for block in result.blocks {
           // let blockText = block.text
            //  let blockLanguages = block.recognizedLanguages
            // let blockCornerPoints = block.cornerPoints
            // let blockFrame = block.frame
            //print("Block \(i): ")//\(blockText)")
            for line in block.lines {
                let lineText = line.text
                // let lineLanguages = line.recognizedLanguages
                // let lineCornerPoints = line.cornerPoints
                // let lineFrame = line.frame
                //print("LineText: \(lineText)")
                for element in line.elements {
                    let elementText = element.text
                    // let elementCornerPoints = element.cornerPoints
                    // let elementFrame = element.frame
                    if var cost = Double(elementText) {
                       // print("The user entered a value price of \(cost)")
                        if (cost>0.0 && cost<300.0){//reasonable price range is in between 0 and 300 (arbitrary)
                            cost =  Double(round(100*cost)/100)//round to 2 decimal spots
                            //print("ADDED TO PRICES: \(cost)")
                            prices1.append(cost)
                        }
                    } else {
                        //print("Not a valid number: \(elementText)")
                    }
                    //print("ElementText: \(elementText)")
                }
            }
            i+=1
        }
        print("Done going through whole text")
        //print("Printing prices:")
        //for x in prices1 {
        //    print(x)
        //}
       // print("PRICES NUMBER: \(prices1.count)")
        pricesManager.prices = prices1
        pricesManager.getPrices = true
        //print("Prices manager updated. Should switch to Add users view")
    }
    print("Done with get prices as array method")

}
