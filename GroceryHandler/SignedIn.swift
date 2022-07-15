//
//  SignedIn.swift
//  GroceryHandler
//
//  Created by Victor Micha on 6/22/22.
//

import SwiftUI

struct SignedIn: View {
    @State var userName:String
    @State var items = [Item]()
    //  @State private var prices = Set<Double>()
    @State private var users = Set<String>()
    @State private var user: String = ""
    //@State private var payer:String = ""
    @State private var price: String = ""
    @State private var errMsg = ""
    @State private var errColor = Color.red
    @State private var orderSummary = ""
    @State private var orderStr = ""
    @State private var pastOrders = false
    @State private var pictureReceipt = false
    var body: some View {
        //Text("In Signed In VIEW \(userName)")
        // NavigationView{
        
        VStack{
            
            Text("Hello, \(userName)")
                .font(.title)
                //.foregroundColor(Color.green)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0, green: 0, blue: 0.5))
                //.padding(.top, 10)
            
           // Form{
            VStack{
                HStack{
                    Spacer()
                    Text(errMsg)
                        //.padding(.all, 5)
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .foregroundColor(errColor)
                        .frame(width:280, height:40)
                    Spacer()
                }
                .frame(height:50)
                HStack{
                    TextField("Enter user:", text:$user)
                        .textFieldStyle(CustomTextField())
                    Button("Add User"){
                        if (user.count==0){
                            //errorMessage = "Username and password cannot be empty"
                            errColor = Color.red
                            errMsg = "user cannot be empty"
                            return
                        }
                        //CHECK THAT USER IS A VALID USER NAME AND THAT IT HAS NOT ALREADY BEEN ENTERER IN USERS  TO SET
                        // ADD IT TO USERS SET
                        if (getUserInfoForUserName(userName: user).count==0){
                            errColor = Color.red
                            errMsg = "no account found for: \(user)"
                            return
                        }
                        if (users.contains(user)){
                            errColor = Color.red
                            errMsg = "\(user) already added"
                            return
                        }
                        users.insert(user)
                        errColor = Color.green
                        errMsg = "\(user) added to users"
                    }//.padding(.all, 10)
                    .multilineTextAlignment(.center)
                    .padding(.all,5)
                    .buttonStyle(CustomButton(color:Color(red: 0, green: 0, blue: 0.5)))
                }
                HStack{
                    TextField("Enter price:", text:$price)
                        .textFieldStyle(CustomTextField())
                    Button("Add Item"){
                        if (price.count==0){
                            //errorMessage = "Username and password cannot be empty"
                            errColor = Color.red
                            errMsg = "Price is empty!"
                            return
                        }
                        if (users.count==0){
                            errColor = Color.red
                            errMsg = "Num users = 0"
                            return
                        }
                        //if price is valid double
                        var pr = 0.00//2 decimal places
                        if var p = Double(price) {
                            //errMsg = "The user entered a value pr ice of \(p)"
                            p = Double(round(100*p)/100)//round to 2 decimal spots
                            pr = p
                        } else {
                            errColor = Color.red
                            errMsg = "Not a valid number: \(price)"
                            return
                        }
                        let us = Array(users)
                        items.append(Item(price: pr, users: us))
                        errColor = Color.green
                        errMsg = "Added: \(users.count) users and price: \(pr)"
                        var temp = "Current Order:\n"
                        for item in items {
                            temp += "Price: \(item.price). Users: "
                            for user in item.users {
                                temp += "\(user) "
                            }
                            temp+="\n"
                            
                       }
                        orderStr = temp
                        if !(orderSummary.isEmpty){
                            orderSummary = ""
                            //to clear orderSummary if multiple orders are manually inputed and POSTED in a row
                        }
                        user = ""
                        price = ""
                        users.removeAll()
                    }//.padding(.all, 10)
                    .multilineTextAlignment(.center)
                    .padding(.all,5)
                    .buttonStyle(CustomButton(color:Color(red: 0, green: 0, blue: 0.5)))
                }
                
                HStack{
                    Spacer()
                    Button("Take picture of receipt instead"){
                        //GO TO NEW VIEW WHERE TAKING PICTURE WITH CAMERA AND ML IS DONE to get prices
                        //WILL ALSO HAVE TO ASK USER WHO USED WHAT PRODUCT to get users
                        //then post order/compute
                        //  errMsg = "Coming soon!"
                        pictureReceipt = true
                    }
                    .multilineTextAlignment(.center)
                    .padding(.all,5)
                    .buttonStyle(CustomButton(color:Color(red: 0.7, green: 0.2, blue: 0.2)))
                    Spacer()
                }.frame(height:60)
            }
          //  }
           // .frame(height: 350)
            .padding(.bottom, 10)
            
           
            Button("See past orders"){
                pastOrders = true
            }
            //.padding(.all, 10)
            //.frame(height: 20)
            .multilineTextAlignment(.center)
            .padding(.all,5)
            .buttonStyle(CustomButton(color:Color(red: 0, green: 0, blue: 0.5)))
            ScrollView{
                Text("\n\n\(orderStr)")
                // .padding(.all, 5)
                    .multilineTextAlignment(.center)
                Text(orderSummary)
                // .padding(.all, 5)
                    .multilineTextAlignment(.center)
                // .frame(width:320, height:150)
                //.lineLimit(30)
            }
            .background(Color(red: 0.3, green: 0.6, blue: 0.8))//automatically appears/disapears
            .cornerRadius(15)
            .frame(width:300, height: 200)
            .font(.callout)
            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.9))
            Button("Post order and view summary"){
                if (items.isEmpty){
                    errColor = Color.red
                    errMsg = "No items were added."//An order must have at least 1 item"
                    orderSummary = ""
                    orderStr = ""
                    return
                }
                dateFormatter.dateFormat = "M/d/y, HH:mm:ss"//"YY/MM/dd"
                let date = Date()
                let order = Order(userName: userName, receipt: items, paid: false, time:dateFormatter.string(from:date))
                
               // let order = Order(userName: userName, receipt: items, paid: false, time: Date().formatted())
                //Date().formatted() : 6/27/2022, 1:44 PM
                postRequest(order: order)
                errColor = Color.green
                errMsg = "Order posted to db"
                user = ""
                price = ""
                items.removeAll()
                users.removeAll()
                orderSummary = computeAmoundOwed(order: order)
                orderStr = getOrderAsString(order: order)
                
            }//.padding(.all, 10)
            .multilineTextAlignment(.center)
            .padding(.top,5)
            .buttonStyle(CustomButton(color:Color(red: 0, green: 0.4, blue: 0.5)))
            Button("Clear all entries"){
                user = ""
                //payer = ""
                price = ""
                items.removeAll()
                users.removeAll()
                errMsg = ""
                orderSummary = ""
                orderStr = ""
            }
            .foregroundColor(Color.gray)
            .padding(.bottom, 5)
            NavigationLink(destination: PictureReceipt(userName:userName), isActive: $pictureReceipt){EmptyView()}
            NavigationLink(destination: PastOrders(userName:userName), isActive: $pastOrders){EmptyView()}
        }
        .background(Color(red: 0.67, green: 0.87, blue: 0.9))
    }
}

struct SignedIn_Previews: PreviewProvider {
    static var previews: some View {
        SignedIn(userName:"userName")
    }
}
