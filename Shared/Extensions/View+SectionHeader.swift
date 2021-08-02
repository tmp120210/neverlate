//
//  View.swift
//  Neverlate
//
//  Created by Александр Северюхин on 28.07.2021.
//

import SwiftUI

struct SectionHeader: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 10, weight: .regular))
            .frame(minWidth: 0, idealWidth: .infinity, maxWidth: .infinity, minHeight: 0, idealHeight: 10, maxHeight: .infinity, alignment: .leading)
            .padding(.horizontal)
        
    }
}

extension View {
    func sectionHeader() -> some View{
        self.modifier(SectionHeader())
    }
}

