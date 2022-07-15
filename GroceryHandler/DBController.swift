//
//  DBController.swift
//  GroceryHandler
//
//  Created by Victor Micha on 6/20/22.
//
//handles interaction to astra database
import Foundation
import SwiftUI

class ErrorManager: ObservableObject {
    //taken/copied from https://stackoverflow.com/questions/59312795/a-state-static-property-is-being-reinitiated-without-notice
    @Published var errorMessage: String = ""
    @Published var errMsgColor = Color.red
}

let shared = ErrorManager()

class PricesManager: ObservableObject {
    //taken/copied from https://stackoverflow.com/questions/59312795/a-state-static-property-is-being-reinitiated-without-notice
    @Published var getPrices: Bool = false
    @Published var prices = [Double]()
}

let pricesManager = PricesManager()

//returns true if user can sign in and false otherwise
//is also used to check if user can change password
func signIn(userName:String, password:String)->Bool{
    let dict = getUserInfoForUserName(userName: userName)
    if (dict.count==0){
        shared.errMsgColor = Color.red
        shared.errorMessage = "There is no account with username \(userName)."
        return false
    }
    if (dict[dict.startIndex].value.password==password){//dict should have only one entry since usernames are unique
        return true
    } else {
        shared.errMsgColor = Color.red
        shared.errorMessage = "Incorrect password."// Could not sign in."commented because sign in func is also used for changing password
        return false
    }
}

//for a user to sign up (create account)
func createAccount(userName:String, password:String){
    let userInfoDict = getUserInfoForUserName(userName: userName)
    if (userInfoDict.count>0){
        shared.errMsgColor = Color.red
        shared.errorMessage = "Cannot create account with username: \(userName) because one already exists."
        print("Cannot create account with username: \(userName) because one already exists.")
        return
    }
    postRequest(userInfo: UserInfo(userName: userName, password: password))
    shared.errMsgColor = Color.green
    shared.errorMessage = "Account created successfully."
}

func deleteAccount(userName:String, password:String){
    print("Deleting acount... Please wait")
    //get user info and doc id from astra db
    let userInfoDB = getUserInfoForUserName(userName: userName)
    //returns dict of [docID:UserInfo]
    //because doc id is needed to delete from db
    if (userInfoDB.count==0){
        shared.errMsgColor = Color.red
        shared.errorMessage = "Cannot delete account with username: \(userName) because none exists."
        print("Cannot delete account with username: \(userName) because none exists.")
        return
    }
    //userInfoDB[userInfoDB.startIndex].value -> a userInfo
    //userInfoDB[userInfoDB.startIndex].key -> docID string
    if (userInfoDB[userInfoDB.startIndex].value.password==password){
        deleteUserInfoRequest(docID: userInfoDB[userInfoDB.startIndex].key)
    } else {
        shared.errMsgColor = Color.red
        shared.errorMessage = "Incorrect password. Cannot delete account."
        print("Incorrect password. Cannot delete account.")
        return
    }
    deleteOrdersForUserName(userName:userName)
    shared.errMsgColor = Color.green
    shared.errorMessage = "Account deleted successfully"
}

func deleteOrdersForUserName(userName:String){
    //get all orders for username and get all their DOC IDs
    //then go through each ID and delete
    let localOrderDB = getAllOrdersForUserName(userName: userName).localOrderDB//get doc ID because can only delete from database with doc ID
    for (docID, _) in localOrderDB {
        deleteOrderRequest(docID: docID)
    }
}

//if user has lots of receipts he wants to compute in one go
func computeAllOrdersFor(userName:String){
    let orders1 = getAllOrdersForUserName(userName: userName).orders
    var dict = [String:Double]()
    for order in orders1{
        computeAmountOwed(order: order, dict: &dict)
    }
    for (key,value) in dict{
        print("\(key) owes \(value) to \(userName)")
    }
}

func populateUserInfoDB(){
    createAccount(userName: "Michael1", password: "thatswhatshesaid")
    createAccount(userName: "Dwight1", password: "bearsbeetsbattlestargallactica")
    createAccount(userName: "Jim1", password: "beesley!")
    createAccount(userName: "Pam1", password: "sprinkleofcinnamon")
    createAccount(userName: "Angela1", password: "cats")
    createAccount(userName: "Kevin1", password: "cookies")
    createAccount(userName: "Oscar1", password: "accountant")
    createAccount(userName: "Phillys1", password: "damnitphyllis")
    createAccount(userName: "Stanley1", password: "crosswordpuzzles")
    createAccount(userName: "Andy1", password: "itsdrewnow")
    createAccount(userName: "Toby1", password: "goingtocostarica")
    createAccount(userName: "Kelly1", password: "attention")
    createAccount(userName: "Ryan1", password: "hottestintheoffice")
    createAccount(userName: "David1", password: "corporate")
    createAccount(userName: "Gabe1", password: "birdman")
    createAccount(userName: "Robert1", password: "lizardking")
    createAccount(userName: "Creed1", password: "scrantonstrangler")
    createAccount(userName: "Roy1", password: "wharehouseandpam")
    createAccount(userName: "Darryl1", password: "rogers")
    createAccount(userName: "Jan1", password: "loveshunter")
    createAccount(userName: "Holly1", password: "michaelslove")
    createAccount(userName: "Mose1", password: "dwightsbrother")
    createAccount(userName: "Joe1", password: "ceoofsabre")
}

