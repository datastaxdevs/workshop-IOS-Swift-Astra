//
//  DBController.swift
//  GroceryHandler
//
//  Created by Victor Micha on 6/20/22.
//
//handles interaction to astra database
import SwiftUI

class ErrorManager: ObservableObject {
    //taken/copied from https://stackoverflow.com/questions/59312795/a-state-static-property-is-being-reinitiated-without-notice
    @Published var errorMessage: String = ""
    @Published var errMsgColor = Color.red
}

let shared = ErrorManager()

//returns true if user can sign in and false otherwise
//is also used to check if user can change password
func signIn(userName:String, password:String) async throws -> Bool{
    let (dict, noError) = try await getUserInfo(userName:userName)
    if (noError==false){
        return false
    }
    if (dict.count==0){
        shared.errMsgColor = Color.red
        shared.errorMessage = "There is no account with username \(userName)."
        print("There is no account with username \(userName).")
        return false
    }
    if (dict[dict.startIndex].value.password==password){
        //dict should have only one entry since usernames are unique
        return true
    } else {
        shared.errMsgColor = Color.red
        shared.errorMessage = "Incorrect password."
        print("Incorrect password.")
        return false
    }
}

//for a user to sign up (create account)
func createAccount(userName:String, password:String) async throws{
    print("Creating account for \(userName).")
    let (userInfoDict, noError) = try await getUserInfo(userName:userName)
    if (noError==false){
        print("error fetching userInfo")
        return
    }
    if (userInfoDict.count>0){
        shared.errMsgColor = Color.red
        shared.errorMessage = "Cannot create account with username: \(userName) because one already exists."
        print("Cannot create account with username: \(userName) because one already exists.")
        return
    }
    let _ = try await postRequest(userInfo: UserInfo(userName: userName, password: password))
    shared.errMsgColor = Color.green
    shared.errorMessage = "Account created successfully."
    print("Account created successfully.")
}

func deleteAccount(userName:String, password:String) async throws{
    print("Deleting acount... Please wait.")
    let (userInfoDB, noError) = try await getUserInfo(userName:userName)
    if (noError==false){
        print("error fetching userInfo")
        return
    }
    //returns dict of [docID:UserInfo]
    //because doc id is needed to delete from db
    if (userInfoDB.count==0){
        shared.errMsgColor = Color.red
        shared.errorMessage = "Cannot delete account with username: \(userName) because none exists."
        print("Cannot delete account with username: \(userName) because none exists.")
        return
    }
    //userInfoDB.count is either 0 (no account exists for userName)
    //or 1 (1 account exists for userName) because userNames are unique
    //userInfoDB[userInfoDB.startIndex].value -> a userInfo
    //userInfoDB[userInfoDB.startIndex].key -> docID string
    if (userInfoDB[userInfoDB.startIndex].value.password==password){
        let b = try await deleteUserInfoRequest(docID: userInfoDB[userInfoDB.startIndex].key)
        if (b==false){
            print("Error deleting userInfo, could not delete account")
            return
        } else {
            print("Deletion of user info is successfull")
        }
    } else {
        shared.errMsgColor = Color.red
        shared.errorMessage = "Incorrect password. Cannot delete account."
        print("Incorrect password. Cannot delete account.")
        return
    }
    try await deleteOrdersForUserName(userName:userName)
    shared.errMsgColor = Color.green
    shared.errorMessage = "Account deleted successfully."
    print("Account deleted successfully.")
}

func deleteOrdersForUserName(userName:String) async throws{
    //get all orders for username and get all their DOC IDs
    //then go through each ID and delete
    //get doc ID because can only delete from database with doc ID
    let (_, b, docIDSet) = try await getAllOrdersForUserNameAsync(userName:userName)
    if (b==false){
        print("could not delete all orders")
        return
    }
    for docID in docIDSet {
        print("deleting \(docID)")
        if (try await deleteOrderRequest(docID: docID)==false){
            print("error deleting doc \(docID)")
        }
    }
}

