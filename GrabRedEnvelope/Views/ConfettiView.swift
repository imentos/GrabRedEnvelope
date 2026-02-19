//
//  ConfettiView.swift
//  GrabRedEnvelope
//
//  Confetti particle effect
//

import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                generateParticles(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func generateParticles(in size: CGSize) {
        let centerX = size.width / 2
        let centerY = size.height / 2
        
        for i in 0..<50 {
            let angle = Double(i) * (360.0 / 50.0) * .pi / 180.0
            let distance = CGFloat.random(in: 50...200)
            
            let particle = ConfettiParticle(
                x: centerX + cos(angle) * distance,
                y: centerY + sin(angle) * distance,
                color: [.red, .yellow, .orange, .pink, .purple].randomElement()!,
                size: CGFloat.random(in: 4...12),
                opacity: 1.0
            )
            
            particles.append(particle)
            
            // Animate particle
            withAnimation(.easeOut(duration: 1.0).delay(Double(i) * 0.01)) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].opacity = 0
                    particles[index].y += CGFloat.random(in: 100...300)
                }
            }
        }
        
        // Remove particles after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            particles.removeAll()
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var color: Color
    var size: CGFloat
    var opacity: Double
}
