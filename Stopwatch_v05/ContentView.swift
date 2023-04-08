//
//  ContentView.swift
//  Stopwatch_v05
//
//  Created by Max Franz Immelmann on 4/7/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var digitalStartTime: TimeInterval?
    @State private var timer: Timer?
    @State private var digitalTimeLabel: String = "00:00.00"
    
    let circleDiameter = UIScreen.main.bounds.width * 0.9

    var body: some View {
        
        let lineWidth = circleDiameter / 100
        let handLength = circleDiameter * 0.85
        
        VStack {
            
            Text(digitalTimeLabel)
                .font(.system(size: 64, design: .monospaced))
                .fontWeight(.regular)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.systemBackground).opacity(0.8))
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.bottom, 50)
            
            Spacer()
            ZStack {
                CircleView(circleDiameter: circleDiameter,
                           lineWidth: lineWidth)
                
                OrangeHand(lineWidth: lineWidth,
                           handLength: handLength,
                           fullSeconds: fullSeconds(),
                           circleDiameter: circleDiameter
                )
            }
            Spacer()
            
            Button(action: {
                if timer == nil {
                    digitalStartTime = Date().timeIntervalSinceReferenceDate
                    timer = Timer.scheduledTimer(withTimeInterval: 0.01,
                                                 repeats: true) { _ in
                        digitalTimeLabel = formattedTime()
                    }
                } else {
                    timer?.invalidate()
                    timer = nil
                }
            }) {
                Text(timer == nil ? "Start" : "Stop")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(25)
            }
            .padding(.bottom, 30)
        }
        .padding()
    }
    
    private func fullSeconds() -> Double {
        guard let startTime = digitalStartTime else { return 0 }
        let currentTime = Date().timeIntervalSinceReferenceDate
        let elapsedTime = currentTime - startTime
        return Double(elapsedTime.truncatingRemainder(dividingBy: 60))
    }
    
    private func formattedTime() -> String {
        guard let startTime = digitalStartTime else { return "00:00.00" }
        let currentTime = Date().timeIntervalSinceReferenceDate
        let elapsedTime = currentTime - startTime
        let minutes = Int(elapsedTime / 60)
        let seconds = Int(elapsedTime) % 60
        let hundredths = Int((elapsedTime.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d",
                      minutes,
                      seconds,
                      hundredths)
    }
}

struct CircleView: View {
    let circleDiameter: CGFloat
    let lineWidth: CGFloat
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: circleDiameter,
                   height: circleDiameter)
        
        ForEach(0..<60, id: \.self) { tick in
            MinuteMark(minute: tick,
                 lineWidth: lineWidth,
                 circleDiameter: circleDiameter)
        }
    }
}

struct MinuteMark: View {
    var minute: Int
    var lineWidth: CGFloat
    var circleDiameter: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(Color.black)
            .frame(width: 2,
                   height: minute % 5 == 0 ? lineWidth * 6 : lineWidth * 3)
            .offset(y: -circleDiameter / 2 + lineWidth * 3)
            .rotationEffect(Angle.degrees(Double(minute) / 60 * 360))
    }
}

struct OrangeHand: View {
    let lineWidth: CGFloat
    let handLength: CGFloat
    var fullSeconds: Double
    let circleDiameter: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: geometry.size.width / 2,
                                      y: geometry.size.height / 2
                                      - handLength / 10))
                path.addLine(to: CGPoint(x: geometry.size.width / 2,
                                         y: handLength))
            }
            .stroke(Color.orange, lineWidth: lineWidth)
            .rotationEffect(Angle.degrees(Double(fullSeconds.truncatingRemainder(dividingBy: 60)) / 60 * 360 + 180), anchor: .center)
        }
        .frame(width: lineWidth * 2, height: handLength)
        
        Circle()
            .fill(Color.orange)
            .frame(width: circleDiameter * 0.04,
                   alignment: .center)
        
        Circle()
            .fill(Color.white)
            .frame(width: circleDiameter * 0.02,
                   alignment: .center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
