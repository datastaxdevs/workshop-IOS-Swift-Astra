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
func signIn(userName:String, password:String) async -> Bool{
    do {
        let dict = try await getUserInfo(userName:userName)
        if (dict.count==0){
            DispatchQueue.main.async {//UI can only be changed from main thread
                shared.errMsgColor = Color.red
                shared.errorMessage = "There is no account with username \(userName)."
            }
            print("There is no account with username \(userName).")
            return false
        }
        if (dict[dict.startIndex].value.password==password){
            //dict should have only one entry since usernames are unique
            print("Correct password, signing in")
            return true
        } else {
            DispatchQueue.main.async {//UI can only be changed from main thread
                shared.errMsgColor = Color.red
                shared.errorMessage = "Incorrect password."
            }
            print("Incorrect password.")
            return false
        }
    } catch AstraError.getError {
        print("ASTRA GET ERROR CAUGHT")
    } catch AstraError.stringToDataError {
        print("Error converting string to DATA")
    } catch AstraError.decodeIntoDictionaryError{
        print("Error decoding into dictionary")
    } catch {
        print("error")
    }
    DispatchQueue.main.async {//UI can only be changed from main thread
        shared.errMsgColor = Color.red
        shared.errorMessage = "Error: Could not sign in."
    }
    return false
}

//for a user to sign up (create account)
func createAccount(userName:String, password:String) async {
    print("Creating account for \(userName).")
    do {
        let userInfoDict = try await getUserInfo(userName:userName)
        if (userInfoDict.count>0){
            DispatchQueue.main.async {//UI can only be changed from main thread
                shared.errMsgColor = Color.red
                shared.errorMessage = "Cannot create account with username: \(userName) because one already exists."
            }
            print("Cannot create account with username: \(userName) because one already exists.")
            return
        }
        try await postRequest(userInfo: UserInfo(userName: userName, password: password))
        DispatchQueue.main.async {//UI can only be changed from main thread
            shared.errMsgColor = Color.green
            shared.errorMessage = "Account created successfully."
        }
        print("Account created successfully.")
        return
    } catch AstraError.getError {
        print("ASTRA get error CAUGHT")
    } catch AstraError.stringToDataError {
        print("Error converting string to DATA")
    } catch AstraError.postError {
        print("Astra POST error caugth")
        print("Error posting user info. Could not create account")
    } catch AstraError.structToDataError {
        print("Error converting struct to data")
    } catch AstraError.decodeIntoDictionaryError{
        print("Error decoding into dictionary")
    } catch {
        print("error")
    }
    DispatchQueue.main.async {//UI can only be changed from main thread
        shared.errMsgColor = Color.red
        shared.errorMessage = "Error: could not create account."
    }
}

func deleteAccount(userName:String, password:String) async{
    print("Deleting acount... Please wait.")
    do {
        let userInfoDB = try await getUserInfo(userName:userName)
        //returns dict of [docID:UserInfo]
        //because doc id is needed to delete from db
        if (userInfoDB.count==0){
            DispatchQueue.main.async {//UI can only be changed from main thread
                shared.errMsgColor = Color.red
                shared.errorMessage = "Cannot delete account with username: \(userName) because none exists."
            }
            print("Cannot delete account with username: \(userName) because none exists.")
            return
        }
        //userInfoDB.count is either 0 (no account exists for userName)
        //or 1 (1 account exists for userName) because userNames are unique
        //userInfoDB[userInfoDB.startIndex].value -> a userInfo
        //userInfoDB[userInfoDB.startIndex].key -> docID string
        if (userInfoDB[userInfoDB.startIndex].value.password==password){
            DispatchQueue.main.async {//UI can only be changed from main thread
                shared.errMsgColor = Color.orange
                shared.errorMessage = "Deleting acount... Please wait."
            }
            try await deleteUserInfoRequest(docID: userInfoDB[userInfoDB.startIndex].key)
        } else {
            DispatchQueue.main.async {//UI can only be changed from main thread
                shared.errMsgColor = Color.red
                shared.errorMessage = "Incorrect password. Cannot delete account."
            }
            print("Incorrect password. Cannot delete account.")
            return
        }
        try await deleteOrdersForUserName(userName:userName)
        DispatchQueue.main.async {//UI can only be changed from main thread
            shared.errMsgColor = Color.green
            shared.errorMessage = "Account deleted successfully."
        }
        print("Account deleted successfully.")
        return
    } catch AstraError.getError {
        print("ASTRA get error CAUGHT")
    } catch AstraError.stringToDataError {
        print("Error converting string to DATA")
    } catch AstraError.deleteUserInfoError {
        print("ASTRA DELETE ERROR CAUGHT")
        print("Error deleting userInfo, could not delete account")
    } catch AstraError.deleteOrderError {
        print("ASTRA DELETE ERROR CAUGHT")
        print("Error deleting order. Could not delete all orders for \(userName)")
    } catch AstraError.decodeIntoDictionaryError{
        print("Error decoding into dictionary")
    } catch {
        print("error")
    }
    DispatchQueue.main.async {//UI can only be changed from main thread
        shared.errMsgColor = Color.red
        shared.errorMessage = "Error occured while deleting account"
    }
}

