//
//  SheetMuiscWebViewExtension.swift
//  Play'dRiteDemo_Version_2
//
//  Created by Ben Johnson  on 2/3/23.
//

import WebKit

class SheetMusicWebViewExtension: WKWebView, WKNavigationDelegate {
    
    var XMLString = ""
    
    init(containerView: UIView, musicXMLString: String) {
        self.XMLString = musicXMLString
        super.init(frame: CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height), configuration: WKWebViewConfiguration())
        containerView.backgroundColor = .white
        isOpaque = false
        backgroundColor = .clear
        scrollView.backgroundColor = .clear
        navigationDelegate = self
        configuration.ignoresViewportScaleLimits = true
        backgroundColor = UIColor.clear
        allowsBackForwardNavigationGestures = false
        isUserInteractionEnabled = true
        
        if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "OSMD") {
            let request = URLRequest(url: url)
            load(request)
        }
        containerView.addSubview(self)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder: NSCoder) {
            fatalError("init(coder:) is not supported")
        }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Did finish navigation")
        
        //Replaces/reformats the xml file
        XMLString = XMLString.replacingOccurrences(of: "'", with: "\\'").replacingOccurrences(of: "\n", with: "")
        
        evaluateJavaScript("""
        console.log("Attempt loading of MusicXML file");
        var osmd = new opensheetmusicdisplay.OpenSheetMusicDisplay("osmdContainer");
        osmd.setOptions({
          backend: "svg", drawTitle: true, followCursor: true,
          // drawingParameters: "compacttight" // don't display title, composer etc., smaller margins
        });
        osmd.load('\(XMLString)').then(function () {
          osmd.render();
        });
        """) { reply, error in
                print("JavaScript Initial load evaluation completed")
                print(reply ?? "No reply")
                print(error ?? "No error")
        }
    }
    
}
