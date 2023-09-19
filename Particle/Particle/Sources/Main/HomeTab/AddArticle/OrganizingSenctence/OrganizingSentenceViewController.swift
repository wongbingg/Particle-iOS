//
//  OrganizingSentenceViewController.swift
//  Particle
//
//  Created by Sh Hong on 2023/07/11.
//

import RIBs
import RxSwift
import UIKit
import SnapKit
import RxCocoa

protocol OrganizingSentencePresentableListener: AnyObject {
    func nextButtonTapped(with data: [OrganizingSentenceViewModel])
    func backButtonTapped()
}

final class OrganizingSentenceViewController: UIViewController,
                                              OrganizingSentencePresentable,
                                              OrganizingSentenceViewControllable {
    
    weak var listener: OrganizingSentencePresentableListener?
    private var disposeBag: DisposeBag = .init()
    
    private let organizingViewModels = BehaviorRelay<[OrganizingSentenceViewModel]>(
        value: [
            .init(sentence: "대표문장", isRepresent: false),
            .init(sentence: "일반문장", isRepresent: false),
            .init(sentence: "일반문장일반문장", isRepresent: false),
            .init(sentence: "일반문장일반문장일반문장1", isRepresent: false),
            .init(sentence: "일반문장일반문장일반문장2", isRepresent: false),
        ]
    )
    
    enum Metric {
        enum Title {
            static let topMargin = 12
            static let leftMargin = 20
        }
        
        enum TableView {
            static let topMargin = 23
            static let horizontalMargin = 20
        }
        
        enum NavigationBar {
            static let height: CGFloat = 44
            static let backButtonLeftMargin: CGFloat = 8
            static let nextButtonRightMargin: CGFloat = 8
        }
        
        enum SelectFlag {
            static let verticalInset: CGFloat = 6
            static let horizontalInset: CGFloat = 16
        }
    }
    
    // MARK: - UIComponents
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .semibold)
        label.text = "문장 순서와 대표 문장을 설정하세요"
        label.textColor = .particleColor.gray04
        label.font = .particleFont.generate(style: .ydeStreetB, size: 19)
        label.textColor = .white
        return label
    }()
    
    private let sentenceTableView: UITableView = {
        let table = UITableView()
        table.register(SentenceTableViewCell.self)
        table.backgroundColor = .clear
        table.alwaysBounceVertical = false
        table.rowHeight = UITableView.automaticDimension
        table.separatorColor = .clear
        table.estimatedRowHeight = 50
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    private let navigationBar: UIView = {
        let view = UIView()
        view.backgroundColor = .particleColor.black
        return view
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        button.setImage(.particleImage.backButton, for: .normal)
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.setTitleColor(.particleColor.gray03, for: .disabled)
        button.setTitleColor(.particleColor.main100, for: .normal)
        return button
    }()
    
    // MARK: - Initializers
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .fullScreen
        self.view.backgroundColor = .particleColor.black
        addSubviews()
        setConstraints()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewLifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialView()
    }
    
    // MARK: - Methods
    
    private func setupInitialView() {
        nextButton.isEnabled = false
    }
    
    private func bind() {
        
        organizingViewModels
            .bind(to: sentenceTableView.rx.items(
                cellIdentifier: SentenceTableViewCell.defaultReuseIdentifier,
                cellType: SentenceTableViewCell.self)
            ) { index, item, cell in
                cell.setCellData(item)
            }
            .disposed(by: disposeBag)
        
        sentenceTableView.rx.itemSelected.subscribe { [weak self] index in
            guard let self = self,
                  let index = index.element else { return }
            
            let list = self.organizingViewModels.value
            
            var newList = [OrganizingSentenceViewModel]()
            list.enumerated().forEach { (i, item) in
                newList.append(
                    OrganizingSentenceViewModel(sentence: item.sentence,
                                                isRepresent: i == index.row)
                )
            }
            
            self.organizingViewModels.accept(newList)
            
            if self.nextButton.isEnabled == false {
                self.nextButton.isEnabled = true
            }
        }
        .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .bind { [weak self] in
                self?.listener?.nextButtonTapped(
                    with: self?.organizingViewModels.value ?? []
                )
                // TODO: isMain 의 여부를 알려주기 위해 다음화면에 organizingViewModel 을 전달.
                // organizingRepository 에 적용
            }
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .bind { [weak self] in
                self?.listener?.backButtonTapped()
            }
            .disposed(by: disposeBag)
    }
    
    func setUpData(with viewModels: [OrganizingSentenceViewModel]) {
        organizingViewModels.accept(viewModels)
    }
}

// MARK: - Layout Settings

private extension OrganizingSentenceViewController {
    
    func addSubviews() {
        [backButton, nextButton]
            .forEach {
                navigationBar.addSubview($0)
            }
        
        [
            navigationBar,
            titleLabel,
            sentenceTableView
        ]
            .forEach {
                self.view.addSubview($0)
            }
        
    }
    
    func setConstraints() {
        navigationBar.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(Metric.NavigationBar.height)
        }
        
        backButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(Metric.NavigationBar.backButtonLeftMargin)
        }
        
        nextButton.snp.makeConstraints { make in
            make.width.equalTo(52)
            make.height.equalTo(44)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(Metric.NavigationBar.nextButtonRightMargin)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(Metric.Title.topMargin)
            make.left.equalTo(self.view.safeAreaLayoutGuide).inset(Metric.Title.leftMargin)
        }
        
        sentenceTableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(Metric.TableView.topMargin)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: - Preview
#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct OrganizingSentenceViewController_Preview: PreviewProvider {
    
    static var previews: some View {
        OrganizingSentenceViewController().showPreview()
    }
}
#endif
