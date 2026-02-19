//
//  AppIconGenerator.swift
//  GrabRedEnvelope
//
//  Generate app icon using SwiftUI
//

import SwiftUI

struct AppIconGeneratorView: View {
    var body: some View {
        ZStack {
            // Red gradient background
            LinearGradient(
                colors: [Color(red: 0.9, green: 0.1, blue: 0.1), Color(red: 0.7, green: 0.0, blue: 0.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Gold border
            RoundedRectangle(cornerRadius: 228)
                .stroke(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 0.85, green: 0.65, blue: 0.13)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 40
                )
                .padding(30)
            
            // Envelope symbol
            VStack(spacing: 20) {
                // Top decorative element
                Text("福")
                    .font(.system(size: 180, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 1.0, green: 0.7, blue: 0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 4)
                
                // Red envelope shape
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.8, green: 0.0, blue: 0.0))
                    .frame(width: 280, height: 180)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(red: 1.0, green: 0.84, blue: 0.0), lineWidth: 4)
                    )
                    .overlay(
                        // Gold seal/pattern
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.84, blue: 0.0), Color(red: 0.85, green: 0.65, blue: 0.13)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text("🧧")
                                    .font(.system(size: 50))
                            )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .frame(width: 1024, height: 1024)
    }
}

#Preview {
    AppIconGeneratorView()
}