func deleteOrdersForUserName(userName:String) async throws{
    //get all orders for username and get all their DOC IDs
    //then go through each ID and delete
    //get doc ID because can only delete from database with doc ID
    let (_, docIDSet) = try await getAllOrdersForUserNameAsync(userName:userName)
    for docID in docIDSet {
        print("deleting \(docID)")
        try await deleteOrderRequest(docID: docID)
    }
}

//if user has lots of receipts he wants to compute in one go
func computeAllOrdersFor(userName:String) async {
    do {
        let (orders1, _) = try await getAllOrdersForUserNameAsync(userName:userName)
        var dict = [String:Double]()
        for order in orders1{
            computeAmountOwed(order: order, dict: &dict)
        }
        for (key,value) in dict{
            print("\(key) owes \(value) to \(userName)")
        }
    } catch AstraError.getError {
        print("ASTRA GET ERROR CAUGHT")
    } catch AstraError.stringToDataError {
        print("Error converting string to DATA")
    } catch AstraError.decodeIntoDictionaryError{
        print("Error decoding into dictionary")
    } catch {
        print("error")
    }
}

//create lots of fake accounts to test db
func populateUserInfoDB() async{
    await createAccount(userName: "Michael1", password: "boss")
    await createAccount(userName: "Dwight1", password: "bearsbeetsbattlestargallactica")
    await createAccount(userName: "Jim1", password: "beesley!")
    await createAccount(userName: "Pam1", password: "sprinkleofcinnamon")
    await createAccount(userName: "Angela1", password: "cats")
    await createAccount(userName: "Kevin1", password: "cookies")
    await createAccount(userName: "Oscar1", password: "accountant")
    await createAccount(userName: "Phillys1", password: "damnitphyllis")
    await createAccount(userName: "Stanley1", password: "crosswordpuzzles")
    await createAccount(userName: "Andy1", password: "itsdrewnow")
    await createAccount(userName: "Toby1", password: "goingtocostarica")
    await createAccount(userName: "Kelly1", password: "attention")
    await createAccount(userName: "Ryan1", password: "hottestintheoffice")
    await createAccount(userName: "David1", password: "corporate")
    await createAccount(userName: "Gabe1", password: "birdman")
    await createAccount(userName: "Robert1", password: "lizardking")
    await createAccount(userName: "Creed1", password: "scrantonstrangler")
    await createAccount(userName: "Roy1", password: "wharehouseandpam")
    await createAccount(userName: "Darryl1", password: "rogers")
    await createAccount(userName: "Jan1", password: "loveshunter")
    await createAccount(userName: "Holly1", password: "michaelslove")
    await createAccount(userName: "Mose1", password: "dwightsbrother")
    await createAccount(userName: "Joe1", password: "ceoofsabre")
}

//populates orders db with orders given from a set of usernames
//same set of usernames in func populateUserInfoDB()
func populateOrdersDB(numNewOrders:Int) async {
    do {
        for _ in 0..<numNewOrders{
            let order = getRandomOrder(userNames: Array(getRandomSetOfUserNames()))
            try await postRequest(order: order)
        }
        print("Posted \(numNewOrders) new orders")
    } catch AstraError.structToDataError {
        print("Error converting struct to data")
    } catch AstraError.postError {
        print("Error posting order")
    } catch {
        print("error")
    }
}

