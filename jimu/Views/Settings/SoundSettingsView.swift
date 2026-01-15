//
//  SoundSettingsView.swift
//  jimu
//
//  Created by Jimu Team on 15/1/2026.
//

import SwiftUI
import AudioToolbox

struct SoundSettingsView: View {
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("selectedSoundID") private var selectedSoundID = 1000
    
    // System Sound IDs
    // 参考: http://iphonedevwiki.net/index.php/AudioServices
    private let sounds: [(id: Int, name: String)] = [
        (1000, "デフォルト (New Mail)"),
        (1001, "Mail Sent"),
        (1002, "Voicemail"),
        (1003, "Received Message"),
        (1004, "Sent Message"),
        (1016, "Tweet Sent"),
        (1022, "Calendar Alert"),
        (1025, "Fanfare"),
        (1057, "PIN Code Correct"),
        (1103, "Horn"),
        (1104, "Tock"),
        (1304, "Alert Tone")
    ]
    
    var body: some View {
        List {
            Section {
                Toggle("サウンド効果を有効にする", isOn: $soundEnabled)
            }
            
            if soundEnabled {
                Section(header: Text("効果音を選択")) {
                    ForEach(sounds, id: \.id) { sound in
                        Button(action: {
                            selectedSoundID = sound.id
                            playSound(id: SystemSoundID(sound.id))
                        }) {
                            HStack {
                                Text(sound.name)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedSoundID == sound.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("サウンド設定")
    }
    
    private func playSound(id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
    }
}

#Preview {
    NavigationStack {
        SoundSettingsView()
    }
}

