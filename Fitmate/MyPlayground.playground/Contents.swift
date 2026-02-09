////
////  ProductsViewController.swift
////
////  Live Coding Interview Task
////
//
//import UIKit
//import Foundation
//
//// MARK: - Task Description
///*
// 
// Есть экран со списком продуктов.
// 
// Поведение:
// - Нужно загрузить продукты по массиву categoryIds
// - Каждый categoryId возвращает массив продуктов
// - Ответы приходят асинхронно и в произвольном порядке
// - Если запрос категории завершился ошибкой — её продукты не отображаются
// - Итоговый список должен сохранять порядок categoryIds и порядок продуктов внутри категории
// 
// UI:
// - Список обновляется по мере поступления данных
// - Для каждой картинки сначала показывается лоадер
// - После загрузки картинки ячейка обновляется под размер изображения
// 
// Аналитика:
// - Для каждого продукта отправляется событие просмотра
// - При клике отправляется событие нажатия
// 
// Формат:
// - Можно изменять архитектуру и структуру кода
// - Важно проговаривать найденные проблемы и решения + оптимизация запросов
// 
//*/
//
//// MARK: - Model
//
//final class Product {
//    let id: UUID = UUID()
//    let name: String
//    let imageUrl: String
//
//    init(name: String, imageUrl: String) {
//        self.name = name
//        self.imageUrl = imageUrl
//    }
//}
//
//// MARK: - Analytics
//
//struct Analytics {
//
//    static let shared = Analytics()
//
//    func logView(product: Product) {
//        print("Viewed: \(product.name)")
//    }
//
//    func logClick(product: Product) {
//        print("Clicked: \(product.name)")
//    }
//}
//
//// MARK: - Service
//
//class ProductService {
//
//    func fetchProducts(
//        for categoryId: String,
//        completion: @escaping (Result<[Product], Error>) -> Void
//    ) {
//        let delay = Double.random(in: 1...5)
//        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
//            // Симуляция запроса
//            switch categoryId {
//            case "1":
//                completion(.failure(NSError()))
//            case "2":
//                completion(.success([
//                    Product(name: "iPhone", imageUrl: "https://via.placeholder.com/200"),
//                    Product(name: "MacBook", imageUrl: "https://via.placeholder.com/300")
//                ]))
//            case "3":
//                completion(.success([
//                    Product(name: "Samsung Galaxy", imageUrl: "https://via.placeholder.com/250"),
//                    Product(name: "Amazon Kindle", imageUrl: "https://via.placeholder.com/180"),
//                    Product(name: "Yandex Alisa", imageUrl: "https://via.placeholder.com/220")
//                ]))
//            default:
//                completion(.success([]))
//            }
//        }
//    }
//
//    func loadImage(
//        url: String,
//        completion: @escaping (UIImage?) -> URL
//    ) -> URLSessionTask? {
//
//        guard let url = URL(string: url) else {
//            completion(nil)
//            return nil
//        }
//
//        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
//            let image = data.flatMap { UIImage(data: $0) }
//            completion(image)
//        }
//
//        task.resume()
//        return task
//    }
//}
//
//// MARK: - Cell
//
//final class ProductCell: UITableViewCell {
//
//    static let reuseId = "ProductCell"
//
//    let productImageView = UIImageView()
//    private let loader = UIActivityIndicatorView(style: .medium)
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupUI()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError()
//    }
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        productImageView.image = nil
//        loader.startAnimating()
//    }
//
//    private func setupUI() {
//        productImageView.translatesAutoresizingMaskIntoConstraints = false
//        loader.translatesAutoresizingMaskIntoConstraints = false
//
//        contentView.addSubview(productImageView)
//        contentView.addSubview(loader)
//
//        NSLayoutConstraint.activate([
//            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            productImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
//            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
//            productImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//
//            loader.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            loader.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
//        ])
//    }
//
//    func configure(product: Product) {
//        textLabel?.text = product.name
//    }
//}
//
//// MARK: - View Controller
//
//final class ProductsViewController: UIViewController {
//
//    private let tableView = UITableView()
//    private let service = ProductService()
//
//    private var categoryIds: [String] = []
//    private var products: [Product] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        load(categoryIds: ["2", "3", "1"])
//    }
//
//    func load(categoryIds: [String]) {
//        self.categoryIds = categoryIds
//        self.products.removeAll()
//        
//        var resultProducts = [String: [Product]]()
//        let group = DispatchGroup()
//        
//        for categoryId in categoryIds {
//            group.enter()
//            service.fetchProducts(for: categoryId) { [weak self] result in
//                defer { group.leave() }
//                switch result {
//                case .success(let products):
//                    resultProducts[categoryId] = products
//                case .failure(let failure):
//                    print(failure.localizedDescription)
//                }
//            }
//        }
//        
//        group.notify(queue: .main) { [weak self] in
//            guard let self else { return }
//            self.products = categoryIds.compactMap{ resultProducts[$0] }.flatMap { $0 }
//            self.tableView.reloadData()
//        }
//    }
//
//    private func setupUI() {
//        view.backgroundColor = .white
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//
//        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.reuseId)
//        tableView.dataSource = self
//        tableView.delegate = self
//
//        view.addSubview(tableView)
//
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.topAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//    }
//}
//
//// MARK: - Table
//
//extension ProductsViewController: UITableViewDataSource, UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        products.count
//    }
//
//    func tableView(
//        _ tableView: UITableView,
//        cellForRowAt indexPath: IndexPath
//    ) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(
//            withIdentifier: ProductCell.reuseId,
//            for: indexPath
//        ) as! ProductCell
//
//        let product = products[indexPath.row]
//
//        cell.textLabel?.text = product.name
//
//        Analytics.shared.logView(product: product)
//
//        cell.configure(product: product)
//        service.loadImage(url: product.imageUrl) { image in
//            DispatchQueue.main.async { [weak self] in
//                cell.productImageView.image = image
//            }
//        }
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        Analytics.shared.logClick(product: products[indexPath.row])
//    }
//}
//
