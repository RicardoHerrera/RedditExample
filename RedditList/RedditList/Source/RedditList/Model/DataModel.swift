//
//  DataModel.swift
//  RedditList
//
//  Created by Ricardo Herrera on 6/20/21.
//  Copyright © 2021 Ricardo. All rights reserved.
//

import Foundation

final class DataModelManager {
    static let sharedInstance: DataModelManager = {
        let instance = DataModelManager()
        instance.loadDataModel()
        return instance
    }()

    private var dataModel: DataModel!
    var storage: RedditStorageProtocol!

    init(storage: RedditStorageProtocol = RedditStorage()) {
        self.storage = storage
    }

    var postToShow: [Post] {
        return dataModel?.postToShow ?? []
    }

    var after: String {
        set {
            dataModel.after = newValue
        }
        get {
            dataModel.after
        }
    }

    var currentCount: Int {
        set {
            dataModel.currentCount = newValue
        }
        get {
            dataModel.currentCount
        }
    }

    func saveDataModel() {
        // save in userdefaults
    }

    func loadDataModel() {
        // load from userdefaults
        dataModel = DataModel()
    }

    func post(at index: Int) -> Post {
        return dataModel.postToShow[index]
    }

    func append(posts: [Post]) {
        dataModel?.postToShow.append(contentsOf: posts)
    }

    func removePost(at index: Int) {
        dataModel?.postToShow.remove(at: index)
    }

    func removeAllPosts() {
        dataModel?.postToShow.removeAll()
    }

    func resetValues() {
        dataModel?.postToShow = []
        dataModel?.after = ""
        dataModel?.currentCount = 0
    }
}

struct DataModel {

    var postToShow: [Post] = []
    var after: String = ""
    var currentCount: Int = 0

}
