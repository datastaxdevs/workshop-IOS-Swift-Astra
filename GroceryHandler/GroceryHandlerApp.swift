
//
//  GroceryHandlerApp.swift
//  GroceryHandler
//
//  Created by Victor Micha on 6/13/22.
//

import SwiftUI

@main
struct GroceryHandlerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

//environment variables https://blog.eidinger.info/use-environment-variables-from-env-file-in-a-swift-package
public var ASTRA_DB_ID:String? {
    ProcessInfo.processInfo.environment["ASTRA_DB_ID"]
}
public var ASTRA_DB_REGION:String? {
    ProcessInfo.processInfo.environment["ASTRA_DB_REGION"]
}
public var ASTRA_DB_TOKEN:String? {
    ProcessInfo.processInfo.environment["ASTRA_DB_TOKEN"]
}

struct Order : Codable {
    let userName : String
    let receipt : [Item]
    var paid : Bool
    let time : String
}

struct Item : Codable {
    let price : Double
    let users : [String]
}

struct UserInfo : Codable {
    let userName : String
    let password : String
}

//structs used to PATCH -> change paid status or change password
struct Paid :Codable {
    var paid :Bool
}
struct Password: Codable{
    var password:String
}

//these vars are global because getRequest func has async call
var orders = [Order]()
var gotOrders = false
var localOrderDB = [String:Order]()

var gotUserInfo = false
var localUserInfoDB = [String:UserInfo]()

var pageState = ""//pageState is initialized as empty on purpose, see getAllOrdersForUserName

let dateFormatter = DateFormatter()

//usernames for random orders to populate the database
let userNames = ["Michael1", "Dwight1", "Jim1", "Pam1", "Angela1", "Kevin1",
             "Oscar1", "Phillys1", "Stanley1", "Andy1", "Toby1", "Kelly1",
             "Ryan1", "David1", "Gabe1", "Robert1", "Creed1", "Roy1", "Darryl1",
             "Jan1", "Holly1", "Mose1", "Joe1"]

//this struct is taken/copied from https://www.hackingwithswift.com/quick-start/swiftui/customizing-button-with-buttonstyle
struct CustomButton: ButtonStyle {
    let color:Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(color)
            .foregroundColor(.white)
            .clipShape(Capsule())
            .animation(.easeOut)
            //.transition(.move(edge: .trailing))
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .shadow(radius: configuration.isPressed ? 40 : 0)
    }
}

//this struct is taken/copied from https://www.fivestars.blog/articles/how-to-customize-textfields/
struct CustomTextField: TextFieldStyle {
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .foregroundColor(Color(red: 0, green: 0, blue: 0.4))
            .padding(10)
            .overlay(//https://stackoverflow.com/questions/67132408/i-have-trouble-using-cornerradius-and-borders-on-a-textfield-in-swiftui
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.blue, lineWidth: 2)
            )
            .padding()
      }
    
    
}

//to know average bytes of random order
func getAverageNumBytesOfDoc()->Int{
    let numNewOrders = 50//arbitrary
    var sum = 0
    for _ in 0..<numNewOrders{
        let order = getRandomOrder(userNames: Array(getRandomSetOfUserNames()))
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let uploadData = try? encoder.encode(order) else {
            break
            //could not convert to type data
        }
        print(uploadData)
        sum+=Int(uploadData.count)
        
    }
    //print("Average is \(sum/numNewOrders)")
    return sum/numNewOrders
}

func getRandomSetOfUserNames()->Set<String>{
    let numUserNames = Int.random(in: 2..<userNames.count/3)
    var setOfUserNames = Set<String>()
    for _ in 0..<numUserNames {
        var randInt = Int.random(in: 0..<userNames.count)
        while (setOfUserNames.contains(userNames[randInt])){
            randInt = Int.random(in: 0..<userNames.count)
        }
        setOfUserNames.insert(userNames[randInt])
    }
    return setOfUserNames
}

