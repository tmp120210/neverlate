//
//  View.swift
//  Neverlate
//
//  Created by Александр Северюхин on 28.07.2021.
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

struct SectionHeader: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 10, weight: .regular))
            .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, minHeight: 0, idealHeight: 10, maxHeight: .infinity, alignment: .leading)
            .padding(.horizontal)
        
    }
}

extension View {
    func rowStyle(backgroundColor: Color) -> some View {
        self.modifier(Row(color: backgroundColor))
    }
    
    func sectionHeader() -> some View{
        self.modifier(SectionHeader())
    }
}

