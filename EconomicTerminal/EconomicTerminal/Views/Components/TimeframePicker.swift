//  TimeframePicker.swift
//  차트 위에 놓이는 1일/1주/1달/1년 기간 선택 세그먼트입니다.

import SwiftUI

struct TimeframePicker: View {
    @Binding var selection: Timeframe

    var body: some View {
        Picker("기간", selection: $selection) {
            ForEach(Timeframe.allCases) { tf in
                Text(tf.rawValue).tag(tf)
            }
        }
        .pickerStyle(.segmented)
    }
}
