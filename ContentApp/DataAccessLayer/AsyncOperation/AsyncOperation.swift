//
// Copyright (C) 2005-2021 Alfresco Software Limited.
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

import Foundation

class AsyncOperation: Operation {
    override func start() {
        guard !isCancelled else {
            asyncFinish()
            return
        }

        setIsExecutingWithKVO(value: true)
        asyncStart()
    }

    /// Override to execute operation async code
    func asyncStart() {}

    /// Call this when the operation is finished
    func asyncFinish() {
        setIsExecutingWithKVO(value: false)
        setIsFinishedWithKVO(value: true)
    }

    override var isAsynchronous: Bool {
        return true
    }

    // MARK: KVO helpers

    private var _isFinished = false
    private var _isExecuting = false

    override var isExecuting: Bool {
        return _isExecuting
    }

    override var isFinished: Bool {
        return _isFinished
    }

    func setIsExecutingWithKVO(value: Bool) {
        willChangeValue(forKey: "isExecuting")
        _isExecuting = value
        didChangeValue(forKey: "isExecuting")
    }

    func setIsFinishedWithKVO(value: Bool) {
        willChangeValue(forKey: "isFinished")
        _isFinished = value
        didChangeValue(forKey: "isFinished")
    }
}
