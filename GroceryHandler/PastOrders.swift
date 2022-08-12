//
//  PastOrders.swift
//  GroceryHandler
//
//  Created by Victor Micha on 6/22/22.
//

import SwiftUI

struct PastOrders: View {
    @State var userName:String
    @State var sorted:[Order]
    @State private var dict = [String:Double]()
    @State private var computeOrders = false
    var body: some View {
        VStack{
            if (sorted.count==1){
                Text("1 order for \(userName)")
                    .padding(.bottom, 40)
                    .font(.title)
                    .foregroundColor(Color(red: 0, green: 0, blue: 0.5))
            } else {
                Text("\(sorted.count) orders for \(userName)")
                    .padding(.bottom, 40)
                    .font(.title)
                    .foregroundColor(Color(red: 0, green: 0, blue: 0.5))
            }
            ScrollView{
                Text("")
                //ignore warning for the ForEach loop: Non-constant range: argument must be an integer literal
                //because sorted.count is constant in this view
                ForEach(0..<sorted.count) { value in
                    Text(getOrderAsString(order:sorted[value]))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(width: 350, height:550)
            .background(Color(red: 0.3, green: 0.6, blue: 0.8))
            .cornerRadius(15)
            .font(.callout)
            .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.9))
            .padding(.bottom, 10)
            
            Button("Compute all past orders"){
                Task{
                    dict = await computeAllOrders(orders: sorted)
                    computeOrders = true
                }
            }
            .buttonStyle(CustomButton(color:Color(red: 0, green: 0, blue: 0.2)))
            NavigationLink(destination: ComputeOrders(userName: userName, dict :dict), isActive: $computeOrders) {EmptyView()}
        }
        .frame(width: 400, height: 800)
        .background(Color(red: 0.67, green: 0.87, blue: 0.9))
    }
}

struct PastOrders_Previews: PreviewProvider {
    static var previews: some View {
        PastOrders(userName:"userName", sorted:[Order(userName: "asd", receipt: [Item(price: 10, users: ["Hello, Hi"])], paid: false, time: "time")])
    }
}
