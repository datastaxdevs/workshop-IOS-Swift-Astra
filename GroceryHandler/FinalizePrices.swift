//
//  FinalizePrices.swift
//  GroceryHandler
//
//  Created by Victor Micha on 6/27/22.
//

import SwiftUI

struct FinalizePrices: View {
    //if the user is in this view, he has logged in and provided a picture of a receipt, which the ML function has taken and got an array of prices
    //this view is to finalize the list of prices in case ML wasnt 100% successful
    @State var userName:String
    @State var prices:[Double]
    @State private var price:String = ""
    @State private var errMsg = ""//"Error: Invalid input"
    @State private var errMsgColor = Color.red
    @State private var listFinalized = false
    var body: some View {
        VStack{
            ScrollView{
                Text("Number of prices = \(prices.count)")
                ForEach(0 ..< prices.count, id: \.self) { value in
                    Text(String(format: "%.2f", prices[value]))//.2f -> 2 decimal points`
                        .multilineTextAlignment(.center)
                }
            }
            .background(Color(red: 0.3, green: 0.6, blue: 0.8))
            .cornerRadius(5)
            .frame(height: 200)
            .font(.callout)
            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.9))
            .padding(.top, 25)
            NavigationLink(destination: AddUsers(userName: userName, prices: prices), isActive: $listFinalized){EmptyView()}
            Button("Next"){
                if (prices.count==0){
                    errMsg = "Number of prices has to be >= 1"
                    errMsgColor = Color.red
                    return
                }
                listFinalized = true
            }
            .padding(.all,15)
            .buttonStyle(CustomButton(color:Color(red: 0.3, green: 0.7, blue: 0.4)))
            Spacer()
            
            Text(errMsg)
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(errMsgColor)
            TextField("Enter price (rounded to 2 decimal places):", text: $price)
                .textFieldStyle(CustomTextField())
            HStack{
                Button("Add Price"){
                    if var newPrice = Double(price){
                        if (newPrice>0 && newPrice<300){
                            //newPrice has to be < 300 is arbitrary
                            //this is also the case in MLTextRecognizer
                            newPrice = Double(round(100*newPrice)/100)//round to 2 decimal spots
                            prices.append(newPrice)
                            errMsgColor = Color.green
                            errMsg = "Price \(newPrice) added"
                            price = ""
                            return
                        } else {
                            errMsgColor = Color.red
                            errMsg = "Price \(newPrice) not in valid range"
                            price = ""
                            return
                        }
                    }
                    errMsgColor = Color.red
                    errMsg = "Please input a valid price"
                    price = ""
                }
                .multilineTextAlignment(.center)
                .padding(.all,15)
                .buttonStyle(CustomButton(color:Color(red: 0, green: 0, blue: 0.2)))
                Button("Remove Price"){
                    if var newPrice = Double(price){
                        if (newPrice>0 && newPrice<300){
                            //newPrice has to be < 300 is arbitrary
                            //this is also the case in MLTextRecognizer
                           newPrice = Double(round(100*newPrice)/100) //round 2 decimals spots
                            let ind = prices.firstIndex(of: newPrice)
                            if !(ind==nil){
                                prices.remove(at: ind!)
                                //print("Price \(newPrice) removed")
                                errMsgColor = Color.green
                                errMsg = "Price \(newPrice) removed"
                            } else {
                                errMsgColor = Color.red
                                errMsg = "Price \(newPrice) not found in list"
                            }
                            price = ""
                            return
                        }
                        errMsgColor = Color.red
                        errMsg = "Price \(newPrice) not in valid range"
                        price = ""
                        return
                    }
                    errMsgColor = Color.red
                    errMsg = "Please input a valid price"
                    price = ""
                }
                .multilineTextAlignment(.center)
                .padding(.all,15)
                .buttonStyle(CustomButton(color:Color(red: 0.5, green: 0, blue: 0)))
            }
        }
        .background(Color(red: 0.67, green: 0.87, blue: 0.9))
   
    }
}

struct FinalizePrices_Previews: PreviewProvider {
    static var previews: some View {
        FinalizePrices(userName: "userName", prices: [1.0,2.0])
    }
}
