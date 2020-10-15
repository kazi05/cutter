//
//  AsyncOperation.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 15.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {

    enum State: String {
        case ready, executing, finished, cancelled

        fileprivate var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }

    var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }

    override var isAsynchronous: Bool {
        return true
    }

    override var isFinished: Bool {
        return state  == .finished
    }

    override var isCancelled: Bool {
        return state == .cancelled
    }

    override var isExecuting: Bool {
        return state == .executing
    }

    override var isReady: Bool {
        return super.isReady && state == .ready
    }

    override func main() {
        guard !isCancelled else { return }
        state = .executing
    }

    /// Implements force cancel of operation
    func forceStop() {}

    /// Implements pause of operation
    func pauseProcess() {}

    /// Implements resume of operation
    func resumeProcess() {}

    override func start() {
        if isCancelled {
            state = .finished
            return
        }
        state = .ready
        main()
    }

    override func cancel() {
        super.cancel()
        state = .finished
    }

}
