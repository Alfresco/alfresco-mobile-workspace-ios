//
// Copyright (C) 2005-2020 Alfresco Software Limited.
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

import UIKit

class TopLevelTransition: NSObject, UIViewControllerAnimatedTransitioning {

    let viewControllers: [UIViewController]?
    let resizeTransitionDuration: TimeInterval = 0.2
    let alphaTransitionDuration: TimeInterval = 0.4

    init(viewControllers: [UIViewController]?) {
        self.viewControllers = viewControllers
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return resizeTransitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let fromView = fromVC.view,
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let toView = toVC.view
            else {
                transitionContext.completeTransition(false)
                return
        }

        fromView.alpha = 0
        let frame = transitionContext.initialFrame(for: fromVC)
        toView.frame = frame
        toView.transform = toView.transform.scaledBy(x: 0.9, y: 0.9)

        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }

            transitionContext.containerView.addSubview(toView)
            toView.layer.fadeAnimation(with: .fadeIn, duration: sSelf.alphaTransitionDuration, completionHandler: nil)

            UIView.animate(withDuration: sSelf.resizeTransitionDuration, animations: {
                toView.transform = .identity
            }, completion: {success in
                fromView.removeFromSuperview()
                fromView.alpha = 1
                transitionContext.completeTransition(success)
            })
        }
    }
}