func getAllOrdersForUserNameAsString(userName:String) async ->(result:String, numOrders:Int){
    do {
        let (pastOrders, _) = try await getAllOrdersForUserNameAsync(userName:userName)
        var result = ""
        for order in pastOrders {
            result += getOrderAsString(order: order)
            result += "\n"
        }
        print(result)
        return (result, pastOrders.count)
    } catch AstraError.getError {
        print("ASTRA GET ERROR CAUGHT")
    } catch AstraError.stringToDataError {
        print("Error converting string to DATA")
    } catch AstraError.decodeIntoDictionaryError{
        print("Error decoding into dictionary")
    } catch {
        print("error")
    }
    return ("", 0)
}

func proccessDataString(dataString:String)->(String, String){
    var dataString = dataString
    /*
     JSON dataString is of the form
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

func getUserInfo(userName:String) async throws -> [String:UserInfo] {
    let str = "/namespaces/\(ASTRA_DB_KEYSPACENAME!)/collections/userInfo?where={\"userName\":{\"$eq\":\"\(userName)\"}}&page-size=1"
    let dataString = try await getRequestAsync(str: str)
    let (formattedData, _) = proccessDataString(dataString: dataString)
    if let jsonData = formattedData.data(using: .utf8) {
        do {
            let userInfoDict = try JSONDecoder().decode([String:UserInfo].self, from: jsonData)
            //userInfoDict is dict of [String:UserInfo] -> [DocID:UserInfo]
            //if userInfoDict.count==1 -> there is user info for username
            //if userInfoDict.count==0 -> there is no user info for username
            return userInfoDict
        } catch {
            throw AstraError.decodeIntoDictionaryError
        }
    } else {
        throw AstraError.stringToDataError
    }
}

func getRequestAsync(str:String) async throws -> String {
    let request = httpRequest(httpMethod: "GET", endUrl: str)
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let response = response as? HTTPURLResponse,
          response.statusCode == 200 else {
        //response.status code is 200 on successful GET
        print(response)
        throw AstraError.getError
    }
    if response.mimeType == "application/json",
       let dataString = String(data: data, encoding: .utf8) {
        //print ("got data: \(dataString)")
        //print("Response status code in get request: \(response.statusCode)")
        return dataString
    }
    throw AstraError.getError
}

func getAllOrdersForUserNameAsync(userName:String) async throws ->([Order], Set<String>){
    //TO GET ALL ORDERS: get request with page-size=20
    //then get operation with page-state = val of page state from first get request
    var orders = [Order]()
    var docIDSet = Set<String>()//to prevent duplicates
    var str = "/namespaces/\(ASTRA_DB_KEYSPACENAME!)/collections/orders?where={\"userName\":{\"$eq\":\"\(userName)\"}}&page-size=20"
    let dataString = try await getRequestAsync(str: str)
    var (formattedData, pageState) = proccessDataString(dataString: dataString)
    if let jsonData = formattedData.data(using: .utf8) {
        do {
            let ordersDict = try JSONDecoder().decode([String:Order].self, from: jsonData)
            for (docID, order) in ordersDict {
                if !(docIDSet.contains(docID)){
                    docIDSet.insert(docID)
                    orders.append(order)
                }
            }
        }
        catch {
            throw AstraError.decodeIntoDictionaryError
        }
    } else {
        print("Could not convert to type Data")
        throw AstraError.stringToDataError
    }
    if (pageState.isEmpty){
        return (orders, docIDSet)
    }
    while !(pageState.isEmpty){
        str = "/namespaces/\(ASTRA_DB_KEYSPACENAME!)/collections/orders?where={\"userName\":{\"$eq\":\"\(userName)\"}}&page-size=20&page-state=\(pageState)"
        print("pageState: \(pageState)")
        let dataString = try await getRequestAsync(str: str)
        let (formattedData, pageState1) = proccessDataString(dataString: dataString)
        pageState = pageState1
        if let jsonData = formattedData.data(using: .utf8) {
            do {
                let ordersDict = try JSONDecoder().decode([String:Order].self, from: jsonData)
                for (docID, order) in ordersDict {
                    if !(docIDSet.contains(docID)){
                        docIDSet.insert(docID)
                        orders.append(order)
                    }
                }
            }
            catch {
                throw AstraError.decodeIntoDictionaryError
            }
        } else {
            print("Could not convert to type Data")
            throw AstraError.stringToDataError
        }
    }
    return (orders, docIDSet)
}

//this method is called in ChangePassword view, which means that the user has a user info and already
//inputed a correct password
//returns true if could changePassword and false otherwise
func changePassword(newPassword:String, userName:String) async -> Bool{
    do {
        let dict = try await getUserInfo(userName:userName)
        if (dict.count==0){
            //this shouldnt happen because the user has already signed in so there must be a user info
            //this can only happen if the user info is deleted by a third party while the user is still
            //using the app
            return false
        }
        let docID = dict[dict.startIndex].key
        let encoder = JSONEncoder()
        guard let uploadData = try? encoder.encode(Password(password: newPassword)) else {
            return false//could not convert to type data
        }
        let request = httpRequest(httpMethod: "PATCH", endUrl: "/namespaces/\(ASTRA_DB_KEYSPACENAME!)/collections/userInfo/\(docID)")
        let (data, response) = try await URLSession.shared.upload(for: request, from: uploadData)
        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
            //status code 200 for successful patch
            print("Response: \(response)")
            return false
        }
        print("Response status code in change password: \(response.statusCode)")
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
    } catch AstraError.getError {
        print("ASTRA GET ERROR CAUGHT")
        return false
    } catch AstraError.stringToDataError {
        print("Error converting string to DATA")
        return false
    } catch AstraError.decodeIntoDictionaryError{
        print("Error decoding into dictionary")
        return false
    } catch {
        print("error")
        return false
    }
}

//POST is successful if no error is thrown
func postRequest(uploadData:Data, collection:String) async throws {
    let request = httpRequest(httpMethod: "POST", endUrl: "/namespaces/\(ASTRA_DB_KEYSPACENAME!)/collections/\(collection)")
    let (data, response) = try await URLSession.shared.upload(for: request, from: uploadData)
    guard let response = response as? HTTPURLResponse,
          response.statusCode == 201 else {
        //status code 201 for successfull post
        print("Response: \(response)")
        throw AstraError.postError
    }
    print("Response status code in POST: \(response.statusCode)")
    if response.mimeType == "application/json",
       let dataString = String(data: data, encoding: .utf8) {
        //print("POST to \(collection) successful")
        print ("got data: \(dataString)")
        return
        //dataString is of form:
        /*
         {"documentId":"58171bbd-cd42-4c54-a5f7-ed146097d1dc"}
         */
    }
    throw AstraError.postError
}

