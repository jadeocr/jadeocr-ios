//
//  multipleChoiceCard.swift
//  jadeocr
//
//  Created by Jeremy Tow on 12/28/20.
//

import UIKit

class multipleChoiceCard: UIView {
    
    @IBOutlet var multipleChoiceCardContent: UIView!
    @IBOutlet weak var aTextView: UITextView!
    @IBOutlet weak var bTextView: UITextView!
    @IBOutlet weak var cTextView: UITextView!
    @IBOutlet weak var dTextView: UITextView!
    @IBOutlet weak var aView: UIView!
    @IBOutlet weak var bView: UIView!
    @IBOutlet weak var cView: UIView!
    @IBOutlet weak var dView: UIView!
    @IBOutlet weak var correctLabel: UILabel!
    
    var delegate:CardDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initWithNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initWithNib()
    }
    
    convenience init(a: String, b: String, c: String, d: String) {
        self.init()
        aTextView.text = a
        bTextView.text = b
        cTextView.text = c
        dTextView.text = d
    }
    
    func initWithNib() {
        Bundle.main.loadNibNamed("multipleChoiceCard", owner: self, options: nil)
        multipleChoiceCardContent.frame = bounds
        multipleChoiceCardContent.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        aView.clipsToBounds = true
        aView.layer.cornerRadius = 10
        aView.layer.borderWidth = 5
        aView.layer.borderColor = UIColor(named: "nord9")?.cgColor
        
        bView.clipsToBounds = true
        bView.layer.cornerRadius = 10
        bView.layer.borderWidth = 5
        bView.layer.borderColor = UIColor(named: "nord9")?.cgColor
        
        cView.clipsToBounds = true
        cView.layer.cornerRadius = 10
        cView.layer.borderWidth = 5
        cView.layer.borderColor = UIColor(named: "nord9")?.cgColor
        
        dView.clipsToBounds = true
        dView.layer.cornerRadius = 10
        dView.layer.borderWidth = 5
        dView.layer.borderColor = UIColor(named: "nord9")?.cgColor
        
        
        
        addSubview(multipleChoiceCardContent)
    }
    
    public func change(a: String, b: String, c: String, d: String) {
        aTextView.text = a
        bTextView.text = b
        cTextView.text = c
        dTextView.text = d
    }
    
    public func setCorrectLabel(text: String) {
        correctLabel.text = text
        correctLabel.isHidden = false
    }
    
    func correctAnimation(view: UIView, textView: UITextView, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, animations: {
            
            view.backgroundColor = UIColor.systemGreen
            
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, delay: 0.3, animations: {
                
                view.backgroundColor = UIColor.systemGray6
                
            }, completion: {_ in
                completion?()
            })
        })
    }
    
    func incorrectAnimation(view: UIView, textView: UITextView, completion: (() -> Void)? = nil) {
        self.shake(view: view)
        UIView.animate(withDuration: 0.2, animations: {
            
            view.backgroundColor = UIColor.systemRed
            
        }, completion: { _ in
            
            UIView.animate(withDuration: 0.1, delay: 0.5, animations: {
                
                view.backgroundColor = UIColor.systemGray6
                
            }, completion: {_ in
                completion?()
            })
        })
    }
    
    func shake(view: UIView, completion: (() -> Void)? = nil) {
        let speed = 0.6
        let time = 1.0 * speed - 0.15
        let timeFactor = CGFloat(time / 4)
        let animationDelays = [timeFactor, timeFactor * 2, timeFactor * 3]

        let shakeAnimator = UIViewPropertyAnimator(duration: time, dampingRatio: 0.3)
        // left, right, left, center
        shakeAnimator.addAnimations({
            view.transform = CGAffineTransform(translationX: 20, y: 0)
        })
        shakeAnimator.addAnimations({
            view.transform = CGAffineTransform(translationX: -20, y: 0)
        }, delayFactor: animationDelays[0])
        shakeAnimator.addAnimations({
            view.transform = CGAffineTransform(translationX: 20, y: 0)
        }, delayFactor: animationDelays[1])
        shakeAnimator.addAnimations({
            view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, delayFactor: animationDelays[2])
        shakeAnimator.startAnimation()

        shakeAnimator.addCompletion { _ in
            completion?()
        }

        shakeAnimator.startAnimation()
    }
    
    @IBAction func aViewTapped(_ sender: Any) {
        delegate?.selectedChoice(selected: aTextView.text, view: aView, textView: aTextView )
    }
    
    @IBAction func bViewTapped(_ sender: Any) {
        delegate?.selectedChoice(selected: bTextView.text, view: bView, textView: bTextView)
    }
    
    @IBAction func cViewTapped(_ sender: Any) {
        delegate?.selectedChoice(selected: cTextView.text, view: cView, textView: cTextView)
    }
    
    @IBAction func dViewTapped(_ sender: Any) {
        delegate?.selectedChoice(selected: dTextView.text, view: dView, textView: dTextView)
    }
}
