//
//  ViewController.swift
//  JSONModelGenerator
//
//  Created by Evgeniy on 27.04.18.
//  Copyright © 2018 Evgeniy. All rights reserved.
//

import Cocoa

enum ModelKind: String {
    case sample
    case gmaps = "Model"
}

final class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        testWorker(.gmaps)
    }

    private func testWorker(_ kind: ModelKind) {
        guard let url = Bundle.main.url(forResource: kind.rawValue, withExtension: "json"),
            let content = try? Data(contentsOf: url),
            let object = try? JSONSerialization.jsonObject(with: content, options: []),
            let json = object as? JSONObject else { log.warning("can't read file!"); return }

        let worker = Worker()
        let model = worker.generate(name: "Search", for: json)
        log.debug("\n\(model)")
    }
}
