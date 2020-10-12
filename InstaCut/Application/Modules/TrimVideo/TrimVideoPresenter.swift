//
//  TrimVideoPresenter.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 12.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import Foundation

class TrimVideoPresenter {
    
    // MARK: - Private properties 🕶
    private weak var view: TrimVideoView!
    private let video: VideoModel
    
    // MARK: - Constructor 🏗
    init(view: TrimVideoView, video: VideoModel) {
        self.view = view
        self.video = video
    }
    
}
