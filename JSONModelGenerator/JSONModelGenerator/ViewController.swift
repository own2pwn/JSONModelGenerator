//
//  ViewController.swift
//  JSONModelGenerator
//
//  Created by Evgeniy on 27.04.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Cocoa

public final class Worker {

    // MARK: - Interface

    public func parse() {
        let path = FileManager.default.currentDirectoryPath
        log.debug(path)
    }
}

final class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func testWorker() {
        let worker = Worker()
        worker.parse()
    }
}
