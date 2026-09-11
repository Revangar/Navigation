import UIKit
import WebKit

final class YouTubeViewController: UIViewController {

    private struct Video {
        let title: String
        let id: String
    }

    private let videos: [Video] = [
        Video(title: "WKWebView — iOS WebView Tutorial", id: "f3mFrWesbvM"),
        Video(title: "Creating an Instance of AVAudioPlayer", id: "mG9stRAaKIg"),
        Video(title: "Play Music in Your App with Swift", id: "2kflmGGMBOA")
    ]

    private let webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .black
        return webView
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 58
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "YouTube"
        view.backgroundColor = .systemBackground

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "VideoCell")

        setupUI()
        loadVideo(at: 0)
        tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
    }

    private func setupUI() {
        view.addSubview(webView)
        view.addSubview(tableView)

        let aspectConstraint = webView.heightAnchor.constraint(
            equalTo: webView.widthAnchor,
            multiplier: 9.0 / 16.0
        )
        aspectConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            aspectConstraint,
            webView.heightAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor,
                multiplier: 0.45
            ),

            tableView.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadVideo(at index: Int) {
        guard videos.indices.contains(index) else { return }
        let id = videos[index].id

        let html = """
        <!doctype html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
            <style>
                html, body { margin: 0; padding: 0; width: 100%; height: 100%; background: #000; overflow: hidden; }
                iframe { width: 100%; height: 100%; border: 0; }
            </style>
        </head>
        <body>
            <iframe
                src="https://www.youtube.com/embed/\(id)?playsinline=1"
                title="YouTube video player"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                allowfullscreen>
            </iframe>
        </body>
        </html>
        """

        webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube.com"))
    }
}

extension YouTubeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        videos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = videos[indexPath.row].title
        content.image = UIImage(systemName: "play.rectangle.fill")
        cell.contentConfiguration = content
        return cell
    }
}

extension YouTubeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loadVideo(at: indexPath.row)
    }
}
