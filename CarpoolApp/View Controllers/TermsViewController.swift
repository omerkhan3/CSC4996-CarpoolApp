//
//  TermsViewController.swift
//  CarpoolApp
//
//  Created by Matt on 4/9/18.
//  Copyright © 2018 CSC 4996. All rights reserved.
//

import UIKit
import PDFKit
class TermsViewController: UIViewController {

    
    @IBOutlet weak var pdfview: PDFView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = Bundle.main.path(forResource: "terms2", ofType: "pdf")
        let url = URL(fileURLWithPath: path!)
        let pdfDocument = PDFDocument(url: url)
        pdfview.displayMode = .singlePageContinuous
        pdfview.autoScales = true
        
        pdfview.document = pdfDocument
    }
}
