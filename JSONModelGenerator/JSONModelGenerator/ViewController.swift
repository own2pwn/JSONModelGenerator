//
//  ViewController.swift
//  JSONModelGenerator
//
//  Created by Evgeniy on 27.04.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Cocoa

final class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        testWorker()
    }

    private func testWorker() {
        let path = "file://" + FileManager.default.currentDirectoryPath + "/Model.json"
        guard let url = URL(string: path),
            let content = try? Data(contentsOf: url),
            let object = try? JSONSerialization.jsonObject(with: content, options: []),
            let json = object as? JSONObject else { return }

        let worker = Worker()
        _ = worker.generate(name: "Search", for: json)
    }
}