//posts a userInfo to db
//POST is successful if no error is thrown
func postRequest(userInfo:UserInfo) async throws{
    let encoder = JSONEncoder()
    guard let uploadData = try? encoder.encode(userInfo) else {
        throw AstraError.structToDataError//could not convert to type data
    }
    try await postRequest(uploadData: uploadData, collection: "userInfo")
}

//posts an order to db
//POST is successful if no error is thrown
func postRequest(order:Order) async throws{
    let encoder = JSONEncoder()
    guard let uploadData = try? encoder.encode(order) else {
        throw AstraError.structToDataError//could not convert to type data
    }
    try await postRequest(uploadData: uploadData, collection: "orders")
}

func getOrdersWhereTotalIs(total:Double, userName:String) async ->[Order]{
    do {
        let (orders1, _) = try await getAllOrdersForUserNameAsync(userName:userName)
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
    } catch AstraError.getError {
        print("ASTRA GET ERROR CAUGHT")
        return [Order]()
    } catch AstraError.stringToDataError {
        print("Error converting string to DATA")
        return [Order]()
    } catch AstraError.decodeIntoDictionaryError{
        print("Error decoding into dictionary")
        return [Order]()
    } catch {
        print("error")
        return [Order]()
    }
}

//this function is called every time an HTTP request is made
//returns URLRequest which URLSession needs to perform the HTTP request to the server
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

func deleteUserInfoRequest(docID:String) async throws{
    try await deleteRequest(docID: docID, collectionID: "userInfo")
}

func deleteOrderRequest(docID:String) async throws{
    try await deleteRequest(docID: docID, collectionID: "orders")
}

func deleteRequest(docID:String, collectionID:String) async throws{
    let request = httpRequest(httpMethod: "DELETE", endUrl: "/namespaces/\(ASTRA_DB_KEYSPACENAME!)/collections/\(collectionID)/\(docID)")
    let (_, response) = try await URLSession.shared.data(for: request)
    guard let response = response as? HTTPURLResponse,
          response.statusCode == 204 else {
        //successful delete is status code 204
        print("Response error in delete: \(response)")
        if (collectionID=="orders") {
            throw AstraError.deleteOrderError
        } else {
            throw AstraError.deleteUserInfoError
        }
    }
    print("Response status code in delete: \(response.statusCode)")
}
