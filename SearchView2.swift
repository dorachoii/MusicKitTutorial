import SwiftUI
import MusicKit

struct Item: Identifiable, Hashable {
    var id = UUID()
    let name: String
    let artist: String
    let artwork: Artwork?
}

struct SearchView: View {
    @State var albums = [Item]()

    var body: some View {
        NavigationView {
            VStack {
                Text("실리카겔 검색 결과")
                    .font(.title3)
                    .padding(.top)
                
                List(albums) { album in
                    HStack {
                        if let artwork = album.artwork {
                            ArtworkImage(artwork, width: 75, height: 75)
                        }
                        VStack(alignment: .leading) {
                            Text(album.name)
                                .font(.title3)
                            Text(album.artist)
                                .font(.footnote)
                        }
                        .padding()
                    }
                }
                .onAppear {
                    searchAlbums()
                }
            }
        }
    }

    private func searchAlbums() {
        Task {
            do {
                var request = MusicCatalogSearchRequest(term: "Silicagel", types: [Album.self])
                request.limit = 25

                let response = try await request.response()
                let albums = response.albums.map { album in
                    Item(name: album.title, artist: album.artistName, artwork: album.artwork)
                }
                self.albums = albums
            } catch {
                print("Error fetching albums: \(error)")
            }
        }
    }
}

#Preview {
    SearchView()
}
