//
//  FireworksView.swift
//  GrabRedEnvelope
//
//  Fireworks particle effect for results screen
//

import SwiftUI

struct FireworksView: View {
    @State private var particles: [FireworkParticle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                        .scaleEffect(particle.scale)
                }
            }
            .onAppear {
                animateFireworks(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func animateFireworks(in size: CGSize) {
        // Launch 3 fireworks at different times
        for burst in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(burst) * 0.4) {
                launchFirework(at: CGPoint(
                    x: size.width * CGFloat.random(in: 0.2...0.8),
                    y: size.height * CGFloat.random(in: 0.1...0.4)
                ))
            }
        }
    }
    
    private func launchFirework(at center: CGPoint) {
        let colors: [Color] = [.red, .yellow, .orange, .pink, .purple, .blue, .green]
        let particleColor = colors.randomElement()!
        
        // Create burst of particles
        for i in 0..<30 {
            let angle = Double(i) * (360.0 / 30.0) * .pi / 180.0
            let distance = CGFloat.random(in: 80...150)
            
            let particle = FireworkParticle(
                x: center.x,
                y: center.y,
                color: particleColor,
                size: CGFloat.random(in: 3...8),
                opacity: 1.0,
                scale: 0.1
            )
            
            particles.append(particle)
            
            // Animate explosion
            withAnimation(.easeOut(duration: 1.0)) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].x = center.x + cos(angle) * distance
                    particles[index].y = center.y + sin(angle) * distance
                    particles[index].scale = 1.0
                }
            }
            
            // Fade out
            withAnimation(.easeIn(duration: 0.5).delay(0.5)) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].opacity = 0
                }
            }
        }
        
        // Clean up
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            particles.removeAll()
        }
    }
}

struct FireworkParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var color: Color
    var size: CGFloat
    var opacity: Double
    var scale: CGFloat
}
