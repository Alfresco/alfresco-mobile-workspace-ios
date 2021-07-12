//
// Copyright (C) 2005-2021 Alfresco Software Limited.
//
// This file is part of the Alfresco Content Mobile iOS App.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        let config = TimerViewConfig()
        TimerView(config: config)
    }
}

class TimerViewConfig: ObservableObject, Equatable {
    @Published var isStarted = false
    @Published var font = UIFont.systemFont(ofSize: 14)
    @Published var fontColor = UIColor.darkGray
    @Published var roundedBorderColor = UIColor.lightGray
    @Published var borderWidth: CGFloat =  70.0
    @Published var borderHeight: CGFloat = 35.0

    static func == (lhs: TimerViewConfig, rhs: TimerViewConfig) -> Bool {
        return lhs.isStarted == rhs.isStarted
    }
}

struct TimerView: View {
    @State var minutes: Int = 0
    @State var seconds: Int = 0
    @State var timer: Timer?

    @ObservedObject var config: TimerViewConfig
    private let dateFormatter = DateFormatter()

    init(config: TimerViewConfig) {
        dateFormatter.dateFormat = "mm:ss"
        self.config = config
    }

    var body: some View {
        if config.isStarted {
            VStack {
                let date = makeDate(min: minutes,
                                    sec: seconds)
                Text(date, formatter: dateFormatter)
                    .background(RoundedRectangle(cornerRadius: 25,
                                                 style: .continuous)
                                    .fill(Color(config.roundedBorderColor))
                                    .frame(width: config.borderWidth,
                                           height: config.borderHeight))
                    .font(Font(config.font as CTFont))
                    .foregroundColor(Color(config.fontColor))
                    .onAppear() {
                        startTimer()
                    }
                    .onDisappear() {
                        stopTimer()
                        restartTimer()
                    }
            }
        }
    }

    func startTimer() {
        let startDate = Date()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { tempTimer in
            let diffComponents = Calendar.current.dateComponents([.minute, .second],
                                                                 from: startDate,
                                                                 to: Date())
            minutes = diffComponents.minute ?? 0
            seconds = diffComponents.second ?? 0
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func restartTimer() {
        minutes = 0
        seconds = 0
    }

    private func makeDate(min: Int, sec: Int) -> Date {
        let components = DateComponents(minute: min, second: sec)
        return Calendar.current.date(from: components)!
    }
}
