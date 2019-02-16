import MultipeerConnectivity

struct GameInfo: Codable {
    let game: Game
    let playerOrder: [MCPeerID : Int]
    
    enum CodingKeys: CodingKey {
        case game
        case playerOrder
    }
    
}
