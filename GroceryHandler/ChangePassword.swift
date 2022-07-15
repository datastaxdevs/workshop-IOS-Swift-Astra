//
//  ChangePassword.swift
//  GroceryHandler
//
//  Created by Victor Micha on 6/23/22.
//

import SwiftUI

struct ChangePassword: View {
    @State var userName:String
    @State var errMsg = ""
    @State var newPassword:String = ""
    @State var errColor = Color.red
    var body: some View {
        VStack{
            Text("Hey \(userName)!")
                .font(.title)
                .foregroundColor(Color(red: 0, green: 0, blue: 0.5))
                .padding(.top, 70)
            Spacer()
            Text(errMsg)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(errColor)
            TextField("New password here:", text: $newPassword)
                .textFieldStyle(CustomTextField())
            HStack{
                Spacer()
                Button("Change Password"){
                    if (newPassword.count==0){
                        errColor = Color.red
                        errMsg = "New password cannot be empty."
                        return
                    }
                    changePassword(newPassword: newPassword, userName: userName)
                    errColor = Color.green
                    errMsg = "Password changed to \(newPassword)"
                    newPassword = ""
                }
                .buttonStyle(CustomButton(color:Color(red: 0, green: 0, blue: 0.5)))
                .padding(.all, 10)
            }
            Spacer()
        }.background(Color(red: 0.67, green: 0.87, blue: 0.9))
    }
}

struct ChangePassword_Previews: PreviewProvider {
    static var previews: some View {
        ChangePassword(userName:"userName")
    }
}