func populateOrdersDB(numNewOrders:Int){
    for _ in 0..<numNewOrders{
        let order = getRandomOrder(userNames: Array(getRandomSetOfUserNames()))
        postRequest(order: order)
    }
}

//return dict of [docID:UserInfo] of size 1 if there exists a userInfo
//for userName or of size 0 otherwise
func getUserInfoForUserName(userName:String)-> [String:UserInfo]{
    getRequestUserInfo(userName:userName)
    //userInfo isn't fetched even after getRequestUserInfo is finished -> async call
    //after while loop async func will be finished
    while gotUserInfo==false{
        Thread.sleep(forTimeInterval: 0.001)
    }
    //print("there are \(localUserInfoDB.count) user infos with username: \(userName)")
    var localUserInfoDBCpy = [String:UserInfo]()
    if (localUserInfoDB.count==1){
        //there is a user info for userName
        print("there is a user info for \(userName)")
        let userInf = localUserInfoDB[localUserInfoDB.startIndex].value
        localUserInfoDBCpy[localUserInfoDB[localUserInfoDB.startIndex].key] = UserInfo(userName: userInf.userName, password: userInf.password)
    }
    //reinitialize gotOrders and orders and localOrderDB
    gotUserInfo = false
    localUserInfoDB.removeAll()
    return localUserInfoDBCpy
}

func getAllOrdersForUserNameAsString(userName:String)->(result:String, numOrders:Int){
    let pastOrders = getAllOrdersForUserName(userName: userName).orders
    var result = ""
    for order in pastOrders {
        result += getOrderAsString(order: order)
        result += "\n"
    }
    print(result)
    return (result, pastOrders.count)
}

func getOrderAsString(order:Order)->String{
    var result = "Paid: \(order.paid), Date: \(order.time)\n"
    for item in order.receipt {
        result += "Price: \(item.price) -- Users: "
        for user in item.users {
            result += "\(user) "
        }
        result+="\n"
    }
    result+="\n-----------------------\n"
    return result
}

/*
 get all orders for userName
 so that a user can see all past orders
 */
func getAllOrdersForUserName(userName:String)->(orders: [Order], localOrderDB: [String:Order]) {
    getRequestOrders(userName:userName, maxNumOrders: 20)
    //max number of orders to fetch is 20 because page-size has to be <=20
    //TO GET ALL ORDERS: get request with page-size=20
    //then get operation with page-state = val of page state from first get request
    
    //orders aren't fetched even after getRequestOrders is finished
    //because of async call
    //need while loop
    var ordersCpy = [Order]()
    var localOrderDBCpy = [String:Order]()
    while gotOrders==false{
        Thread.sleep(forTimeInterval: 0.001)
    }
    //print("there are \(orders.count) orders")
    for (docID, order) in localOrderDB {
        if localOrderDBCpy[docID]==nil {//to prevent duplicate docs
            let o = Order(userName: order.userName, receipt: order.receipt, paid: order.paid, time: order.time)
            ordersCpy.append(o)
            localOrderDBCpy[docID] = o
        }
    }
    //reinitialize gotOrders and orders and localOrderDB
    gotOrders = false
    orders = [Order]()
    localOrderDB.removeAll()
    if (pageState.isEmpty){
        return (ordersCpy, localOrderDBCpy)
    }
    while (!(pageState.isEmpty)){
        let str = "/namespaces/keyspacename1/collections/orders?where={\"userName\":{\"$eq\":\"\(userName)\"}}&page-size=20&page-state=\(pageState)"
        pageState = ""//re initialize pageState
        getRequest(orderOrUserInfo: true, str: str)
        while gotOrders==false{
            Thread.sleep(forTimeInterval: 0.001)
        }
        //  print("there are \(orders.count) orders")
        for (docID, order) in localOrderDB {
            if localOrderDBCpy[docID]==nil {//to prevent duplicate docs
                let o = Order(userName: order.userName, receipt: order.receipt, paid: order.paid, time: order.time)
                ordersCpy.append(o)
                localOrderDBCpy[docID] = o
            }
        }
        //reinitialize gotOrders and orders and localOrderDB
        gotOrders = false
        orders = [Order]()
        localOrderDB.removeAll()
    }
    //dont need to reinitialize pageState to empty string because
    //if the while loop finished that means it is already empty
    return (ordersCpy, localOrderDBCpy)
}

