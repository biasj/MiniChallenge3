//
//  LaunchpadViewController.swift
//  Memu
//
//  Created by Gabriel Rodrigues da Silva on 03/11/20.
//

import UIKit
import AVFoundation

class LaunchpadViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    
    let tutorialHasLaunched: Bool = UserDefaults.standard.bool(forKey: "tutorialHasLaunched")
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Note>!
    
    // seção da collection view
    enum Section: Hashable {
        case sequence
        case button
        case launchpad
    }
    
    // cria um tabuleiro para ser exibido (launchpad) e suas notas
    var board = Board(size: 4, instrument: "marimba", type: "launchpad")
    
    // configura a sequencia e suas notas
    var sequence = Sequence(size: 4)
    
    // seção button
    var board3 = Board(size: 1, instrument: "marimba", type: "launchpad")
    var keyNotes3 = [Note]()
    
    let btnImg: [UIImage] = [UIImage(named: "play")!]
    
    var playerItem: [AVPlayerItem] = []
    var sequencePlayer: AVQueuePlayer?
    var notePlayer: AVAudioPlayer?
    
    static var isPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.collectionViewLayout = configLayout()
        
        // seção button
        keyNotes3 = board3.getLaunchpad()
        
        if !tutorialHasLaunched {
            instructionLabel.isHidden = false
        }
        
        configDataSource()
    }
    
    // MARK: - Button
    
    @IBAction func btnMenu(_ sender: Any) {
        print("Menu Button")
        playNote("feedback_interface")
    }
    @IBAction func btnNotes(_ sender: Any) {
        print("Notes Button")
        playNote("feedback_interface")
    }
    @IBAction func btnCheck(_ sender: Any) {
        print("Check Button")
        playNote("feedback_interface")
        performSegue(withIdentifier: "go2Puzzle", sender: self)
    }
    
    @IBAction func unwindSegue(unwindSegue: UIStoryboardSegue){
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "go2Puzzle" {
            let vc = segue.destination as? PuzzleViewController
            vc?.puzzleBoard.setPuzzleNotes(notes: board.getLaunchpad())
            vc?.launchpadSequence = sequence.getNotes()
        }
    }
    
    
    // MARK: - Collection View Layout
    
    func configLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnviroment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let sect = sectionIndex
            
            if sect == 0 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.2), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 0, bottom: 0, trailing: 0)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.1))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 40, leading: 50, bottom: 0, trailing: 50)
                
                return section
    
            } else if sect == 1 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 5, bottom: 0, trailing: 0)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.25))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 50, bottom: 0, trailing: 50)
                
                return section
                
            } else {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 0, bottom: 5, trailing: 0)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.25))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 50)
                
                return section
            }
        
        }
        
        return layout
    }
    
    // MARK: - Collection View Data Source
    func configDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Note>(collectionView: self.collectionView, cellProvider: { (collectionView, IndexPath, image) -> UICollectionViewCell? in
            
            guard let btnDeleteCell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonCell.reuseIdentifierDelete, for: IndexPath) as? ButtonCell else { fatalError("Cannot create delete button cell") }
            
            guard let btnCell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonCell.reuseIdentifier, for: IndexPath) as? ButtonCell else { fatalError("Cannot create button cell") }
            
            guard let keyCell = collectionView.dequeueReusableCell(withReuseIdentifier: LaunchpadCell.reuseIdentifier, for: IndexPath) as? LaunchpadCell else { fatalError("Cannot create key cell") }
            
            if self.sequence.getNotes()[IndexPath.row].getImage() == UIImage(named: "delete")! {
                btnDeleteCell.delegate = self
                return btnDeleteCell
            } else if IndexPath.section == 1  {
                btnCell.delegate = self
                return btnCell
            } else {
                // se for seção da sequencia
                if IndexPath.section == 0 {
                    print(IndexPath)
                    let sequenceNote = self.sequence.getNotes()[IndexPath.row]
                    keyCell.setNoteKey(note: sequenceNote)
                    return keyCell

                }else {
                    // se for seção do tabuleiro/launchpad
                    let note = self.board.getLaunchpad()[IndexPath.row]
                    keyCell.setNoteKey(note: note)
                    return keyCell
                }
            }

        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Note>()
        snapshot.appendSections([.sequence, .button, .launchpad])
        snapshot.appendItems(sequence.getNotes(), toSection: .sequence)
        snapshot.appendItems(keyNotes3, toSection: .button)
        snapshot.appendItems(board.getLaunchpad(), toSection: .launchpad)
        
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
}

