//
//  Models.swift
//  პრაქტიკული სამუშაო #4 - SwiftUI + Networking + Concurrency (გუნდური)
//
//  Created by NikoDanelia on 27/10/2026.
//
import Foundation


struct Post: Codable, Identifiable, Hashable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
}
