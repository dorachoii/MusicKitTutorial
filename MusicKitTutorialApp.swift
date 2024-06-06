//
//  MusicKitTutorialApp.swift
//  MusicKitTutorial
//
//  Created by dora on 5/6/24.
//

import SwiftUI

@main
struct MusicKitTutorialApp: App {
    
    var body: some Scene {
        WindowGroup {
            ZStack{
                SearchView()
                
                VStack{
                    Spacer()
                    MiniPlayerView(isShowingNowPlaying: false)
                        .shadow(radius: 5)
                }
            }
            
        }
    }
}