//orderOrUserInfo is true to perform order get request
//and false to perform user info get request
//(if database has more than two collections, use an enum instead of boolean)
func getRequest(orderOrUserInfo:Bool, str:String){
    let request = httpRequest(httpMethod: "GET", endUrl: str)
    let task = URLSession.shared.dataTask(with: request){ data, response, error in
        if error != nil {
            return
        }
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            print(response)
            return
        }
        if let mimeType = response.mimeType,
           mimeType == "application/json",
           let data = data,
           var dataString = String(data: data, encoding: .utf8) {
            //print ("got data: \(dataString)")
            /*
             JSON data is of the form
             {“data”:
             {
             “docID”: Order,
             “docID”:Order
             }
             }
             OR (if there are more docs than <page-size> or <20>)
             {"pageState":"JDZjN2Y5MGQ5LWYyZGItNGRkNS05Mzk3LTZiNDE5NzYzNGMwZQDwf_____B_____","data":{
             
             “docID”: Order,
             “docID”:Order
             }
             }
             */
            //need to clean up/proccess dataString
            let y = 64//length of page-state
            //no page state if looking for user info
            if (orderOrUserInfo==true && dataString[dataString.index(dataString.startIndex, offsetBy: 2)]=="p"){
                pageState = String(dataString[dataString.index(dataString.startIndex, offsetBy: 14)...dataString.index(dataString.startIndex, offsetBy: 14+y-1)])
            }
            var indx = dataString.startIndex//arbitrary, val is changed in if/else statement
            if (dataString[dataString.index(dataString.startIndex, offsetBy: 2)]=="p"){
                //there is page state
                indx = dataString.index(dataString.startIndex, offsetBy: 14+y-1+10)
            } else {
                //there is no page state
                //length of {“data”: is 8
                indx = dataString.index(dataString.startIndex, offsetBy: 8)
            }
            let x = dataString.startIndex..<indx
            dataString.removeSubrange(x)
            dataString.removeLast()//to remove last }
            //print("dataString: \(dataString)")
            /*
             by now dataString is of form:
             {
             “docID”: Order,
             “docID”:Order
             } or {"docID":UserInfo}
             */
            //https://medium.com/@boguslaw.parol/decoding-dynamic-json-with-unknown-properties-names-and-changeable-values-with-swift-and-decodable-127e437e8000
            if (orderOrUserInfo==true){
                typealias Values = [String: Order]
                if let jsonData = dataString.data(using: .utf8) {
                    let events = try? JSONDecoder().decode(Values.self, from: jsonData)
                    for (key, eventData) in events! {
                        //eventData is an Order
                        //key is a docID
                        localOrderDB[key]=eventData
                        orders.append(eventData)
                    }
                    gotOrders = true
                } else {
                    print("Could not convert to type Data")
                }
            } else {
                typealias Values = [String: UserInfo]
                if let jsonData = dataString.data(using: .utf8) {
                    let events = try? JSONDecoder().decode(Values.self, from: jsonData)
                    //if events!.count==1 -> there is user info for username
                    //if events!.count==0 -> there is no user info for username
                    if !(events!.count==0){
                        //there is at least one user info (we are expecting only one)
                        //events is dict of [String:UserInfo] -> [DocID:UserInfo]
                        localUserInfoDB[events![events!.startIndex].key] = events![events!.startIndex].value
                    }
                    gotUserInfo = true
                } else {
                    print("Could not convert to type Data")
                }
            }
        }
    }
    task.resume()
}

//sets correct value to "localUserInfoDB"
func getRequestUserInfo(userName:String){
    let str = "/namespaces/keyspacename1/collections/userInfo?where={\"userName\":{\"$eq\":\"\(userName)\"}}&page-size=1"
    getRequest(orderOrUserInfo: false, str: str)
}

//sets correct values to "orders" and "localOrderDB" vars
func getRequestOrders(userName:String, maxNumOrders:Int){
    //param is username of person to retrieve all orders
    let str = "/namespaces/keyspacename1/collections/orders?where={\"userName\":{\"$eq\":\"\(userName)\"}}&page-size=\(maxNumOrders)"
    getRequest(orderOrUserInfo: true, str: str)
}

