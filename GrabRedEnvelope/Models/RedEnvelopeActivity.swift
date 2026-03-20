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
        meta.title = String(localized: "shareplay.title")
        meta.subtitle = String(localized: "shareplay.subtitle")
        meta.type = .generic
        return meta
    }
}
