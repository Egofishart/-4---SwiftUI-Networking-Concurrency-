//
//  ViewModel.swift
//  პრაქტიკული სამუშაო #4 - SwiftUI + Networking + Concurrency (გუნდური)
//
//  Created by NikoDanelia on 27/10/2026.
//
import Foundation
import Combine

@MainActor
class PostsViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let apiClient: APIClientProtocol
    
   
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    func loadPosts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.posts = try await apiClient.fetchPosts()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