func getRandomOrder(userNames:[String])->Order{
    //userNames has length of at least 2
    //userNames shoudl be list of DISTINCT strings
    //one of these will be the user who pays
    dateFormatter.dateFormat = "M/d/y, HH:mm:ss"
    let payerNameIndex = Int.random(in: 0..<userNames.count)
    var receipt = [Item]()
    let numItems = Int.random(in: 2...15)//2...15 is arbitrary and small for testing, could make much bigger though
    for _ in 0..<numItems{
        let numUsers = Int.random(in: 1...userNames.count)
        var setOfIndices = Set<Int>()
        for _ in 0..<numUsers {
            //get a name from names randomly
            var index = Int.random(in: 0..<userNames.count)
            while (setOfIndices.contains(index)){
                index = Int.random(in: 0..<userNames.count)
                //to prevent repeat names
            }
            setOfIndices.insert(index)
        }
        var users = [String]()
        for i in setOfIndices{
            users.append(userNames[i])
        }
        let price = Double.random(in: 0.5...50.0)//0.5...50.0 is arbitrary
        let priceRounded = round(price*1000)/1000
        let item = Item(price: priceRounded, users: users)
        receipt.append(item)
    }
    let date = Date()
    let order = Order(userName:userNames[payerNameIndex], receipt:receipt, paid: false, time:dateFormatter.string(from:date))
    return order
}

func printAllOrdersFor(userName:String){
    let orders1 = getAllOrdersForUserName(userName: userName).orders
    printOrders(orders: orders1)
    print("there are \(orders1.count) orders")
}

func printUserInfoFor(userName:String){
    let userInfoDict1 = getUserInfoForUserName(userName: userName)
    if (userInfoDict1.count==0){
        print("No account with username: \(userName)")
        return
    }
    let userInfo = userInfoDict1[userInfoDict1.startIndex].value
    print("Username: \(userInfo.userName), Password: \(userInfo.password)")
}

//returns an order summary
func computeAmoundOwed(order:Order)->String{
    var dict = [String:Double]()
    computeAmountOwed(order: order, dict: &dict)
    var result = ""
    for (key,value) in dict{
        result += String(format: "\(key) owes %.2f to \(order.userName)\n", value)
    }
    return result
}

func computeAmountOwed(order:Order, dict: inout [String:Double]){
    if (order.paid==true){
        print("Order.paid is true. No need to compute amount owed")
        return//only compute amount owed for orders that have not been paid
    }
    for item in order.receipt{
        let amount = Double(item.price)/Double(item.users.count)
        for user in item.users {
            if (user != order.userName){
                //no need to keep track how much the person paid owes themselves
                //this is assuming that every person has a different name
                if (dict[user]==nil){
                    dict[user]=0.0
                }
                dict[user]!+=Double(amount)
            }
        }
    }
    //each user owes dict[user] to order.userName
    print("end of compute amound owed method")
}

func printOrder(order:Order){
    print("Payer user name: \(order.userName)")
    print("Receipt: ")
    for item in order.receipt {
        print("item price: \(item.price)")
        //print("User: ", terminator: "")
        // for user in item.users {//
        //     print("\(user) ", terminator: "")
        // }
        // print()
    }
}

func printOrders(orders:[Order]){
    for order in orders {
        printOrder(order:order)
    }
}

//to go back to ContentView view from AddUsers view
//code taken/copied from https://stackoverflow.com/questions/57334455/how-can-i-pop-to-the-root-view-using-swiftui/59662275#59662275
struct NavigationUtil {
  static func popToRootView() {
    findNavigationController(viewController: UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController)?
      .popToRootViewController(animated: true)
  }

  static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
    guard let viewController = viewController else {
      return nil
    }

    if let navigationController = viewController as? UINavigationController {
      return navigationController
    }

    for childViewController in viewController.children {
      return findNavigationController(viewController: childViewController)
    }

    return nil
  }
}