func setOrderStatusToPaid(docID:String){
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    guard let uploadData = try? encoder.encode(Paid(paid:true)) else {
        return//could not convert to type data
    }
    let request = httpRequest(httpMethod: "PATCH", endUrl: "/namespaces/keyspacename1/collections/orders/\(docID)")
    let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
        if let error = error {
            print ("error: \(error)")
            return
        }
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            print ("server error")
            return
        }
        if let mimeType = response.mimeType,
           mimeType == "application/json",
           let data = data,
           let dataString = String(data: data, encoding: .utf8) {
            print ("got data: \(dataString)")
            //dataString is of form:
            /*
             {"documentId":"58171bbd-cd42-4c54-a5f7-ed146097d1dc"}
             */
        }
    }
    task.resume()
}


//this method is called in ChangePassword view, which means that the user has a user info and already
//inputed a correct password
func changePassword(newPassword:String, userName:String){
    let dict = getUserInfoForUserName(userName: userName)
    let docID = dict[dict.startIndex].key
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    guard let uploadData = try? encoder.encode(Password(password: newPassword)) else {
        return//could not convert to type data
    }
    let request = httpRequest(httpMethod: "PATCH", endUrl: "/namespaces/keyspacename1/collections/userInfo/\(docID)")
    let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
        if let error = error {
            print ("error: \(error)")
            return
        }
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            print ("server error")
            return
        }
        if let mimeType = response.mimeType,
           mimeType == "application/json",
           let data = data,
           let dataString = String(data: data, encoding: .utf8) {
            print ("got data: \(dataString)")
            //dataString is of form:
            /*
             {"documentId":"58171bbd-cd42-4c54-a5f7-ed146097d1dc"}
             */
        }
    }
    task.resume()
}

func postRequest(uploadData:Data, collection:String){
    let request = httpRequest(httpMethod: "POST", endUrl: "/namespaces/keyspacename1/collections/\(collection)")
    let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
        if let error = error {
            print ("error: \(error)")
            return
        }
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            print ("server error")
            print("Response: \(response!)")
            return
        }
        if let mimeType = response.mimeType,
           mimeType == "application/json",
           let data = data,
           let dataString = String(data: data, encoding: .utf8) {
            //print("POST to \(collection) successful")
            if (collection.elementsEqual("userInfo")){
                print("Account created successfully")
            }
            print ("got data: \(dataString)")
            //dataString is of form:
            /*
             {"documentId":"58171bbd-cd42-4c54-a5f7-ed146097d1dc"}
             */
        }
    }
    task.resume()
}

//posts a userInfo to db
func postRequest(userInfo:UserInfo){
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    guard let uploadData = try? encoder.encode(userInfo) else {
        return
        //could not convert to type data
    }
    postRequest(uploadData: uploadData, collection: "userInfo")
}

//posts an order to db
func postRequest(order:Order){
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    guard let uploadData = try? encoder.encode(order) else {
        return
        //could not convert to type data
    }
    postRequest(uploadData: uploadData, collection: "orders")
}

func getOrdersWhereTotalIs(total:Double, userName:String)->[Order]{
    let orders1 = getAllOrdersForUserName(userName: userName).orders
    var result = [Order]()
    for order in orders1 {
        var sum = 0.0
        for item in order.receipt{
            sum+=item.price
        }
        if (sum == total){
            result.append(order)
        }
    }
    return result
}

func httpRequest(httpMethod: String, endUrl: String)-> URLRequest {
    /*code for this function is taken/copied from : https://developer.apple.com/documentation/foundation/url_loading_system/uploading_data_to_a_website*/
    let str = "https://"+ASTRA_DB_ID!+"-"+ASTRA_DB_REGION!+".apps.astra.datastax.com/api/rest/v2"+endUrl
    let encodedStr = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let url = URL.init(string:encodedStr)!
    var request = URLRequest(url: url)
    request.httpMethod = httpMethod//"POST", "GET", etc
    if (httpMethod=="POST"){
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    request.setValue("application/json", forHTTPHeaderField: "accept")
    request.setValue(ASTRA_DB_TOKEN!, forHTTPHeaderField: "X-Cassandra-Token")
    return request
}

func deleteUserInfoRequest(docID:String){
    deleteRequest(docID: docID, collectionID: "userInfo")
}

func deleteOrderRequest(docID:String){
    deleteRequest(docID: docID, collectionID: "orders")
}

func deleteRequest(docID:String, collectionID:String){
    let request = httpRequest(httpMethod: "DELETE", endUrl: "/namespaces/keyspacename1/collections/\(collectionID)/\(docID)")
    let task = URLSession.shared.dataTask(with: request){ data, response, error in
        if let error = error {
            print ("error: \(error)")
            return
        }
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            print ("server error")
            return
        }
    }
    task.resume()
}
