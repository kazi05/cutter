//
//  TriminProgressPresenter.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 14.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import Foundation

protocol TrimmingProgressPresenterOutput: class {
    
}

class TrimmingProgressPresenter {
    
    // MARK: - Private properties 🕶
    private weak var view: TrimmingProgressView!
    private weak var delegate: TrimmingProgressPresenterOutput!
    private let periods: [VideoPeriod]
    
    // MARK: - Constructor 🏗
    init(view: TrimmingProgressView, periods: [VideoPeriod], delegate: TrimmingProgressPresenterOutput) {
        self.view = view
        self.periods = periods
        self.delegate = delegate
    }
    
    // MARK: - View actions
    func getPeriodsCount() -> Int {
        return periods.count
    }
    
    func getPreiod(at index: Int) -> VideoPeriod {
        return periods[index]
    }
    
    // MARK: - Input methods
    
    
    // MARK: - Output methods
    
}
