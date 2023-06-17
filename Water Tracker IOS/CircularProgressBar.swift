//
//  CircularProgressBar.swift
//  Water Tracker IOS
//
//  Created by Alexander Klann on 17.06.23.
//

import SwiftUI

struct CircularProgressBar: View {
    let progress: Double
    let strokeWidth: CGFloat
    let progressColor: Color
    let backdropColor: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    backdropColor.opacity(0.5),
                    lineWidth: strokeWidth
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progressColor,
                    style: StrokeStyle(
                        lineWidth: strokeWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)
        }
    }
}

struct CircularProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressBar(progress: 0.5, strokeWidth: 5, progressColor: Color.blue, backdropColor: Color.cyan)
    }
}
