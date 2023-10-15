//
//  MyRecordListInteractor.swift
//  Particle
//
//  Created by 이원빈 on 2023/09/03.
//

import RIBs
import RxSwift

protocol MyRecordListRouting: ViewableRouting {
    func attachRecordDetail(data: RecordReadDTO)
    func detachRecordDetail()
}

protocol MyRecordListPresentable: Presentable {
    var listener: MyRecordListPresentableListener? { get set }
    
    func setData(with data: [SectionOfRecordDate])
}

protocol MyRecordListListener: AnyObject {
    func myRecordListBackButtonTapped()
}

final class MyRecordListInteractor: PresentableInteractor<MyRecordListPresentable>,
                                    MyRecordListInteractable,
                                    MyRecordListPresentableListener {
    
    private let tag: String
    private let fetchMyRecordsByDateUseCase: FetchMyRecordsByDateUseCase
    private let fetchMyRecordsByTagUseCase: FetchMyRecordsByTagUseCase
    
    private var sortedByRecentRecords: [SectionOfRecordDate] = []
    private var sortedByOldRecords: [SectionOfRecordDate] = []
    
    private var disposeBag = DisposeBag()
    weak var router: MyRecordListRouting?
    weak var listener: MyRecordListListener?

    init(
        presenter: MyRecordListPresentable,
        tag: String,
        fetchMyRecordsByTagUseCase: FetchMyRecordsByTagUseCase,
        fetchMyRecordsByDateUseCase: FetchMyRecordsByDateUseCase
    ) {
        self.tag = tag
        self.fetchMyRecordsByTagUseCase = fetchMyRecordsByTagUseCase
        self.fetchMyRecordsByDateUseCase = fetchMyRecordsByDateUseCase
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        fetchData()
    }

    override func willResignActive() {
        super.willResignActive()
    }
    
    // MARK: - Methods
    
    private func fetchData() {
        
        if tag == "My" {
            fetchAllRecords()
        } else {
            fetchRecordsFromTag()
        }
    }
    
    private func fetchAllRecords() {
        
        fetchMyRecordsByDateUseCase.execute()
            .subscribe { [weak self] result in
                guard let self = self else { return }
                self.sortedByOldRecords = result
                self.sortedByRecentRecords = self.reverseRecords(data: result)
                self.presenter.setData(with: result)
            } onError: { error in
                Console.error(error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    
    private func fetchRecordsFromTag() {
        
        fetchMyRecordsByTagUseCase.execute(tag: tag)
            .subscribe { [weak self] result in
                guard let self = self else { return }
                self.sortedByOldRecords = result
                self.sortedByRecentRecords = self.reverseRecords(data: result)
                self.presenter.setData(with: result)
            } onError: { error in
                Console.error(error.localizedDescription)
            }
            .disposed(by: disposeBag)
    }
    
    private func reverseRecords(data: [SectionOfRecordDate]) -> [SectionOfRecordDate] {
        var newList = [SectionOfRecordDate]()
        for record in data.reversed() {
            newList.append(record.reverseItems())
        }
        return newList
    }
    
    // MARK: - MyRecordListPresentableListener
    
    func myRecordListBackButtonTapped() {
        listener?.myRecordListBackButtonTapped()
    }
    
    func myRecordSorByRecentButtonTapped() {
        self.presenter.setData(with: sortedByRecentRecords)
    }
    
    func myRecordSorByOldButtonTapped() {
        self.presenter.setData(with: sortedByOldRecords)
    }
    
    func myRecordListCellTapped(with data: RecordReadDTO) {
        router?.attachRecordDetail(data: data)
    }
    
    // MARK: - MyRecordListInteractable
    
    func recordDetailCloseButtonTapped() {
        router?.detachRecordDetail()
    }
}
