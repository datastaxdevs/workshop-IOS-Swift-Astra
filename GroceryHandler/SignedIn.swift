//
//  SignedIn.swift
//  GroceryHandler
//
//  Created by Victor Micha on 6/22/22.
//

import SwiftUI

struct SignedIn: View {
    @State var userName:String
    @State private var items = [Item]()
    @State private var users = Set<String>()
    @State private var user: String = ""
    @State private var price: String = ""
    @State private var errMsg = ""
    @State private var errColor = Color.red
    @State private var orderSummary = ""
    @State private var orderStr = ""
    @State private var pastOrders = false
    @State private var pictureReceipt = false
    var body: some View {
        VStack{
            Text("Hello, \(userName)")
                .font(.title)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0, green: 0, blue: 0.5))
            VStack{
                HStack{
                    Spacer()
                    Text(errMsg)
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
                            errColor = Color.red
                            errMsg = "User cannot be empty."
                            return
                        }
                        //check that user has account and that is has not already been added to users. Then add it to users
                        if (getUserInfoForUserName(userName: user).count==0){
                            errColor = Color.red
                            errMsg = "No account found for: \(user)."
                            return
                        }
                        if (users.contains(user)){
                            errColor = Color.red
                            errMsg = "\(user) already added."
                            return
                        }
                        users.insert(user)
                        errColor = Color.green
                        errMsg = "\(user) added to users."
                    }
                    .multilineTextAlignment(.center)
                    .padding(.all,5)
                    .buttonStyle(CustomButton(color:Color(red: 0, green: 0, blue: 0.5)))
                }
                HStack{
                    TextField("Enter price:", text:$price)
                        .textFieldStyle(CustomTextField())
                    Button("Add Item"){
                        if (price.count==0){
                            errColor = Color.red
                            errMsg = "Price is empty!"
                            return
                        }
                        if (users.count==0){
                            errColor = Color.red
                            errMsg = "Number of users must be > 0!"
                            return
                        }
                        //check that price is a valid double
                        var pr = 0.0
                        if var p = Double(price) {
                            p = Double(round(100*p)/100)//round to 2 decimal places
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
                    }
                    .multilineTextAlignment(.center)
                    .padding(.all,5)
                    .buttonStyle(CustomButton(color:Color(red: 0, green: 0, blue: 0.5)))
                }
                HStack{
                    Spacer()
                    Button("Take picture of receipt instead"){
                        //go to new view where taking picture of receipt is done to get prices
                        pictureReceipt = true
                    }
                    .multilineTextAlignment(.center)
                    .padding(.all,5)
                    .buttonStyle(CustomButton(color:Color(red: 0.7, green: 0.2, blue: 0.2)))
                    Spacer()
                }.frame(height:60)
            }
            .padding(.bottom, 10)
            Button("See past orders"){
                pastOrders = true
            }
            .multilineTextAlignment(.center)
            .padding(.all,5)
            .buttonStyle(CustomButton(color:Color(red: 0, green: 0, blue: 0.5)))
            ScrollView{
                Text("\n\n\(orderStr)")
                    .multilineTextAlignment(.center)
                Text(orderSummary)
                    .multilineTextAlignment(.center)
            }
            .background(Color(red: 0.3, green: 0.6, blue: 0.8))//automatically appears/disapears depending on if Text is empty or not
            .cornerRadius(15)
            .frame(width:300, height: 200)
            .font(.callout)
            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.9))
            Button("Post order and view summary"){
                if (items.isEmpty){
                    errColor = Color.red
                    errMsg = "An order must have at least 1 item."
                    orderSummary = ""
                    orderStr = ""
                    return
                }
                dateFormatter.dateFormat = "M/d/y, HH:mm:ss"
                let date = Date()
                let order = Order(userName: userName, receipt: items, paid: false, time:dateFormatter.string(from:date))
                Task{
                try await postRequest(order: order)
                }
                errColor = Color.green
                errMsg = "Order posted to db."
                user = ""
                price = ""
                items.removeAll()
                users.removeAll()
                orderSummary = computeAmoundOwed(order: order)
                orderStr = getOrderAsString(order: order)
            }
            .multilineTextAlignment(.center)
            .padding(.top,5)
            .buttonStyle(CustomButton(color:Color(red: 0, green: 0.4, blue: 0.5)))
            Button("Clear all entries"){
                user = ""
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
        SignedIn(userName:"testUserName")
    }
}
