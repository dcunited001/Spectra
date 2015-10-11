//
//  NodeResource.swift
//  Pods
//
//  Created by David Conner on 10/11/15.
//
//

typealias NodeResourceMap = [String:NodeResource]
typealias NodeResourceDataWriteBlock = () -> Void
typealias NodeResourceDataWriteMap = [String:NodeResourceDataWriteBlock]
typealias NodeResourceInputParamMap = [String:InputParams]
typealias NodeResourceInputDataMap = [String:EncodableData]

typealias EncodableDataMap = [String:EncodableData]

protocol NodeResource {
    // to store a node's copy of the data
}

//protocol Vertexable {
//    
//}

//protocol EncodableData {
//   //to store the encoder's copy of the data
// }