// MARK: - Delegate

extension LaunchpadViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell: \(indexPath[1])")
        
        // se for a seção das teclas
        if indexPath.section == 2 && board.getLaunchpad()[indexPath[1]].getImage() == UIImage(named: "key\(board.getLaunchpad()[indexPath[1]].getColor())Off") {
            // muda cor da tecla
            board.getLaunchpad()[indexPath[1]].turnOn()
            
            playNote(board.getLaunchpad()[indexPath[1]].getSoundFile())
            
            // adiciona no array de sequencia
            sequence.addNote(note: board.getLaunchpad()[indexPath[1]])
            
            if sequence.isFull() {
                btnCheck.isEnabled = true
            }
            
            collectionView.reloadData()
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let keyCell = collectionView.cellForItem(at: indexPath) as? LaunchpadCell {
            keyCell.keyOn.isHighlighted = true
            keyCell.keyOn.alpha = 0.8
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let keyCell = collectionView.cellForItem(at: indexPath) as? LaunchpadCell {
            keyCell.keyOn.isHighlighted = false
            keyCell.keyOn.alpha = 1.0
        }
    }
}


extension LaunchpadViewController: ButtonCellDelegate {
    func delete() {
        // retira a nota do vetor
        let erasedNote = sequence.eraseNote()
        
        // acha a nota apagada e desliga ela do launchpad
        for note in board.getLaunchpad() {
            if(note.getName() == erasedNote.getName()) {
                note.turnOff()
                playNote("feedback_interface")
            }
        }
        
        // se deletar qualquer nota, a sequencia já não vai estar cheia
        btnCheck.isEnabled = false
        
        collectionView.reloadData()
    }
    
    func play() {
        
        if LaunchpadViewController.isPlaying == true {
            sequencePlayer?.pause()
        } else {
            prepareToPlay(sequenceNotes: sequence.getNotes())
            sequencePlayer?.seek(to: .zero)
            sequencePlayer?.play()
            sequencePlayer?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        }
    }
    
    func prepareToPlay(sequenceNotes: Array<Note>) {
        
        if sequencePlayer != nil {
            sequencePlayer?.removeAllItems()
            playerItem.removeAll()
        }
        
        let songs = sequenceNotes
        for song in songs {
            if song.getName() != "off" && song.getName() != "delete" {
                guard let url = Bundle.main.url(forResource: song.getSoundFile(), withExtension: ".mp3") else {
                    fatalError("Cannot load \(song)")
                }
                playerItem.append(AVPlayerItem(url: url))
            }
        }
        
        sequencePlayer = AVQueuePlayer(items: playerItem)
    }
    
    func playNote(_ song: String) {
        let path = Bundle.main.path(forResource: song, ofType: ".mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            notePlayer = try AVAudioPlayer(contentsOf: url)
            notePlayer?.play()
        } catch {
            print(error)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if object as AnyObject? === sequencePlayer {
            if keyPath == "timeControlStatus" {
                if ((sequencePlayer?.timeControlStatus) == .playing) {
                    LaunchpadViewController.isPlaying = true
                } else {
                    LaunchpadViewController.isPlaying = false
                }
                NotificationCenter.default.post(name: NSNotification.Name.init("Playing"), object: nil)
            }
        }
    }
    
}

