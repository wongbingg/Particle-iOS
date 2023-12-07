//
//  SearchViewController.swift
//  Particle
//
//  Created by 이원빈 on 2023/07/18.
//

import RIBs
import RxSwift
import RxCocoa
import UIKit

protocol SearchPresentableListener: AnyObject {
    func requestSearch(_ text: String)
}

final class SearchViewController: UIViewController, SearchPresentable, SearchViewControllable {
    
    weak var listener: SearchPresentableListener?
    
    private var tags: [String] = {
        return [
            "UX/UI",
            "브랜드",
            "트렌드",
            "서비스기획",
            "그로스마케팅"
        ]
    }()
    
    private var disposeBag = DisposeBag()
    private let searchResult = PublishRelay<[SearchResult]>()
    
    private var mainView: SearchMainView {
        return self.view as! SearchMainView
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        title = "검색"
        tabBarItem.image = .particleImage.searchTabIcon
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = SearchMainView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialView()
        
        bind()
    }
    
    private func bind() {
        Observable.of([
            "최근 검색어어어어",
            "최근 검색어어어어",
            "최근 검색어어어어",
            "최근 검색어어어어",
            "최근 검색어어어어"
        ])
        .bind(to: mainView.recentSearchView.recentSearchList.rx.items(
            cellIdentifier: SearchListCell.defaultReuseIdentifier,
            cellType: SearchListCell.self)
        ) { tableView, item, cell in
            cell.bind(item)
        }
        .disposed(by: disposeBag)
        
        Driver.merge([
            mainView.recentSearchView.recentSearchList.rx.modelSelected(String.self).asDriver(),
            mainView.recentSearchView.tagCollectionView.rx.modelSelected(String.self).asDriver()
        ])
        .drive { [weak self] recentData in
            self?.mainView.searchBar.searchTextField.text = recentData
            self?.mainView.searchBar.searchTextField.becomeFirstResponder()
            self?.listener?.requestSearch(recentData)
        }
        .disposed(by: disposeBag)
        
        Observable.of(tags)
            .bind(to: mainView.recentSearchView.tagCollectionView.rx.items(
                cellIdentifier: LeftAlignedCollectionViewCell.defaultReuseIdentifier,
                cellType: LeftAlignedCollectionViewCell.self
            )) { collectionView, item, cell in
                cell.titleLabel.text = item
            }
            .disposed(by: disposeBag)
        
        Observable<Bool>.merge([
            mainView.searchBar.rx.textDidBeginEditing
                .map { _ in true }
                .asObservable(),
            mainView.searchBar.rx.text.orEmpty.map { $0.isEmpty == false },
            mainView.recentSearchView.recentSearchList.rx.itemSelected.map { _ in true },
            mainView.recentSearchView.tagCollectionView.rx.itemSelected.map { _ in true },
            mainView.searchBar.rx.textDidEndEditing
                .map { _ in false }
                .asObservable()
        ])
        .bind { [weak self] isStart in
            if isStart {
                self?.showSearchResult()
            } else {
                self?.hiddenSearchResult()
            }
        }
        .disposed(by: disposeBag)
        
        mainView.searchBar.rx.searchButtonClicked
            .compactMap { [weak self] in
                self?.mainView.searchBar.text
            }
            .subscribe(onNext: { [weak self] text in
                self?.listener?.requestSearch(text)
            })
            .disposed(by: disposeBag)
        
        searchResult
            .bind(to: mainView.searchResultView.searchResultTableView.rx.items(
                cellIdentifier: SearchListCell.defaultReuseIdentifier,
                cellType: SearchListCell.self
            )) { tableView, item, cell in
                cell.bind(item.title)
            }
            .disposed(by: disposeBag)
        
        searchResult
            .map { $0.isEmpty == true }
            .asDriver(onErrorJustReturn: false)
            .drive { [weak self] isEmpty in
                self?.mainView.searchResultEmptyView.isHidden = (isEmpty == false)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupInitialView() {
        mainView.backgroundColor = .particleColor.black
        navigationController?.isNavigationBarHidden = true
    }
    
    func showSearchResult() {
        mainView.recentSearchView.isHidden = true
        mainView.searchResultView.isHidden = false
        mainView.searchResultEmptyView.isHidden = true
    }
    
    func hiddenSearchResult() {
        mainView.recentSearchView.isHidden = false
        mainView.searchResultView.isHidden = true
        mainView.searchResultEmptyView.isHidden = true
    }
    
    func updateSearchResult(_ result: [SearchResult]) {
        searchResult.accept(result)
    }
}

// MARK: - Preview

#if canImport(SwiftUI) && DEBUG
import SwiftUI
import AuthenticationServices

@available(iOS 13.0, *)
struct SearchViewController_Preview: PreviewProvider {
    static var previews: some View {
        SearchViewController().showPreview()
    }
}
#endif