//if user has lots of receipts he wants to compute in one go
func computeAllOrdersFor(userName:String) async throws{
    let (orders1, _, _) = try await getAllOrdersForUserNameAsync(userName:userName)
    var dict = [String:Double]()
    for order in orders1{
        computeAmountOwed(order: order, dict: &dict)
    }
    for (key,value) in dict{
        print("\(key) owes \(value) to \(userName)")
    }
}

//create lots of fake accounts to test db
func populateUserInfoDB() async throws{
    try await createAccount(userName: "Michael1", password: "boss")
    try await createAccount(userName: "Dwight1", password: "bearsbeetsbattlestargallactica")
    try await createAccount(userName: "Jim1", password: "beesley!")
    try await createAccount(userName: "Pam1", password: "sprinkleofcinnamon")
    try await createAccount(userName: "Angela1", password: "cats")
    try await createAccount(userName: "Kevin1", password: "cookies")
    try await createAccount(userName: "Oscar1", password: "accountant")
    try await createAccount(userName: "Phillys1", password: "damnitphyllis")
    try await createAccount(userName: "Stanley1", password: "crosswordpuzzles")
    try await createAccount(userName: "Andy1", password: "itsdrewnow")
    try await createAccount(userName: "Toby1", password: "goingtocostarica")
    try await createAccount(userName: "Kelly1", password: "attention")
    try await createAccount(userName: "Ryan1", password: "hottestintheoffice")
    try await createAccount(userName: "David1", password: "corporate")
    try await createAccount(userName: "Gabe1", password: "birdman")
    try await createAccount(userName: "Robert1", password: "lizardking")
    try await createAccount(userName: "Creed1", password: "scrantonstrangler")
    try await createAccount(userName: "Roy1", password: "wharehouseandpam")
    try await createAccount(userName: "Darryl1", password: "rogers")
    try await createAccount(userName: "Jan1", password: "loveshunter")
    try await createAccount(userName: "Holly1", password: "michaelslove")
    try await createAccount(userName: "Mose1", password: "dwightsbrother")
    try await createAccount(userName: "Joe1", password: "ceoofsabre")
}

//populates orders db with orders given from a set of usernames
//same set of usernames in func populateUserInfoDB()
func populateOrdersDB(numNewOrders:Int) async throws{
    for _ in 0..<numNewOrders{
        let order = getRandomOrder(userNames: Array(getRandomSetOfUserNames()))
        print(try await postRequest(order: order))
    }
    print("Posted \(numNewOrders) new orders")
}


