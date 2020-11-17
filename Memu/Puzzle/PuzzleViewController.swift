//
//  PuzzleViewController.swift
//  Memu
//
//  Created by Gabriel Rodrigues da Silva on 03/11/20.
//

import UIKit

class PuzzleViewController: UIViewController {

    @IBOutlet weak var ear1: UIImageView!
    @IBOutlet weak var ear2: UIImageView!
    @IBOutlet weak var ear3: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    enum Section {
        case sequence
        case button
        case puzzle
    }
    
    // cria um tabuleiro para ser exibido (launchpad) e suas notas
    var puzzleBoard = Board(size: 4, instrument: "marimba", type: "puzzle")
    var puzzleNotes = [Note]()
    
    // configura a sequencia e suas notas
    var sequence = Sequence(size: 4)
    var sequenceNotes = [Note]()
    
    // recebe a sequencia de notas do launchpad
    var launchpadSequence = [Note]()
    
    var board3 = Board(size: 1, instrument: "marimba", type: "puzzle")
    var keyNotes3 = [Note]()
    
    var dataSource: UICollectionViewDiffableDataSource<Section, Note>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.collectionViewLayout = configLayout()
        
        puzzleNotes = puzzleBoard.launchpad
        sequenceNotes = sequence.notes
        
        // seção button
        keyNotes3 = board3.launchpad
        
        configDataSource()
    }
    
    // MARK: - Button
    
    @IBAction func btnPlay(_ sender: Any) {
        print("Play Button")
    }
    
    @IBAction func btnCheck(_ sender: Any) {
        print("Check Button")
    }
    
    @IBAction func btnMenu(_ sender: Any) {
        print("Menu Button")
        self.dismiss(animated: true, completion: nil)
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

            guard let puzzleCell = collectionView.dequeueReusableCell(withReuseIdentifier: LaunchpadCell.reuseIdentifier, for: IndexPath) as? LaunchpadCell else { fatalError("Cannot create key cell") }

            if self.sequenceNotes[IndexPath.row].image == UIImage(named: "delete")! {
                return btnDeleteCell
            } else if IndexPath.section == 1  {
                return btnCell
            } else {
                if IndexPath.section == 0 {
                    print(IndexPath)
                    puzzleCell.setNoteKey(note: self.sequenceNotes[IndexPath.row])
                    return puzzleCell

                } else {
                    let note = self.puzzleNotes[IndexPath.row]
                    puzzleCell.setNoteKey(note: note)
                    return puzzleCell
                }
            }

        })

        var snapshot = NSDiffableDataSourceSnapshot<Section, Note>()
        snapshot.appendSections([.sequence, .button, .puzzle])
        snapshot.appendItems(sequenceNotes, toSection: .sequence)
        snapshot.appendItems(keyNotes3, toSection: .button)
        snapshot.appendItems(puzzleNotes, toSection: .puzzle)


        dataSource.apply(snapshot, animatingDifferences: false)
    }

}

// MARK: - Delegate

extension PuzzleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell: \(indexPath[1])")
        
        if indexPath.section == 2  {
            print(puzzleNotes[indexPath[1]].name)
            if puzzleNotes[indexPath[1]].image == UIImage(named: "key\(puzzleNotes[indexPath[1]].color)Off") {
                // muda cor da tecla
                puzzleNotes[indexPath[1]].turnOn()
                
                // adiciona no array de sequencia
                sequence.addNote(note: puzzleNotes[indexPath[1]])
                // atualiza array de notas da sequencia (conectado à collection)
                self.sequenceNotes = sequence.notes
                
                collectionView.reloadData()
            }
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
