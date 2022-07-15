# Sample Swift IOS app using Datastax Astra's Document API.

### Contributor:
[Victor Micha](https://github.com/vmic2002), Datastax Polaris Intern

### Objective:
Build an app in Swift that connects to the Datastax Astra Database. By replicating this project, you will have an IOS app with fully functional backend and frontend.

## About:
This sample app is coded in Swift and was developed on the XCode IDE. It connects to the Astra DB using the Document API. It handles user accounts (signing up, deleting accounts, signing in, and changing password) as well as manually entering an order, taking a picture of the receipt to post an order, and seeing all past orders. GroceryHandler is an application for facilitating the accounting of splitting expenses with others. For example, if roommates buy groceries together in one order, this app would be able to indicate how much each person owes the buyer.

## Prerequisites:
1. [Create an Astra database account:](https://auth.cloud.datastax.com/auth/realms/CloudUsers/login-actions/registration?client_id=auth-proxy&tab_id=sbXNIWyPYDw&redirect_uri=https://astra.datastax.com/welcome)
![](READMEPictures/Screen%20Shot%202022-07-13%20at%2011.08.20%20AM.png)
2. After verifying the account, click on *Create Database*:
![](READMEPictures/Screen%20Shot%202022-07-13%20at%2010.52.43%20AM.png)
3. Enter a database name, keyspace name, and region. Name them whatever you like. Then click on *Create Database*
![](READMEPictures/Screen%20Shot%202022-07-13%20at%2010.57.15%20AM.png)
4. Click on *Go To Database*
![](READMEPictures/Screen%20Shot%202022-07-13%20at%2011.01.41%20AM.png)
5. In the dashboard, click on the *Connect* tab:
![](READMEPictures/Screen%20Shot%202022-07-13%20at%2011.04.35%20AM.png)
6. Create an application token:
![](READMEPictures/Screen%20Shot%202022-07-13%20at%2011.09.38%20AM.png)
7. Select the role *Administrator User* then click on *Generate Token*
![](READMEPictures/Screen%20Shot%202022-07-13%20at%2011.20.17%20AM.png)
8. Make sure to copy the *Token* somewhere for later
![](READMEPictures/Screen%20Shot%202022-07-13%20at%2011.23.58%20AM.png)
9. Finally, [Download XCode](
https://developer.apple.com/xcode/).
The XCode version for this application is version 13.4.1.



## How to replicate project:
See -> [Prerequisites first](https://github.com/vmic2002/GroceryHandler#prerequisites)

Go to the directory where you would like your project to reside. Clone the project by running:
```bash
$ git clone https://github.com/vmic2002/GroceryHandler.git
```
This is all that is needed to strictly connect to the database. However, the sample app uses ML Kit Text Recognition API to decipher prices from receipts. The Pods required for this are too big to be stored on Github, so either follow the steps to integrate them in your project by [clicking here](https://github.com/vmic2002/GroceryHandler#integrate-pods-in-project) or remove them from project by [clicking here](https://github.com/vmic2002/GroceryHandler#remove-pods-from-project).
#### Integrate Pods in Project:
1. In the same window, go to your project directory by running 
```bash
$ cd GroceryHandler
```
2. To install CocoaPods, run: 
```bash
$ sudo gem install cocoapods
```
3. To edit the Podfile, run:
```bash
$ vim Podfile
```
Under  
```
# Pods for <APP_NAME>
```
add (it should already be there):
```
pod 'GoogleMLKit/TextRecognition','2.2.0'
```
4. To install the Pods directory, exit the Podfile and run:
```bash
$ pod install
```

![](READMEPictures/Screen%20Shot%202022-06-30%20at%204.44.02%20PM.png)

Now the pods are installed and the project will build once opened on XCode!

#### Remove Pods from project:
1. After cloning the git repo, go to your project directory by running:
```bash
$ cd GroceryHandler
```
2. Run these commands to remove the pods from the project:
```bash
$ sudo gem install cocoapods-deintegrate cocoapods-clean
$ pod deintegrate
$ pod cache clean --all
$ rm Podfile
```
3. Make sure to comment out the *MLTextRecognizer.swift* file once you are in XCode because the import statements will cause problems if the Pods were deleted successfully

### !! Whether you chose to remove the Pods or keep them, now follow the following steps !!


Launch the XCode app and select *Open a project or file*
![](READMEPictures/Screen%20Shot%202022-06-30%20at%204.45.29%20PM.png)

Click on the *GroceryHandler.xcworkspace* file and select *Open*
![](READMEPictures/Screen%20Shot%202022-06-30%20at%204.46.19%20PM.png)



Build the project and run the app by clicking the big play button at the top left of the XCode window. [Click here](https://developer.apple.com/documentation/xcode/running-your-app-in-the-simulator-or-on-a-device) or [here](https://www.twilio.com/blog/2018/07/how-to-test-your-ios-application-on-a-real-device.html) to run it on your personal device. You will need a [cable that connects to your laptop](https://www.apple.com/shop/product/MQGH2AM/A/usb-c-to-lightning-cable-2-m). 

## How to connect to your own database in the app:
If you would like to connect to your Astra DB from this app, you will need to change these environment variables in XCode:
```
ASTRA_DB_ID, ASTRA_DB_REGION, ASTRA_DB_TOKEN
```
The *ASTRA_DB_ID* can be found in the dashboard of the astra website:
![](READMEPictures/Screen%20Shot%202022-07-13%20at%204.17.34%20PM.png)

To change the values of the environment variables in XCode, first click on *Edit Scheme...*
![](READMEPictures/Screen%20Shot%202022-07-13%20at%209.25.48%20AM.png)

This will open the following window in which you can change the values of the environment variables:
![](READMEPictures/Screen%20Shot%202022-07-13%20at%209.26.16%20AM.png)

The app accesses the environment variables in the *GroceryHandlerApp.swift* file:
```swift
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
```
XCode sets up the environment variables, which means that the app can only be run from XCode. Once you run it on your phone once, the icon will still be in your phone even when it isn't connected to your computer anymore. However, if you click the icon and try to log in or post orders, the app will crash because the environment variables will not be set up.


Now you should create your own collection using Swagger UI:
![](READMEPictures/Screen%20Shot%202022-06-30%20at%204.46.48%20PM.png)

You can access Swagger UI from the Astra website:
![](READMEPictures/Screen%20Shot%202022-07-13%20at%204.39.36%20PM.png)

To create an empty collection named *newCol* in *keyspacename1* for example:
![](READMEPictures/Screen%20Shot%202022-07-13%20at%209.48.09%20AM.png)

The collections for the sample app are named: *userInfo* and *orders*. They are both in the keyspace *keyspacename1*. Make sure to change using search and replace (in the *DBController.swift* file) the *userInfo*, *orders*, and *keyspacename1* to whatever you named them.

### Creating your own model
To customize your app, you will need to come up with a model of what the data will look like in the database.
Here is what the model looks like for a *UserInfo*: (this can be found in the *GroceryHandlerApp.swift* file)
```swift
struct UserInfo : Codable {
    let userName : String
    let password : String
}
```
Here is what the model looks like for an order:
```swift
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
```


The *Codable* makes it so that instances of these structs can be converted to JSON data objects, which is needed to post them to the database.
To be explicitly clear, an *Order* is posted to the collection *orders* and a *UserInfo* is posted to the collection *userInfo*.

## Additional Information

### Sending requests to a server in Swift:
The [JSONEncoder](https://developer.apple.com/documentation/foundation/jsonencoder) class makes it easy to convert a struct into a JSON type which can then be posted to a collection of the Astra DB. The [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) struct and [URLSession](https://developer.apple.com/documentation/foundation/urlsession) class handle the request to the server.

### Using Document API to connect to your Astra DB:
The URL to connect to your Astra db using the Document API is : (this is already in the *DBController.swift* file)
```
https://ASTRA_DB_ID-ASTRA_DB_REGION.apps.astra.datastax.com/api/rest/v2/namespaces/ASTRA_DB_KEYSPACE/collections/{collection-id}
```
Check out the [Astra DB documentation](https://docs.datastax.com/en/astra/docs/develop/dev-with-doc.html) for more information.

### For beginners to Swift: 
[Click here](https://developer.apple.com/tutorials/swiftui)

### For beginners to databases:
Make sure to do some research on HTTP requests, URLs, and JSON.
Being familiar with cURL is always helpful.

### Interested in using the ML in your own app?
[Click here](https://developers.google.com/ml-kit/vision/text-recognition/ios) and/or look at the *MLTextRecognizer.swift* file
