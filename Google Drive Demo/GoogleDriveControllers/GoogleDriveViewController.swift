//
//  GoogleDriveViewController.swift
//  Google Drive Demo
//
//  Created by HaiboZhou on 2021/8/24.
//

import UIKit
import GoogleAPIClientForREST

class GoogleDriveViewController: UIViewController {
    var filesAndFolders: [GTLRDrive_File]?
    var folderID: String?
    var stateManager: StateManager!
    
    var googleAPIs: GoogleDriveAPI? {
        get { stateManager.googleAPIs }
    }
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(GoogleDriveTableViewCell.self, forCellReuseIdentifier: GoogleDriveTableViewCell.cell_ID)
        
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 52
        tableView.frame = view.bounds
        
        if title == nil { title = "Google Drive" }
        
        print("google drive files viewdidload")
        loadData()
        
    }
    
    func loadData() {
        listAudioFilesAndFolders()
    }
    
    func listAudioFilesAndFolders() {
        showSpinner()
        // for root folder
        var id = "root"
        if let folderID = self.folderID {
            id = folderID
        }
        
        DispatchQueue.global().async { [weak self] in
            self?.googleAPIs?.listFiles(id, onCompleted: { files, error in
                guard error == nil, files != nil else {
                    print("Error: \(String(describing: error))")
                    return
                }
                
                self?.filesAndFolders = files
                
                print("load data in google drive's current level complete")
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.removeSpinner()
                }
            })
        }
    }
    
    func downloadButtonTapped(_ index: IndexPath) {
        guard let files = filesAndFolders else { return }
        let fileItem = files[index.row]
        
        // implement your download method
        
        DispatchQueue.global().async { [weak self] in
            self?.googleAPIs?.download(fileItem, onCompleted: { data, error in
                guard error == nil, data != nil else {
                    print("Err: \(String(describing: error))")
                    return
                }
                
                // put code about where to save the downloaded file.
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            })
        }
    }
}



extension GoogleDriveViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let files = filesAndFolders else { return 0 }
        return files.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GoogleDriveTableViewCell.cell_ID, for: indexPath) as? GoogleDriveTableViewCell else {
            fatalError("initialize cell failed")
        }
        
        guard let audioFilesAndFolders = filesAndFolders else
        {
            return cell
        }
        
        let file = audioFilesAndFolders[indexPath.row]
        
        // show folder icon for this cell
        if file.mimeType == "application/vnd.google-apps.folder" {
            cell.cellImageView.image = UIImage(systemName: "folder.fill")?.withTintColor(.myFolderBlue, renderingMode: .alwaysOriginal)
            cell.nameLabel.text = file.name
            cell.downloadButton.isHidden = true
        } else {
            cell.cellImageView.image = UIImage(systemName: "music.note")?.withTintColor(.systemPink, renderingMode: .alwaysOriginal)
            
            // remove sufix, eg. Taylor Swift.mp3 -> Taylor Swift
            let filename: NSString = file.name as NSString? ?? ""
            let pathPrefix = filename.deletingPathExtension
            cell.nameLabel.text = pathPrefix
        }
        
        cell.tapAction = { [weak self] (cell) in
            guard let index = self?.tableView.indexPath(for: cell) else { return }
            self?.downloadButtonTapped(index)
        }
        
        return cell
    }
}

extension GoogleDriveViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let files = self.filesAndFolders else { return }
        let file = files[indexPath.row]
        // open a new VC when file type is 'folder'
        if file.mimeType == "application/vnd.google-apps.folder" {
            let vc = GoogleDriveViewController()
            vc.folderID = file.identifier
            vc.title = file.name
            vc.stateManager = self.stateManager
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
