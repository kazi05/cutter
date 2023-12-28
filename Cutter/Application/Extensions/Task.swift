//
//  Task.swift
//  Cutter
//
//  Created by Гаджиев Казим on 26.12.2023.
//

import Foundation

extension Task where Success == Void, Failure == Never {

    typealias ThrowingOperation = () async throws -> Void
    typealias ErrorHandler = (Error) async -> Void

    /// Creates a throwing task with familiar do-catch-like syntax
    @discardableResult
    static func `do`(
        priority: TaskPriority? = nil,
        throwingOperation: @escaping ThrowingOperation,
        `catch` errorHandler: @escaping ErrorHandler
    ) -> Self {
        
        return Task(priority: priority) {
            do { try await throwingOperation() }
            catch { await errorHandler(error) }
        }
    }
}
