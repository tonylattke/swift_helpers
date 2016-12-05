//
//  Vertex.swift
//  MetalCube
//
//  Created by Student on 24.11.16.
//  Copyright © 2016 Student. All rights reserved.
//

struct Vertex{
    
    var x,y,z: Float     // position data
    var r,g,b,a: Float   // color data
    
    func floatBuffer() -> [Float] {
        return [x,y,z,r,g,b,a]
    }
    
};
