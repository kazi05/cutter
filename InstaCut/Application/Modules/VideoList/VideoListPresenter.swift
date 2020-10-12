//
//  VideoListPresenter.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import UIKit

protocol VideoListPresenterOutput: class {
    
}

protocol VideoListPresenterInput {
    
}

class VideoListPresenter {
    
    // MARK: - Private properties 🕶
    private weak var view: VideoListView!
    private weak var delegate: VideoListPresenterOutput?
    
    // MARK: - Constructor 🏗
    init(view: VideoListView, delegate: VideoListPresenterOutput?) {
        self.view = view
        self.delegate = delegate
    }
    
    // MARK: - Input methods
    
    
    // MARK: - Output methods
    
    
}

// MARK: - Input methods
extension VideoListPresenter: VideoListPresenterInput {
    
}

