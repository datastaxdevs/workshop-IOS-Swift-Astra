# Sample Swift IOS app using Datastax Astra's Document API

### Contributor:
[Victor Micha](https://github.com/vmic2002), Datastax Polaris Intern

### Objective:
Build an app in Swift that connects to the Datastax Astra Database. By replicating this project, you will have an IOS app with fully functional backend and frontend.

## About:
This sample app is coded in Swift and was developed on the Xcode IDE. It connects to the Astra DB using the Document API. It handles user accounts (signing up, deleting accounts, signing in, and changing password) as well as manually entering an order, taking a picture of the receipt to post an order, and seeing all past orders. GroceryHandler is an application for facilitating the accounting of splitting expenses with others. For example, if roommates buy groceries together in one order, this app would be able to indicate how much each person owes the buyer.

## For beginners:

If you are new to databases, [click here](https://github.com/datastaxdevs/workshop-IOS-Swift-Astra#for-beginners-to-databases).
If you are new to the Document API, [click here](https://github.com/datastaxdevs/workshop-IOS-Swift-Astra#intro-to-document-api).

## Prerequisites:
1. [Download Xcode](
https://developer.apple.com/xcode/).
The Xcode version for this application is version 13.4.1.
It will take a while to download. While this is happening, move on to the next step.
2. [Create an Astra database account:](https://auth.cloud.datastax.com/auth/realms/CloudUsers/login-actions/registration?client_id=auth-proxy&tab_id=sbXNIWyPYDw&redirect_uri=https://astra.datastax.com/welcome)
![](READMEPictures/Screen%20Shot%202022-07-13%20at%2011.08.20%20AM.png)
3. After verifying the account, click on *Create Database*:
![](READMEPictures/Screen%20Shot%202022-07-13%20at%2010.52.43%20AM.png)
4. Enter a database name, keyspace name, and region. Name them whatever you like. Then click on *Create Database*
![](READMEPictures/Screen%20Shot%202022-07-13%20at%2010.57.15%20AM.png)
5. Click on *Go To Database*
![](READMEPictures/Screen%20Shot%202022-07-13%20at%2011.01.41%20AM.png)
6. In the dashboard, click on the *Connect* tab:
![](READMEPictures/Screen%20Shot%202022-07-13%20at%2011.04.35%20AM.png)
7. Create an application token:
![](READMEPictures/Screen%20Shot%202022-07-13%20at%2011.09.38%20AM.png)
8. Select the role *Administrator User* then click on *Generate Token*
![](READMEPictures/Screen%20Shot%202022-07-13%20at%2011.20.17%20AM.png)
9. Make sure to copy the *Token* somewhere for later
![](READMEPictures/Screen%20Shot%202022-07-13%20at%2011.23.58%20AM.png)


## How to replicate project:
See -> [Prerequisites first](https://github.com/datastaxdevs/workshop-IOS-Swift-Astra#prerequisites)

Go to the directory where you would like your project to reside. If you are not sure what this means, open your Terminal app:

![](READMEPictures/Screen%20Shot%202022-07-18%20at%203.18.37%20PM.png)

If you want your project to reside in your `Desktop` sub-directory for example, type (do not include $):

```bash
$ cd Desktop
```

Clone the project by running:

```bash
$ git clone https://github.com/datastaxdevs/workshop-IOS-Swift-Astra.git
```

This is all that is needed to strictly connect to the database. However, the sample app uses ML Kit Text Recognition API to decipher prices from receipts. 

The Pods required for this are too big to be stored on Github, so either follow the steps to integrate them in your project by [clicking here](https://github.com/datastaxdevs/workshop-IOS-Swift-Astra#integrate-pods-in-project) or remove them from project by [clicking here](https://github.com/datastaxdevs/workshop-IOS-Swift-Astra#remove-pods-from-project).

#### Integrate Pods in Project:
1. In the same window, go to your project directory by running 

```bash
$ cd workshop-IOS-Swift-Astra
```

2. To install CocoaPods, run (if a password is required, use the one you use to log in to your laptop):

```bash
$ sudo gem install cocoapods
```

3. To install the Pods directory, run:

```bash
$ pod install
```

Now the pods are installed and the project will build once opened on Xcode!

#### Remove Pods from project:
1. After cloning the git repo, go to your project directory by running:

```bash
$ cd workshop-IOS-Swift-Astra
```

2. Run these commands to remove the pods from the project (if a password is required, use the one you use to log in to your laptop):

```bash
$ sudo gem install cocoapods-deintegrate cocoapods-clean
$ pod deintegrate
$ pod cache clean --all
$ rm Podfile
```

3. Make sure to comment out the whole *MLTextRecognizer.swift* file once you are in Xcode because the import statements will cause problems if the Pods were deleted successfully. Also comment out this line in the *PictureReceipt.swift* file:

```swift
getPricesAsArray(image: image)
```

### !! Whether you chose to remove the Pods or keep them, now follow the following steps !!


1. Launch the Xcode app and select *Open a project or file*
![](READMEPictures/Screen%20Shot%202022-06-30%20at%204.45.29%20PM.png)

2. Click on the *GroceryHandler.xcworkspace* file and select *Open*
![](READMEPictures/Screen%20Shot%202022-07-18%20at%2011.24.10%20AM.png)

3. Now make sure the project builds successfully by doing <kbd>command</kbd> + <kbd>B</kbd> in Xcode.

4. To test the app, you will have to change the environment variables in Xcode and create the collections *orders* and *userInfo*. The instructions can be found [here](https://github.com/datastaxdevs/workshop-IOS-Swift-Astra#how-to-connect-to-your-own-database-in-the-app).

5. Make sure that the app will run on the iPhone 13 Pro Simulator:
![](READMEPictures/Screen%20Shot%202022-07-19%20at%201.36.11%20PM.png)

6. Build the project and run the app by clicking the big play button at the top left of the Xcode window or by doing <kbd>command</kbd> + <kbd>R</kbd>.
An iPhone Simulator window should pop up:
![](READMEPictures/Screen%20Shot%202022-07-20%20at%2011.20.18%20AM.png)

[Click here](https://developer.apple.com/documentation/xcode/running-your-app-in-the-simulator-or-on-a-device) or [here](https://www.twilio.com/blog/2018/07/how-to-test-your-ios-application-on-a-real-device.html) to run it on your personal device instead. You will need a [cable that connects to your laptop](https://www.apple.com/shop/product/MQGH2AM/A/usb-c-to-lightning-cable-2-m).

That's it! You can now create accounts and post orders to your database! If you would like to populate your database with fake accounts and random orders, uncomment the DEV button in the *ContentView.swift* file by removing the */** and **/* that surrounds this code:
```swift
Button("DEV"){
    print("DEV")
    //This is where you can test functions by running the app and clicking on this button
    populateUserInfoDB()
    populateOrdersDB(numNewOrders: 500)
}
.buttonStyle(CustomButton(color:Color(red: 0, green: 0, blue: 0.5)))
.padding(.all, 20)
```
Run the app on your phone and click this button!
                     


## How to connect to your own database in the app:
If you would like to connect to your Astra DB from this app, you will need to change these environment variables in Xcode:
```
ASTRA_DB_ID, ASTRA_DB_REGION, ASTRA_DB_TOKEN, ASTRA_DB_KEYSPACENAME
```
The *ASTRA_DB_ID* can be found in the dashboard of the astra website:
![](READMEPictures/Screen%20Shot%202022-07-13%20at%204.17.34%20PM.png)

To change the values of the environment variables in Xcode, first click on *Edit Scheme...*
![](READMEPictures/Screen%20Shot%202022-07-13%20at%209.25.48%20AM.png)

This will open the following window in which you can change the values of the environment variables:
![](READMEPictures/Screen%20Shot%202022-07-15%20at%204.11.06%20PM.png)

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
public var ASTRA_DB_KEYSPACENAME:String? {
    ProcessInfo.processInfo.environment["ASTRA_DB_KEYSPACENAME"]
}
```
Xcode sets up the environment variables, which means that the app can only be run from Xcode. Once you run it on your phone once, the icon will still be in your phone even when it isn't connected to your computer anymore. However, if you click the icon and try to log in or post orders, the app will crash because the environment variables will not be set up.


Now you should create your own collection using Swagger UI:
![](READMEPictures/Screen%20Shot%202022-06-30%20at%204.46.48%20PM.png)

You can access Swagger UI from the Astra website:
![](READMEPictures/Screen%20Shot%202022-07-13%20at%204.39.36%20PM.png)

To create an empty collection named *newCol* in *keyspacename1* for example:
![](READMEPictures/Screen%20Shot%202022-07-13%20at%209.48.09%20AM.png)

The collections for the sample app are named: *userInfo* and *orders*. They are both in the keyspace *keyspacename1*. If you want to customize the app by creating different collections, make sure to change using search and replace (in the *DBController.swift* file) the *userInfo* and *orders* to whatever you named them.

If you just want to test the app, you will have to create both of these collections in whatever keyspace you created.

The JSON to create the collection *userInfo* is the following:

```json
{"name":"userInfo"}
```
The JSON to create the collection *orders* is the following:

```json
{"name":"orders"}
```

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

### For beginners to Swift: 
[Click here](https://developer.apple.com/tutorials/swiftui)

### Interested in using the ML in your own app?
[Click here](https://developers.google.com/ml-kit/vision/text-recognition/ios) and/or look at the *MLTextRecognizer.swift* file

### Intro to Document API
Using the Document API for Astra means that data is stored in *keyspaces*. A *keyspace* can have multiple *collections* and a *collection* stores a list of *JSON documents*.
The picture below gives a graphical view of how data is stored for this sample app. There is only one *keyspace* and two *collections*. A JSON doc can be identified by its orange color.

![](READMEPictures/Screen%20Shot%202022-07-20%20at%2010.35.16%20AM.png)

Check out the [Astra DB documentation](https://docs.datastax.com/en/astra/docs/develop/dev-with-doc.html) for more information.

### For beginners to databases:
The following will help you become comfortable with HTTP requests, URLs, and JSON.

First off, what does HTTP stand for? From [CodeAcademy](https://www.codecademy.com/article/http-requests):

```
“HTTP stands for Hypertext Transfer Protocol and is used to structure requests and responses over the internet.
 HTTP requires data to be transferred from one point to another over the network.” 
```

The HTTP request methods that we will be using in this app are GET, POST, PATCH, and DELETE.
GET and DELETE are self explanatory. POST is used to persist data to the database and PATCH is used to update data that is already in the database.

To connect to Datastax astra using the Document API, a specific URL is needed:
```
https://ASTRA_DB_ID-ASTRA_DB_REGION.apps.astra.datastax.com/api/rest/v2/namespaces/ASTRA_DB_KEYSPACENAME/collections/{collection-id}
```

The *api/rest* in the URL is what causes the Document API to be called.

This URL might be followed by something called a *Query String*. The URL and query string are separated by a question mark -> ?

We will see an example of a query string in the examples below.

However, an HTTP request is more than just a URL. It is a URL, headers, a request method (GET, POST, DELETE, PATCH), and depending on the request method a JSON body.

We can perform HTTP requests in the terminal app using a command line tool called cURL, or client URL.

Before using cURL, run these commands in your Terminal windown so that you won't have to copy these values more than once:
```bash
export ASTRA_DB_ID=REPLACE_ME
export ASTRA_DB_REGION=REPLACE_ME
export ASTRA_DB_TOKEN=REPLACE_ME
export ASTRA_DB_KEYSPACENAME=REPLACE_ME
```
Make sure the variables were properly exported by running this command:
```bash
printenv | grep ASTRA_DB
```
Or if you want to do it one variable at a time:
```bash
echo $ASTRA_DB_REGION
```

Now let's go through a few examples. 

#### 1. How to GET all orders (max of 20) from the collection *orders* for the username *Andy1*:

Notice that the collection “orders” has to have been created in your database.

Run this command in your Terminal:
```bash
curl -X 'GET' "https://$ASTRA_DB_ID-$ASTRA_DB_REGION.apps.astra.datastax.com/api/rest/v2/namespaces/$ASTRA_DB_KEYSPACENAME/collections/orders?'where=\{"userName":\{"$eq":"Andy1"\}\}'&page-size=20" -H 'accept: application/json' -H "X-Cassandra-Token: $ASTRA_DB_TOKEN"
```

As we can see, the HTTP method (GET), URL, query string, and headers (-H) are all there.

The query string is : 
```
'where=\{"userName":\{"$eq":"Andy1"\}\}'&page-size=20
```

*where* and *page-size* are parameters. The *&* is a query string separator to pass multiple parameters in the URL.

The *page-size=20* is to specify that we want to GET a maximum of 20 orders (page-size cannot be greater than 20).

The header *accept: application/json* is to specify that we are expecting the format of the data to be retrieved to be in JSON format. If you are not familiar with JSON, a quick online research will be enough, it is simply a way of storing information.

The header *X-Cassandra-Token: $ASTRA_DB_TOKEN* is to specify the token generated by the person who created the database for security reasons. Only people with the token will be able to interact with the database.

#### 2. How to GET the user info for the username *Andy1* in the collection *userInfo*:
Notice that the collection *userInfo* has to have been created in your database.

Run this command in your Terminal:
```bash
curl -X 'GET' "https://$ASTRA_DB_ID-$ASTRA_DB_REGION.apps.astra.datastax.com/api/rest/v2/namespaces/$ASTRA_DB_KEYSPACENAME/collections/userInfo?'where=\{"userName":\{"$eq":"Andy1"\}\}'" -H 'accept: application/json' -H "X-Cassandra-Token: $ASTRA_DB_TOKEN"
```

Notice there are only 2 differences between this cURL command and the one from the first example: There is no *page-size* (since there is a max of 1 user info per person no need to specify how many docs we want to retrieve) and the collection-id is changed from *orders* to *userInfo*.

The JSON that is returned is the following:

```json
{"data":{"ec47a067-d0a7-4f3b-8606-966aa39ce8e9":{"password":"itsdrewnow","userName":"Andy1"}}}
```

#### 3. How to POST a new user info with username *testUsername* and password *testPassword* in the *userInfo* collection:

Run this command in your Terminal:
```bash
curl -X 'POST' "https://$ASTRA_DB_ID-$ASTRA_DB_REGION.apps.astra.datastax.com/api/rest/v2/namespaces/$ASTRA_DB_KEYSPACENAME/collections/userInfo" -H 'accept: application/json' -H "X-Cassandra-Token: $ASTRA_DB_TOKEN" -H 'Content-Type: application/json' --data '
    {
        "userName":"testUsername",
        "password":"testPassword"
    }'
```

The main difference between this command and the ones in the other examples is the HTTP method, which is POST.

There is also an additional header *Content-Type: application/json* which is to specify that the data to be persisted to the database is in JSON format. 

The data itself is passed after the *--data*

This cURL command can be used to POST an order as well. All that has to be changed is the collection-id from *userInfo* to *orders* as well as the data itself.

By now you should be able to perform HTTP requests and interact with your Astra Database from the command line. Doing this from a Swift app is very similar so understanding the cURL commands is going to be extremely helpful.

The structs/classes needed to perform HTTP requests from a Swift app are JSONEncoder, URLRequest, and URLSession.

The [JSONEncoder](https://developer.apple.com/documentation/foundation/jsonencoder) class makes it easy to convert a struct into a JSON type which can then be posted to a collection of the Astra DB. The [URLRequest](https://developer.apple.com/documentation/foundation/urlrequest) struct and [URLSession](https://developer.apple.com/documentation/foundation/urlsession) class handle the request to the server.

Check out the [Astra DB documentation](https://docs.datastax.com/en/astra/docs/develop/dev-with-doc.html) for more information and lots more examples of using cURL to connect to your database using the Document API.

Good luck!
