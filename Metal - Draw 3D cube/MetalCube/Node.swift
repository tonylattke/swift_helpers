//
//  Node.swift
//  MetalCube
//
//  Created by Student on 24.11.16.
//  Copyright © 2016 Student. All rights reserved.
//

import Foundation
import Metal
import QuartzCore

class Node {
    
    let name: String
    var vertexCount: Int
    var vertexBuffer: MTLBuffer
    var device: MTLDevice
    
    var uniformBuffer: MTLBuffer?
    
    var positionX:Float = 0.0
    var positionY:Float = 0.0
    var positionZ:Float = 0.0
    
    var rotationX:Float = 0.0
    var rotationY:Float = 0.0
    var rotationZ:Float = 0.0
    var scale:Float     = 1.0
    
    var time:CFTimeInterval = 0.0
    
    // Init
    init(name: String, vertices: Array<Vertex>, device: MTLDevice){
        var vertexData = Array<Float>()
        for vertex in vertices{
            vertexData += vertex.floatBuffer()
        }
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize)
        
        self.name = name
        self.device = device
        vertexCount = vertices.count
    }
    
    // Render Scene
    func render(commandQueue: MTLCommandQueue, depthStencilState: MTLDepthStencilState, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable, renderPassDescriptor: MTLRenderPassDescriptor, parentModelViewMatrix: Matrix4, projectionMatrix: Matrix4, commandBuffer: MTLCommandBuffer){
        
        // Create and setting a Render Command Encoder
        let renderEncoderOpt = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoderOpt.setCullMode(MTLCullMode.front)
        renderEncoderOpt.setRenderPipelineState(pipelineState)
        renderEncoderOpt.setDepthStencilState(depthStencilState)
        renderEncoderOpt.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        
        // Set memory buffer
        let nodeModelMatrix = self.modelMatrix()
        nodeModelMatrix.multiplyLeft(parentModelViewMatrix)
        uniformBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * Matrix4.numberOfElements() * 2)
        let bufferPointer = uniformBuffer?.contents()
        memcpy(bufferPointer!, nodeModelMatrix.raw(), MemoryLayout<Float>.size*Matrix4.numberOfElements())
        memcpy(bufferPointer! + MemoryLayout<Float>.size*Matrix4.numberOfElements(), projectionMatrix.raw(), MemoryLayout<Float>.size*Matrix4.numberOfElements())
        renderEncoderOpt.setVertexBuffer(self.uniformBuffer, offset: 0, at: 1)

        // Draw primitives
        renderEncoderOpt.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount/3)
        renderEncoderOpt.endEncoding()
        
        // Commit your Command Buffer
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func modelMatrix() -> Matrix4 {
        let matrix = Matrix4()
        matrix!.translate(positionX, y: positionY, z: positionZ)
        matrix!.rotateAroundX(rotationX, y: rotationY, z: rotationZ)
        matrix!.scale(scale, y: scale, z: scale)
        return matrix!
    }
    
    func updateWithDelta(delta: CFTimeInterval){
        time += delta
    }
}