func getAllOrdersForUserNameAsString(userName:String) async throws ->(result:String, numOrders:Int){
    let (pastOrders, _, _) = try await getAllOrdersForUserNameAsync(userName:userName)
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

func proccessDataString(dataString:String)->(String, String){
    var dataString = dataString
    /*
     JSON data is of the form
     {“data”:
     {
     “docID”:Order,
     “docID”:Order
     }
     }
     OR (if there are more docs than <page-size> or <20>)
     {"pageState":"JDZjN2Y5MGQ5LWYyZGItNGRkNS05Mzk3LTZiNDE5NzYzNGMwZQDwf_____B_____","data":{
     “docID”:Order,
     “docID”:Order
     }
     }
     */
    var pageState = ""
    let y = 64//length of page-state
    if (dataString[dataString.index(dataString.startIndex, offsetBy: 2)]=="p"){
        pageState = String(dataString[dataString.index(dataString.startIndex, offsetBy: 14)...dataString.index(dataString.startIndex, offsetBy: 14+y-1)])
    }
    //need to clean up/proccess dataString
    
    var indx = dataString.startIndex//arbitrary, val is changed in if/else statement
    if (dataString[dataString.index(dataString.startIndex, offsetBy: 2)]=="p"){
        //there is page state
        //length of {"pageState":"JDZjN2Y5MGQ5LWYyZGItNGRkNS05Mzk3LTZiNDE5NzYzNGMwZQDwf_____B_____","data":
        //is 87 which is equal to 23+y
        indx = dataString.index(dataString.startIndex, offsetBy: 23+y)
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
     “docID”:Order,
     “docID”:Order
     } or {"docID":UserInfo}
     */
    return (dataString, pageState)
}

//if bool returned is false that means that error occured when fetching userInfo
func getUserInfo(userName:String) async throws -> ([String:UserInfo], Bool) {
    let str = "/namespaces/\(ASTRA_DB_KEYSPACENAME!)/collections/userInfo?where={\"userName\":{\"$eq\":\"\(userName)\"}}&page-size=1"
    print("USING ASYNC")
    let (dataString, noError) = try await getRequestAsync(str: str)
    if (noError==true){
        // print("no error")
    } else {
        print("error")
        return ([String:UserInfo](), false)
    }
    var userInfoDict = [String:UserInfo]()
    let (formattedData, _) = proccessDataString(dataString: dataString)
    if let jsonData = formattedData.data(using: .utf8) {
        let events = try? JSONDecoder().decode(DictUserInfo.self, from: jsonData)
        //if events!.count==1 -> there is user info for username
        //if events!.count==0 -> there is no user info for username
        if !(events!.count==0){
            //there is at least one user info (we are expecting only one)
            //events is dict of [String:UserInfo] -> [DocID:UserInfo]
            userInfoDict[events![events!.startIndex].key] = events![events!.startIndex].value
        }
        return (userInfoDict, true)
    } else {
        print("Could not convert to type Data")
        return (userInfoDict, false)
    }
}

func getRequestAsync(str:String) async throws -> (String, Bool){
    let request = httpRequest(httpMethod: "GET", endUrl: str)
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let response = response as? HTTPURLResponse,
          (200...299).contains(response.statusCode) else {
        print(response)
        return (response.description, false)
    }
    if response.mimeType == "application/json",
       let dataString = String(data: data, encoding: .utf8) {
        //print ("got data: \(dataString)")
        return (dataString, true)
    }
    return ("error", false)
}

func getAllOrdersForUserNameAsync(userName:String) async throws ->([Order], Bool, Set<String>){
    //TO GET ALL ORDERS: get request with page-size=20
    //then get operation with page-state = val of page state from first get request
    var orders = [Order]()
    var docIDSet = Set<String>()//to prevent duplicates
    var str = "/namespaces/\(ASTRA_DB_KEYSPACENAME!)/collections/orders?where={\"userName\":{\"$eq\":\"\(userName)\"}}&page-size=20"
    let (dataString, noError) = try await getRequestAsync(str: str)
    if (noError==true){
        //print("no error")
    } else {
        print("error")
        return ([Order](), false, Set<String>())
    }
    var (formattedData, pageState) = proccessDataString(dataString: dataString)
    if let jsonData = formattedData.data(using: .utf8) {
        let events = try? JSONDecoder().decode(DictOrder.self, from: jsonData)
        for (key, eventData) in events! {
            //eventData is an Order
            //key is a docID
            if !(docIDSet.contains(key)){
                docIDSet.insert(key)
                orders.append(eventData)
            }
        }
    } else {
        print("Could not convert to type Data")
    }
    if (pageState.isEmpty){
        return (orders, true, docIDSet)
    }
    while !(pageState.isEmpty){
        str = "/namespaces/\(ASTRA_DB_KEYSPACENAME!)/collections/orders?where={\"userName\":{\"$eq\":\"\(userName)\"}}&page-size=20&page-state=\(pageState)"
        print("pageState: \(pageState)")
        let (dataString, noError) = try await getRequestAsync(str: str)
        if (noError==true){
            //print("no error")
        } else {
            print("error")
            return ([Order](), false, Set<String>())
        }
        let (formattedData, pageState1) = proccessDataString(dataString: dataString)
        pageState = pageState1
        if let jsonData = formattedData.data(using: .utf8) {
            let events = try? JSONDecoder().decode(DictOrder.self, from: jsonData)
            for (key, eventData) in events! {
                //eventData is an Order
                //key is a docID
                if !(docIDSet.contains(key)){
                    docIDSet.insert(key)
                    orders.append(eventData)
                }
            }
        } else {
            print("Could not convert to type Data")
        }
    }
    return (orders, true, docIDSet)
}

//this method is called in ChangePassword view, which means that the user has a user info and already
//inputed a correct password
//returns true if could changePassword and false otherwise
func changePassword(newPassword:String, userName:String) async throws -> Bool{
    let (dict, noError) = try await getUserInfo(userName:userName)
    if (noError==false){
        return false
    }
    let docID = dict[dict.startIndex].key
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    guard let uploadData = try? encoder.encode(Password(password: newPassword)) else {
        return false//could not convert to type data
    }
    let request = httpRequest(httpMethod: "PATCH", endUrl: "/namespaces/\(ASTRA_DB_KEYSPACENAME!)/collections/userInfo/\(docID)")
    print("DOC ID: \(docID)")
    let (data, response) = try await URLSession.shared.upload(for: request, from: uploadData)
    if response.mimeType == "application/json",
       let dataString = String(data: data, encoding: .utf8) {
        print ("got data: \(dataString)")
        return true
        //dataString is of form:
        /*
         {"documentId":"58171bbd-cd42-4c54-a5f7-ed146097d1dc"}
         */
    }
    return false
}

func postRequest(uploadData:Data, collection:String) async throws -> String{
    let request = httpRequest(httpMethod: "POST", endUrl: "/namespaces/\(ASTRA_DB_KEYSPACENAME!)/collections/\(collection)")
    let (data, response) = try await URLSession.shared.upload(for: request, from: uploadData)
    guard let response = response as? HTTPURLResponse,
          (200...299).contains(response.statusCode) else {
        print ("server error")
        print("Response: \(response)")
        return response.description
    }
    if response.mimeType == "application/json",
       let dataString = String(data: data, encoding: .utf8) {
        //print("POST to \(collection) successful")
        if (collection.elementsEqual("userInfo")){
            print("Account created successfully")
        }
        //print ("got data: \(dataString)")
        //dataString is of form:
        /*
         {"documentId":"58171bbd-cd42-4c54-a5f7-ed146097d1dc"}
         */
        return dataString
    }
    return "ERROR"
}

//posts a userInfo to db
func postRequest(userInfo:UserInfo) async throws -> String{
    print("In async function")
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    guard let uploadData = try? encoder.encode(userInfo) else {
        return "error convert to data"
        //could not convert to type data
    }
    let str = try await postRequest(uploadData: uploadData, collection: "userInfo")
    return str
}

//posts an order to db
func postRequest(order:Order) async throws -> String{
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    guard let uploadData = try? encoder.encode(order) else {
        return "error convert to data"
        //could not convert to type data
    }
    let str = try await postRequest(uploadData: uploadData, collection: "orders")
    return str
}

func getOrdersWhereTotalIs(total:Double, userName:String) async throws ->[Order]{
    let (orders1, _, _) = try await getAllOrdersForUserNameAsync(userName:userName)
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
    /*see for details: https://developer.apple.com/documentation/foundation/url_loading_system/uploading_data_to_a_website*/
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

func deleteUserInfoRequest(docID:String) async throws -> Bool{
    return try await deleteRequest(docID: docID, collectionID: "userInfo")
}

func deleteOrderRequest(docID:String) async throws -> Bool{
    return try await deleteRequest(docID: docID, collectionID: "orders")
}

//returns true if delete is successfull
func deleteRequest(docID:String, collectionID:String) async throws-> Bool{
    let request = httpRequest(httpMethod: "DELETE", endUrl: "/namespaces/\(ASTRA_DB_KEYSPACENAME!)/collections/\(collectionID)/\(docID)")
    let response = try await URLSession.shared.data(for: request)
    //NEED TO ASK WHAT RANGER OF HTTPRESPONSES WOULD MEAN AN ERROR OCCURED
    /*guard let response = response as? HTTPURLResponse,
     (200...299).contains(response.statusCode) else {
     print ("server error")
     print(response)
     return false
     }*/
    return true
}
