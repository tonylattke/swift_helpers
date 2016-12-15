//
//  Camera.swift
//  MetalCube
//
//  Created by Tony Lattke on 24.11.16.
//  Copyright © 2016 Hochschule Bremen. All rights reserved.
//

import Foundation
import simd

class Camera {

    // View Model Matrix
    var viewModelMatrix: float4x4!
    
    // Projection Matrix
    var projectionMatrix: float4x4!
    
    // Frustum
    let angle: Float
    let aspectRatio: Float
    let nearPlan: Float
    let farPlan: Float
    
    // Initalization
    init(position: float3, lookAt: float3, up: float3, aspectRatio: Float, angleDregrees: Float, nearPlan: Float, farPlan: Float) {
        // Set Frustum
        self.angle = float4x4.degrees(toRad: angleDregrees)
        self.aspectRatio = aspectRatio
        self.nearPlan = nearPlan
        self.farPlan = farPlan
        
        // Set Matrix
        viewModelMatrix = float4x4.makeLookAt(position.x, position.y, position.z, lookAt.x, lookAt.y, lookAt.z, up.x, up.y, up.z)
        projectionMatrix = float4x4.makePerspectiveViewAngle(self.angle, aspectRatio: self.aspectRatio, nearZ: self.nearPlan, farZ: self.farPlan)
        
    }
    
    // Get view matrix
    func getViewMatrix() -> float4x4 {
        return viewModelMatrix!
    }
    
    // Get projection matrix
    func getProjectionCamera() -> float4x4 {
        return projectionMatrix
    }
    
    // Update projection matrix
    func projectionMatrixUpdate(aspectRatio: Float){
        let newProjectionMatrix = float4x4.makePerspectiveViewAngle(self.angle,
                                                                    aspectRatio: aspectRatio,
                                                                    nearZ: self.nearPlan,
                                                                    farZ: self.farPlan)
        self.projectionMatrix = newProjectionMatrix
    }
}
