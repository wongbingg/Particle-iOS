//
//  SearchViewController.swift
//  Particle
//
//  Created by 이원빈 on 2023/07/18.
//

import RIBs
import RxSwift
import UIKit

protocol SearchPresentableListener: AnyObject {
    func requestSearch(_ text: String) -> 
}

final class SearchViewController: UIViewController, SearchPresentable, SearchViewControllable {

    weak var listener: SearchPresentableListener?
    
    private var tags: [(title: String, isSelected: Bool)] = {
        let tags = [
            "UX/UI",
            "브랜드",
            "트렌드",
            "서비스기획",
            "그로스마케팅"
            ]
        return tags.map { ($0, false) }
    }()
    
    var disposeBag = DisposeBag()
    
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
        
        Observable.of([
        "최근 검색어어어어",
        "최근 검색어어어어",
        "최근 검색어어어어",
        "최근 검색어어어어",
        "최근 검색어어어어"
        ])
        .bind(to: mainView.recentSearchList.rx.items(
            cellIdentifier: SearchListCell.defaultReuseIdentifier,
            cellType: SearchListCell.self)
        ) { tableView, item, cell in
            cell.bind(item)
        }
        .disposed(by: disposeBag)
        
        Observable.of(tags)
            .bind(to: mainView.tagCollectionView.rx.items(
            cellIdentifier: LeftAlignedCollectionViewCell.defaultReuseIdentifier,
            cellType: LeftAlignedCollectionViewCell.self
        )) { collectionView, item, cell in
            cell.titleLabel.text = item.title
        }
            .disposed(by: disposeBag)
        
        mainView.tagCollectionView.rx.itemSelected
            .subscribe { [weak self] indexPath in
            guard let self = self else { return }
            guard let index = indexPath.element else { return }
                guard let selectedCell = self.mainView.tagCollectionView.cellForItem(at: index) as? LeftAlignedCollectionViewCell else {
                return
            }
            selectedCell.setSelected()
            self.tags[index.row].isSelected.toggle()
        }
        .disposed(by: disposeBag)
        
        Observable<Bool>.merge([
            mainView.searchBar.rx.textDidBeginEditing
                .map { _ in true }
                .asObservable(),
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
    }
    
    private func setupInitialView() {
        mainView.backgroundColor = .particleColor.black
        navigationController?.isNavigationBarHidden = true
    }
    
    func showSearchResult() {
        mainView.recentSearchView.isHidden = true
        mainView.searchResultView.isHidden = false
    }
    
    func hiddenSearchResult() {
        mainView.recentSearchView.isHidden = false
        mainView.searchResultView.isHidden = true
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
