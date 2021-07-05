//
//  ContentView.swift
//  Shared
//
//  Created by Mikhail Filippov on 05.07.2021.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack(){
            VStack() {
                Image("1")
                    .aspectRatio(contentMode: .fill)
                Spacer()
                VStack(spacing: 16.0){
                    Text("Welcome!")
                        .font(.system(size: 22))
                        .fontWeight(.heavy)
                    Text("NeverLate is a perfect app for those who frequently participate in Zoom meetings")
                        .font(.system(size: 18))
                }
                Spacer()
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Text("Continue")
                        .fontWeight(.regular)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Color("lightButton"))
                })
                .cornerRadius(10)
                .buttonStyle(PlainButtonStyle())
            }
            .frame(width: 320, height: 540)
            .padding(.horizontal, 16.0)
            .padding(.vertical, 32.0)
        }.background(Color.white)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
