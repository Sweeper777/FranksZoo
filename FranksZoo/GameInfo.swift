import MultipeerConnectivity

struct GameInfo: Codable {
    let game: Game
    let playerOrder: [MCPeerID : Int]
    
}
