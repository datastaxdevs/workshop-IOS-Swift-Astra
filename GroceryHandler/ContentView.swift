//
//  ContentView.swift
//  GroceryHandler
//
//  Created by Victor Micha on 6/13/22.
//

import SwiftUI

struct ContentView: View {
    @State private var userName: String = ""
    @State private var password: String = ""
    @ObservedObject var errorManager:ErrorManager = shared
    @State private var signin = false
    @State private var changePassword = false
    @ObservedObject var goSignedIn:GoToSignedInManager = goToSignedIn
    //https://www.hackingwithswift.com/articles/216/complete-guide-to-navigationview-in-swiftui
    var body: some View {
        NavigationView {
            VStack{
                Text("Welcome to GroceryHandler")
                    .font(.title)
                    .foregroundColor(Color(red: 0, green: 0, blue: 0.5))
                    .multilineTextAlignment(.center)
                    .padding(.top, 70)
                    .padding(.bottom, 30)
                    .frame(height: 70)
                //COULD HAVE IMAGE OF LOGO HERE
                Spacer()
                HStack{
                    TextField("Username:", text: $userName)
                        .textFieldStyle(CustomTextField())
                        .onSubmit(){
                            shared.errorMessage = ""
                        }
                    Spacer()
                }
                HStack{
                    TextField("Password:", text: $password)
                        .textFieldStyle(CustomTextField())
                        .onSubmit(){
                            shared.errorMessage = ""
                        }
                    Spacer()
                }
                Text(shared.errorMessage)
                    .padding(.all, 30)
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundColor(shared.errMsgColor)
                NavigationLink(destination: SignedIn(userName: goSignedIn.userName), isActive: $goSignedIn.goSignedIn) {EmptyView()}
                NavigationLink(destination: SignedIn(userName: userName), isActive: $signin) {EmptyView()}
                Button("Sign in"){
                    if (userName.count==0 || password.count==0){
                        shared.errMsgColor = Color.red
                        shared.errorMessage = "Username and password cannot be empty."
                        return
                    }
                    print("Signing in with \(userName) and \(password)")
                    if (signIn(userName:userName, password:password)){
                        self.signin = true
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.all,20)
                .buttonStyle(CustomButton(color:Color(red: 0, green: 0, blue: 0.2)))
                HStack{
                    Button("Create Account"){
                        if (userName.count==0 || password.count==0){
                            shared.errMsgColor = Color.red
                            shared.errorMessage = "Username and password cannot be empty."
                            return
                        }
                        createAccount(userName: userName, password: password)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.all,5)
                    .buttonStyle(CustomButton(color:Color(red: 0.2, green: 0.5, blue: 0.2)))
                    Button("Delete Account"){
                        if (userName.count==0 || password.count==0){
                            shared.errMsgColor = Color.red
                            shared.errorMessage = "Username and password cannot be empty."
                            return
                        }
                        deleteAccount(userName: userName, password: password)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.all, 5)
                    .buttonStyle(CustomButton(color: Color(red: 0.5, green: 0, blue: 0)))
                    NavigationLink(destination: ChangePassword(userName: userName), isActive: $changePassword) { EmptyView() }
                    Button("Change Password"){
                        if (userName.count==0 || password.count==0){
                            shared.errMsgColor = Color.red
                            shared.errorMessage = "Username and password cannot be empty."
                            return
                        }
                        if (signIn(userName:userName, password:password)){
                            changePassword = true
                        }
                    }
                    .multilineTextAlignment(.center)
                    .padding(.all,5)
                    .buttonStyle(CustomButton(color:Color(red: 0, green: 0, blue: 0.5)))
                    /*Button("DEV"){
                        print("DEV")
                        //This is where you can test functions by running the app and clicking on this button
                        //populateOrdersDB(numNewOrders: 500)
                        //printUserInfoFor(userName:"Andy1")
                     }
                     .buttonStyle(CustomButton(color:Color(red: 0, green: 0, blue: 0.5)))
                     .padding(.all, 20)*/
                }
                Spacer()
            }.background(Color(red: 0.67, green: 0.87, blue: 0.9))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
