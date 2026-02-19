//
//  RedEnvelopeActivity.swift
//  GrabRedEnvelope
//
//  SharePlay Activity Definition
//

import Foundation
import GroupActivities

struct RedEnvelopeActivity: GroupActivity {
    static let activityIdentifier = "rkuo.GrabRedEnvelope.activity"
    
    var metadata: GroupActivityMetadata {
        var meta = GroupActivityMetadata()
        meta.title = "🧧 Grab Red Envelopes"
        meta.subtitle = "Compete to grab red envelopes!"
        meta.type = .generic
        return meta
    }
}
