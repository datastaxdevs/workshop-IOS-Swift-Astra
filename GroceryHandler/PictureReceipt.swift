//
//  PictureReceipt.swift
//  GroceryHandler
//
//  Created by Victor Micha on 6/27/22.
//

import SwiftUI

//some code for this view is taken/copied from https://designcode.io/swiftui-advanced-handbook-imagepicker
struct PictureReceipt: View {
    @State var userName:String
    @State private var image = UIImage()
    @State private var library = false
    @State private var camera = false
    @State private var gotPrices = false
    @State private var prices = [Double]()
    //@ObservedObject var pricesManager1:PricesManager = pricesManager
    var body: some View {
        VStack {
            Text("Hey, \(userName)")
                .font(.title)
                .foregroundColor(Color(red: 0, green: 0, blue: 0.5))
                .multilineTextAlignment(.center)
            Button("Choose photo from library"){
                library = true
            }
            .multilineTextAlignment(.center)
            .padding(.all,5)
            .buttonStyle(CustomButton(color:Color(red: 0, green: 0, blue: 0.5)))
            Image(uiImage: self.image)
                .resizable()
                .cornerRadius(50)
                .frame(width: 300, height: 400)
                .background(Color.black.opacity(0.2))
                .aspectRatio(contentMode: .fill)
            Button("Take photo"){
                camera = true
            }
            .multilineTextAlignment(.center)
            .padding(.all,5)
            .buttonStyle(CustomButton(color:Color(red: 0, green: 0, blue: 0.5)))
            NavigationLink(destination: FinalizePrices(userName:userName, prices: prices), isActive: $gotPrices){EmptyView()}
            Button("Get Prices from photo"){
                if (image.cgImage==nil){
                    print("Image can't be null")
                    return
                }
                //ML HAPPENS HERE
                Task{
                    prices = try await getPricesAsArray(image: image)
                    gotPrices = true
                }
            }
            .buttonStyle(CustomButton(color: Color(red: 0.6, green: 0.1, blue: 0.1)))
            .padding(.top, 20)
        }
        .frame(width: 350, height: 750)
        .padding(.horizontal, 20)
        .background(Color(red: 0.67, green: 0.87, blue: 0.9))
        .sheet(isPresented: $camera){
            ImagePicker(sourceType: .camera, selectedImage: self.$image)
        }
        .sheet(isPresented: $library) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
        }
    }
}

struct PictureReceipt_Previews: PreviewProvider {
    static var previews: some View {
        PictureReceipt(userName:"testUserName")
    }
}
