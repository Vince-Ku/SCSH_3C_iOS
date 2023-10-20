//
//  HomeViewModel.swift
//  SCSH_3C_iOS
//
//  Created by 辜敬閎 on 2023/7/25.
//

import Foundation
import Combine
import SwiftUI

class HomeViewModel: ObservableObject {
    // MARK: Output
    @Published var firstHeaderIndexPath: IndexPath = .init(item: 0, section: 0)
    @Published var hightLightHeaderIndexPath: IndexPath = .init(item: 1, section: 0)
    @Published var subjects: [String] = ["Explore", "BBB", "CCC", "DDD", "EEE", "FFF", "GGG", "HHH", "III", "JJJ"]
    
    @Published var navigationPath = NavigationPath()

    // MARK: Input
    let viewWillAppear = PassthroughSubject<Int, Error>()
    let viewDidAppear = PassthroughSubject<Void, Error>()
    let searchBarDidTap = PassthroughSubject<Void, Error>()
    let logoButtonDidTap = PassthroughSubject<Void, Error>()
    let messageButtonDidTap = PassthroughSubject<Void, Error>()
    let cartButtonDidTap = PassthroughSubject<Void, Error>()

    private let coordinator: HomeCoordinatorType
    
    private var cancellables = Set<AnyCancellable>()
    
    init(coordinator: HomeCoordinatorType) {
        self.coordinator = coordinator
        
        bindViewStateEvents()
        bindUserInteractionEvents()
        bindTransitionEvents()
    }
    
    private func bindViewStateEvents() {
        viewWillAppear
            .compactMap { [weak self] infinitScrollItems -> IndexPath? in
                guard let self = self else { return nil }
                
                let firstHeaderIndexPath = (infinitScrollItems / 2) - (infinitScrollItems / 2 % self.subjects.count)
                return IndexPath(item: firstHeaderIndexPath, section: 0)
            }
            .sink { _ in
                print("something went wrong in viewWillAppear")
            } receiveValue: { [weak self] indexPath in
                // TODO: unknown warning, fix it
                self?.firstHeaderIndexPath = indexPath
            }
            .store(in: &cancellables)
        
        viewDidAppear
            .compactMap { [weak self] in
                guard let firstHeaderIndexPath = self?.firstHeaderIndexPath else { return nil }
                return IndexPath(item: firstHeaderIndexPath.item + 1, section: firstHeaderIndexPath.section)
            }
            .sink { _ in
                print("something went wrong in viewDidAppear")
            } receiveValue: { [weak self] indexPath in
                self?.hightLightHeaderIndexPath = indexPath
            }
            .store(in: &cancellables)
        
        viewDidAppear
            .sink { _ in
                print("something went wrong in viewDidAppear")
            } receiveValue: { [weak self] _ in
                self?.coordinator.presentNotificationPermissionDailog() { _ in }
            }
            .store(in: &cancellables)
    }
    
    private func bindUserInteractionEvents() {
        searchBarDidTap
            .print("searchBarDidTap")
            .sink { _ in
                print("something went wrong in searchBarDidTap")
            } receiveValue: { [weak self] _ in
                self?.coordinator.requestSearchNavigation()
            }
            .store(in: &cancellables)
        
        logoButtonDidTap
            .print("logoButtonDidTap")
            .sink { _ in
                print("something went wrong in logoButtonDidTap")
            } receiveValue: { [weak self] _ in
                // TODO: implement.
            }
            .store(in: &cancellables)
        
        messageButtonDidTap
            .print("messageButtonDidTap")
            .sink { _ in
                print("something went wrong in messageButtonDidTap")
            } receiveValue: { [weak self] _ in
                self?.coordinator.requestMessageNavigation()
            }
            .store(in: &cancellables)
        
        cartButtonDidTap
            .sink { _ in
                print("something went wrong in cartButtonDidTap")
            } receiveValue: { [weak self] _ in
                self?.coordinator.requestCartNavigation()
            }
            .store(in: &cancellables)
    }
    
    private func bindTransitionEvents() {
        coordinator.navigate
            .sink { _ in
                print("something went wrong in navigate")
            } receiveValue: { [weak self] in
                self?.navigationPath.append($0)
            }
            .store(in: &cancellables)
    }
}
