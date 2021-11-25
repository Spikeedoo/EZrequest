//
//  ViewController.swift
//  EZrequest
//
//  Created by Matteo Grilla on 11/23/21.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var requestTypeSwitcher: NSSegmentedControl!
    @IBOutlet var requestUrl: NSTextField!
    @IBOutlet var requestResponse: NSTextView!
    @IBOutlet var statusCodeView: NSTextField!
    @IBOutlet var codeLabel: NSTextField!
    @IBOutlet var dataString: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    
    @IBAction func onTypeChange(_ sender: Any) {
        if (requestTypeSwitcher.selectedSegment == 0) {
            if (!dataString.isHidden) {
                dataString.isHidden = true;
            }
        } else {
            if (dataString.isHidden) {
                dataString.isHidden = false;
            }
        }
    }
    
    @IBAction func onSubmitRequest(_ sender: Any) {
        if (requestTypeSwitcher.selectedSegment == 0) {
            // GET Request
            submitGet();
        } else {
            // POST Request
            submitPost();
        }
    }
    
    func updateResponse(val: Data, resp: HTTPURLResponse) {
        // Store the response string
        let respStr = String(data: val, encoding: .utf8)!
        // Update the response section with the response
        requestResponse.string = respStr
        if (codeLabel.isHidden) {
            // Unhide the "Status code:" string
            codeLabel.isHidden = false
        }
        // Store status code
        let statusCode = resp.statusCode
        // Display status code
        statusCodeView.stringValue = "\(statusCode)"
        // Conditionals for selecting status color
        if (statusCode >= 200 && statusCode < 300) {
            statusCodeView.textColor = NSColor.green
        } else if (statusCode >= 400 && statusCode < 500) {
            statusCodeView.textColor = NSColor.red
        } else if (statusCode >= 500) {
            statusCodeView.textColor = NSColor.systemRed
        }
    }
    
    func submitGet() {
        // Store url string
        let urlString = requestUrl.stringValue
        // Turn url string into a url
        let url = URL(string: urlString)
        // Set up request
        let getTask = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            // Store data
            guard let data = data else { return }
            // Store response
            guard let httpResponse = response as? HTTPURLResponse else { return }
            // Move back to main thread
            DispatchQueue.main.async {
                // Call method to update the response and code sections
                self.updateResponse(val: data, resp: httpResponse)
            }
        }
        // Call request
        getTask.resume()
    }
    
    func submitPost() {
        // Store url string
        let urlString = requestUrl.stringValue
        // Turn url string into a url
        let url = URL(string: urlString)
        // Set up request
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        let payload = dataString.stringValue.data(using: .utf8)!
        let postTask = URLSession.shared.uploadTask(with: request, from: payload) {(data, response, error) in
            // Store data
            guard let data = data else { return }
            // Store response
            guard let httpResponse = response as? HTTPURLResponse else { return }
            // Move back to main thread
            DispatchQueue.main.async {
                // Call method to update the response and code sections
                self.updateResponse(val: data, resp: httpResponse)
            }
        }
        // Call request
        postTask.resume()
    }
    
}

