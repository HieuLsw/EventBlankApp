//
//  SpeakerDetailsViewController.swift
//  EventBlank2-iOS
//
//  Created by Marin Todorov on 2/23/16.
//  Copyright © 2016 Underplot ltd. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources

class SpeakerDetailsViewController: UIViewController, ClassIdentifier {
    
    private let bag = DisposeBag()

    @IBOutlet weak var tableView: UITableView!

    private var speaker: Speaker!
    private var viewModel: SpeakerDetailsViewModel!
    private var twitterProvider: TwitterProvider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindUI()
    }
    
    static func createWith(storyboard: UIStoryboard,
        speaker: Speaker,
        twitterProvider: TwitterProvider = TwitterProvider()) -> SpeakerDetailsViewController {
        
        return storyboard.instantiateViewController(SpeakerDetailsViewController).then {vc in
            vc.speaker = speaker
            vc.viewModel = SpeakerDetailsViewModel(speaker: speaker, twitterProvider: twitterProvider)
            vc.twitterProvider = twitterProvider
        }
    }
    
    func setupUI() {
        title = speaker.name
        
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func bindUI() {
        //bind the table view
        viewModel.tableItems
            .bindTo(tableView.rx_itemsWithDataSource(viewModel.dataSource))
            .addDisposableTo(bag)
    }
    
}