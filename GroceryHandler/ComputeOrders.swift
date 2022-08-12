//
//  ComputeOrders.swift
//  GroceryHandler
//
//  Created by Victor Micha on 8/12/22.
//

import SwiftUI

struct ComputeOrders: View {
    @State var userName:String
    @State var dict:[String:Double]
    var body: some View {
        VStack{
            Text("Amount owed for \(userName)")
                .padding(.bottom, 40)
                .font(.title)
                .foregroundColor(Color(red: 0, green: 0, blue: 0.5))
            ScrollView{
                //ignore warning for the ForEach loop: Non-constant range: argument must be an integer literal
                //because dict.count is constant in this view
                Text("")
                ForEach(0..<dict.count) { value in
                    Text(String(format: "\(dict[dict.index(dict.startIndex, offsetBy: value)].key) owes %.2f to \(userName)", dict[dict.index(dict.startIndex, offsetBy: value)].value))//.2f -> 2 decimal points
                }
            }
            .frame(width: 350, height:550)
            .background(Color(red: 0.3, green: 0.6, blue: 0.8))
            .cornerRadius(15)
            .font(.callout)
            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.9))
            .padding(.bottom, 10)
        }
        .frame(width: 400, height: 800)
        .background(Color(red: 0.67, green: 0.87, blue: 0.9))
    }
}

struct ComputeOrders_Previews: PreviewProvider {
    static var previews: some View {
        ComputeOrders(userName: "userName", dict: [String:Double]())
    }
}
