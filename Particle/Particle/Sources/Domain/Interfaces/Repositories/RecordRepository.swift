//
//  RecordRepository.swift
//  Particle
//
//  Created by 이원빈 on 2023/10/09.
//

import Foundation
import RxSwift

protocol RecordRepository {
    func getMyRecords() -> Observable<[RecordReadDTO]> /// will deprecated
    
    func getMyRecordsSeparatedByTag() -> Observable<[SectionOfRecordTag]>
    func getMyRecordsSeparatedByDate() -> Observable<[SectionOfRecordDate]>
    func getMyRecordsSeparatedByDate(byTag: String) -> RxSwift.Observable<[SectionOfRecordDate]>
    
    func getRecordsBy(tag: String) -> Observable<[RecordReadDTO]> /// will deprecated
    func createRecord(record: RecordCreateDTO) -> Observable<RecordReadDTO>
    func deleteRecord(recordId: String) -> Observable<String> /// 아래걸로 대체될 것
    func newDeleteRecord(recordId: String) -> Observable<DeleteRecordResponse>
}

/// 원래 여기서는 DTO 모델이 아닌 도메인 모델을 반환해주어야됨.
