import MultipeerConnectivity

struct GameInfo: Codable {
    let game: Game
    let playerOrder: [MCPeerID : Int]
    
    enum CodingKeys: CodingKey {
        case game
        case playerOrder
    }
    
    init(game: Game, playerOrder: [MCPeerID: Int]) {
        self.game = game
        self.playerOrder = playerOrder
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        game = try container.decode(Game.self, forKey: .game)
        let playerOrderData = try container.decode(Data.self, forKey: .playerOrder)
        playerOrder = NSKeyedUnarchiver.unarchiveObject(with: playerOrderData) as! [MCPeerID : Int]
    }
    
}
