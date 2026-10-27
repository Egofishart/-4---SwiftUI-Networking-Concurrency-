import SwiftUI

@MainActor
final class PostDetailViewModel: ObservableObject {

    enum State {
        case loading
        case loaded(post: Post, comments: [Comment])
        case failed(message: String)
    }

    @Published private(set) var state: State = .loading

    private let postID: Int
    private let client: APIClientProtocol
    private var hasLoaded = false

    init(postID: Int, client: APIClientProtocol) {
        self.postID = postID
        self.client = client
    }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        await load()
    }

    func load() async {
        state = .loading
        do {
            async let post = client.fetchPost(id: postID)
            async let comments = client.fetchComments(postID: postID)

            let (loadedPost, loadedComments) = try await (post, comments)
            state = .loaded(post: loadedPost, comments: loadedComments)
            hasLoaded = true
        } catch is CancellationError {
        } catch {
            state = .failed(message: error.localizedDescription)
        }
    }
}

struct PostDetailView: View {

    @StateObject private var viewModel: PostDetailViewModel

    init(postID: Int, client: APIClientProtocol = APIClient()) {
        _viewModel = StateObject(
            wrappedValue: PostDetailViewModel(postID: postID, client: client)
        )
    }

    var body: some View {
        content
            .navigationTitle("პოსტი")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadIfNeeded()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("იტვირთება...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed(let message):
            errorView(message: message)

        case .loaded(let post, let comments):
            loadedView(post: post, comments: comments)
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 44))
                .foregroundStyle(.orange)

            Text("ჩატვირთვა ვერ მოხერხდა")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("ხელახლა ცდა") {
                Task { await viewModel.load() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func loadedView(post: Post, comments: [Comment]) -> some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text(post.title)
                        .font(.title2)
                        .bold()

                    Text(post.body)
                        .font(.body)
                }
                .padding(.vertical, 4)

                NavigationLink {
                    UserProfileView(userId: post.userId)
                } label: {
                    Label("ავტორის პროფილი", systemImage: "person.circle")
                }
            }

            Section("კომენტარები (\(comments.count))") {
                if comments.isEmpty {
                    Text("კომენტარები არ არის")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(comments, id: \.id) { comment in
                        CommentRow(comment: comment)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private struct CommentRow: View {
    let comment: Comment

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(comment.name)
                .font(.headline)

            Text(comment.email)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(comment.body)
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        PostDetailView(postID: 1, client: PreviewAPIClient())
    }
}

private struct PreviewAPIClient: APIClientProtocol {
    func fetchPosts() async throws -> [Post] { [] }

    func fetchPost(id: Int) async throws -> Post {
        Post(userId: 1, id: id,
             title: "სატესტო პოსტის სათაური",
             body: "ეს არის პოსტის ტექსტი პრევიუსთვის.")
    }

    func fetchComments(postID: Int) async throws -> [Comment] {
        [
            Comment(postId: postID, id: 1, name: "პირველი კომენტარი",
                    email: "nika@example.com", body: "კარგი პოსტია!"),
            Comment(postId: postID, id: 2, name: "მეორე კომენტარი",
                    email: "ana@example.com", body: "მადლობა გაზიარებისთვის.")
        ]
    }

    func fetchUser(id: Int) async throws -> User {
        throw URLError(.unsupportedURL)
    }

    func fetchPosts(userID: Int) async throws -> [Post] { [] }
}
