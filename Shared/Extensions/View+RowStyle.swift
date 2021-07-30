//
//  View+RowStyle.swift
//  Neverlate (macOS)
//
//  Created by Александр Северюхин on 29.07.2021.
//

import SwiftUI

struct Row: ViewModifier {
    let color: Color
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, minHeight: 0, idealHeight: 48, maxHeight: 48, alignment: .leading)
            .background(color)
            .cornerRadius(8)
        
    }
}



extension View {
    func rowStyle(backgroundColor: Color) -> some View {
        self.modifier(Row(color: backgroundColor))
    }
}
