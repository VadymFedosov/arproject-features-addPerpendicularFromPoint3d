//
//  CGPoint+Extension.swift
//  ARTest
//
//  Created by Vadym F on 26.08.2020.
//  Copyright © 2020 Vadym F. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow((point.x - x), 2) + pow((point.y - y), 2))
    }
}
