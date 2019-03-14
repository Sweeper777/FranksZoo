import DVITutorialView
import UIKit

class TutorialPart {
    var texts: [String] = []
    var views: (HelpGameViewController) -> [UIView]
    var preTutorialMoves: [Move]
    var postTutorialAllowedMove: Move?
    var postTutorialAction: (() -> Void)?
    
    init(texts: [String],
         views: @escaping (HelpGameViewController) -> [UIView],
         preTutorialMoves: [Move] = [],
         postTutorialAllowedMove: Move? = nil,
         postTutorialAction: (() -> Void)? = nil) {
        self.texts = texts
        self.views = views
        self.preTutorialMoves = preTutorialMoves
        self.postTutorialAllowedMove = postTutorialAllowedMove
        self.postTutorialAction = postTutorialAction
    }
}
