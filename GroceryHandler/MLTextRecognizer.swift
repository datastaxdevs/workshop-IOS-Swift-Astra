//
//  MLTextRecognizer.swift
//  GroceryHandler
//
//  Created by Victor Micha on 6/27/22.
//
//some code for this file is taken/copied from https://developers.google.com/ml-kit/vision/text-recognition/ios
import MLKitTextRecognition
import MLKitVision

func getPricesAsArray(image:UIImage) async throws -> [Double]{
    print("in get prices as array function")
    var prices1 = [Double]()
    let textRecognizer = TextRecognizer.textRecognizer()
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation
    let result = try await textRecognizer.process(visionImage)
    //guard error == nil, let result = result else {
      //  print("Error getting text from picture")
       //return ([Double](), false)
    //}
    print("Text recognized async")
    //let resultText = result.text
    for block in result.blocks {
        //let blockText = block.text
        //let blockLanguages = block.recognizedLanguages
        //let blockCornerPoints = block.cornerPoints
        //let blockFrame = block.frame
        //print("Block \(i): ")//\(blockText)")
        for line in block.lines {
            //let lineText = line.text
            // let lineLanguages = line.recognizedLanguages
            // let lineCornerPoints = line.cornerPoints
            // let lineFrame = line.frame
            //print("LineText: \(lineText)")
            for element in line.elements {
                let elementText = element.text
                // let elementCornerPoints = element.cornerPoints
                // let elementFrame = element.frame
                if var cost = Double(elementText) {
                    if (cost>0.0 && cost<300.0){//reasonable price range is in between 0 and 300 (arbitrary)
                        cost =  Double(round(100*cost)/100)//round to 2 decimal places
                        //print("ADDED TO PRICES: \(cost)")
                        prices1.append(cost)
                    }
                } else {
                    //print("Not a valid number: \(elementText)")
                }
            }
        }
    }
    return prices1
    
    /*{ result, error in
        guard error == nil, let result = result else {
            print("Error getting text from picture")
            return
        }
        print("Text recognized")
        //let resultText = result.text
        for block in result.blocks {
            //let blockText = block.text
            //let blockLanguages = block.recognizedLanguages
            //let blockCornerPoints = block.cornerPoints
            //let blockFrame = block.frame
            //print("Block \(i): ")//\(blockText)")
            for line in block.lines {
                //let lineText = line.text
                // let lineLanguages = line.recognizedLanguages
                // let lineCornerPoints = line.cornerPoints
                // let lineFrame = line.frame
                //print("LineText: \(lineText)")
                for element in line.elements {
                    let elementText = element.text
                    // let elementCornerPoints = element.cornerPoints
                    // let elementFrame = element.frame
                    if var cost = Double(elementText) {
                        if (cost>0.0 && cost<300.0){//reasonable price range is in between 0 and 300 (arbitrary)
                            cost =  Double(round(100*cost)/100)//round to 2 decimal places
                            //print("ADDED TO PRICES: \(cost)")
                            prices1.append(cost)
                        }
                    } else {
                        //print("Not a valid number: \(elementText)")
                    }
                }
            }
        }
        print("Done going through whole text")
        //print("Printing prices:")
        //for x in prices1 {
        //    print(x)
        //}
        pricesManager.prices = prices1
        pricesManager.getPrices = true
        //print("Prices manager updated. Should switch to Finalize Prices view")
    }*/
}
