//
//  AddUsers.swift
//  GroceryHandler
//
//  Created by Victor Micha on 7/14/22.
//

import SwiftUI

struct AddUsers: View {
    @State var userName:String
    @State var prices:[Double]
    @State private var i = 0
    @State private var items = [Item]()
    @State private var users = [String]()
    @State private var user:String = ""
    @State private var errMsg = ""
    @State private var errMsgColor = Color.red
    @State private var postOrder = false
    @State private var currentOrder = ""
    @State private var currentPrice = ""
    @State private var orderPosted = false
    var body: some View {
        VStack{
            Button("Home"){
                goToSignedIn.userName = userName
                NavigationUtil.popToRootView()
                //goes back to ContentView
                //then to SignedIn
            }
            .buttonStyle(CustomButton(color: Color(red: 0.2, green:0.3 , blue: 0.4)))
            ScrollView{
                if (i==0){
                    Text("Current Order:")
                    Text("Username = \(userName)")
                    ForEach(0 ..< prices.count, id: \.self) { value in
                        Text(String(format: "Price: %.2f Users: ?", prices[value]))
                    }
                } else {
                    Text(currentOrder)
                        .multilineTextAlignment(.center)
                }
            }
            .background(Color(red: 0.3, green: 0.6, blue: 0.8))
            .cornerRadius(5)
            .frame(height: 200)
            .font(.callout)
            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.9))
            .padding(.top, 5)
            Button("Post Order"){
                Task{
                    if (i<prices.count){
                        errMsg = "Can't post order yet. Missing users for \(prices.count-i) price(s)!"
                        errMsgColor = Color.red
                        return
                    }
                    if (orderPosted){
                        errMsg = "Order already posted!"
                        errMsgColor = Color.green
                        return
                    }
                    //post order and view summary
                    dateFormatter.dateFormat = "M/d/y, HH:mm:ss"
                    let date = Date()
                    let order = Order(userName: userName, receipt: items, paid: false, time:dateFormatter.string(from:date))
                    print(try await postRequest(order: order))
                    errMsgColor = Color.green
                    errMsg = "Order posted to db."
                    user = ""
                    items.removeAll()
                    currentOrder = "\(computeAmoundOwed(order: order))\n-----------------------\n\n\(getOrderAsString(order: order))"
                    orderPosted = true
                }
            }
            .padding(.all,15)
            .buttonStyle(CustomButton(color:Color(red: 0.3, green: 0.7, blue: 0.4)))
            Spacer()
            HStack{
                if (i<prices.count){
                    Text(String(format: "Current price: %.2f", prices[i]))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.9))
                } else {
                    Text("No more prices!")
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.9))
                }
                Button("Next Price"){
                    if (orderPosted){
                        errMsg = "Order already posted!"
                        errMsgColor = Color.green
                        return
                    }
                    if (i==prices.count){
                        errMsg = "Order info is complete. Click on Post Order."
                        errMsgColor = Color.green
                        return
                    }
                    if (users.count==0){
                        errMsg = "List of users must have at least one user."
                        errMsgColor = Color.red
                        return
                    }
                    items.append(Item(price: prices[i], users: users))
                    users.removeAll()
                    //update currentOrder
                    var str = "Current Order:\nUserName = \(userName)\n"
                    for j in 0..<prices.count {
                        str += "Price: \(prices[j]) Users: "
                        if (j<=i){
                            for k in 0..<items[j].users.count {
                                str += "\(items[j].users[k]) "
                            }
                        }else{
                            str += "?"
                        }
                        str += "\n"
                    }
                    currentOrder = str
                    str.removeAll()
                    errMsg = "Users added to price \(prices[i]) successfully."
                    errMsgColor = Color.green
                    i = i+1
                    if (i==prices.count){
                        errMsg = "Order info is complete. Click on Post Order."
                        errMsgColor = Color.green
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.all,5)
                .buttonStyle(CustomButton(color:Color(red: 0.3, green: 0.2, blue: 0.4)))
            }
            Text(errMsg)
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(errMsgColor)
            TextField("Enter user:", text: $user)
                .textFieldStyle(CustomTextField())
            HStack{
                Button("Add User"){
                    Task{
                        if (orderPosted){
                            errMsg = "Order already posted!"
                            errMsgColor = Color.green
                            return
                        }
                        if (i==prices.count){return}
                        if (user.count==0){
                            errMsg = "User cannot be empty."
                            errMsgColor = Color.red
                            return
                        }
                        let (dict, noError) = try await getUserInfo(userName:user)
                        if (noError==true && dict.count==0){
                            //no user info -> no account
                            errMsgColor = Color.red
                            print("NOT HERE")
                            errMsg = "No account found for: \(user)."
                            return
                        }
                        let ind = users.firstIndex(of: user)
                        if (ind==nil){
                            users.append(user)
                            errMsgColor = Color.green
                            errMsg = "User \(user) added."
                        } else {
                            errMsgColor = Color.red
                            errMsg = "\(user) already in list."
                        }
                        user = ""
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.all,5)
                .buttonStyle(CustomButton(color:Color(red: 0, green: 0, blue: 0.2)))
                Button("Remove User"){
                    if (orderPosted){
                        errMsg = "Order already posted!"
                        errMsgColor = Color.green
                        return
                    }
                    if (i==prices.count){return}
                    if (user.count==0){
                        errMsg = "User cannot be empty."
                        errMsgColor = Color.red
                        return
                    }
                    Task{
                        let (dict, noError) = try await getUserInfo(userName:userName)
                        if (noError==false){
                            errMsgColor = Color.red
                            errMsg = "Error occured while fetching user info."
                            return
                        } else {
                            if (dict.count==0){
                                //no user info -> no account
                                errMsgColor = Color.red
                                errMsg = "No account found for: \(user)."
                                return
                            }
                        }
                    }
                    let ind = users.firstIndex(of: user)
                    if !(ind==nil){
                        users.remove(at: ind!)
                        errMsgColor = Color.green
                        errMsg = "User \(user) removed."
                    } else {
                        errMsgColor = Color.red
                        errMsg = "\(user) not in list."
                    }
                    user = ""
                }
                .multilineTextAlignment(.center)
                .padding(.all,5)
                .buttonStyle(CustomButton(color:Color(red: 0.5, green: 0, blue: 0)))
            }
        }
        .background(Color(red: 0.67, green: 0.87, blue: 0.9))
    }
}

struct AddUsers_Previews: PreviewProvider {
    static var previews: some View {
        AddUsers(userName: "testUserName", prices: [0.1, 2.4])
    }
}
