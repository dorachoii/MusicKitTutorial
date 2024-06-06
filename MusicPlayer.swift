import Combine
import MusicKit
import SwiftUI

/// A wrapper for `ApplicationMusicPlayer` with convenience methods for playback.
class MusicPlayer: ObservableObject {
    
    // MARK: - Initialization
    
    static let shared = MusicPlayer()
    
    init() {}
    
    // MARK: - Properties
    
    @Published var isPlaying = false
    var playbackStateObserver: AnyCancellable?
    
    private var musicPlayer: ApplicationMusicPlayer {
        let musicPlayer = ApplicationMusicPlayer.shared
        
        // ?????
        if playbackStateObserver == nil {
            playbackStateObserver = musicPlayer.state.objectWillChange
                .sink { [weak self] in
                    self?.handlePlaybackStateDidChange()
                }
        }
        return musicPlayer
    }
    
    private var isPlaybackQueueInitialized = false
    private var playbackQueueInitializationItemID: MusicItemID?
    
    // MARK: - Methods
    
    func togglePlaybackStatus<MusicItemType: PlayableMusicItem>(for item: MusicItemType) {
        if !isPlaying {
            let isPlaybackQueueInitializedForSpecifiedItem = isPlaybackQueueInitialized && (playbackQueueInitializationItemID == item.id)
            if !isPlaybackQueueInitializedForSpecifiedItem {
                let musicPlayer = self.musicPlayer
                setQueue(for: [item])
                isPlaybackQueueInitialized = true
                playbackQueueInitializationItemID = item.id
                
                Task {
                    do {
                        try await musicPlayer.play()
                    } catch {
                        print("Failed to prepare music player to play \(item).")
                    }
                }
            } else {
                Task {
                    try? await musicPlayer.play()
                }
            }
        } else {
            musicPlayer.pause()
        }
    }
    
    func togglePlaybackStatus() {
        if !isPlaying {
            Task {
                try? await musicPlayer.play()
            }
        } else {
            musicPlayer.pause()
        }
    }
    
    // song으로 넘겨줘야함! musicVideo랑 Music을 둘 다 트는 역할 enum(열거형)이기 때문에 song으로 넘겨줘야함!
    func play(_ track: Track, in trackList: MusicItemCollection<Track>?, with parentCollectionID: MusicItemID?) {
        let musicPlayer = self.musicPlayer
        if var specifiedTrackList = trackList {
            specifiedTrackList = [track, track, track]
            setQueue(for: specifiedTrackList, startingAt: track)
        } else {
            setQueue(for: [track])
        }
        isPlaybackQueueInitialized = true
        playbackQueueInitializationItemID = parentCollectionID
        Task {
            do {
                try await musicPlayer.play()
            } catch {
                print("Failed to prepare music player to play \(track).")
            }
        }
    }
    
    private func setQueue<S: Sequence, PlayableMusicItemType: PlayableMusicItem>(
        for playableItems: S,
        startingAt startPlayableItem: S.Element? = nil
    ) where S.Element == PlayableMusicItemType {
        ApplicationMusicPlayer.shared.queue = ApplicationMusicPlayer.Queue(for: playableItems, startingAt: startPlayableItem)
    }
    
    private func handlePlaybackStateDidChange() {
        isPlaying = (musicPlayer.state.playbackStatus == .playing)
    }
    
    func skipToNextEntry() {
            Task {
                do {
                    try await musicPlayer.skipToNextEntry()
                } catch {
                    print("Failed to skip to the next entry: \(error)")
                }
            }
        }
    
}
