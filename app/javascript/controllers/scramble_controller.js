import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["scrambledWord", "answerArea", "letterTile", "answerTiles"]
  static values = { gameId: String, playerId: String }
  
  connect() {
    this.selectedLetters = []
    this.setupTouchEvents()
  }
  
  setupTouchEvents() {
    this.element.addEventListener('touchstart', this.handleTouchStart.bind(this), { passive: false })
    this.element.addEventListener('touchmove', this.handleTouchMove.bind(this), { passive: false })
    this.element.addEventListener('touchend', this.handleTouchEnd.bind(this), { passive: false })
  }
  
  handleTouchStart(event) {
    if (event.target.classList.contains('letter-tile')) {
      event.preventDefault()
      this.draggedElement = event.target
      this.startX = event.touches[0].clientX
      this.startY = event.touches[0].clientY
    }
  }
  
  handleTouchMove(event) {
    if (this.draggedElement) {
      event.preventDefault()
      const touch = event.touches[0]
      this.draggedElement.style.position = 'fixed'
      this.draggedElement.style.left = touch.clientX - 24 + 'px'
      this.draggedElement.style.top = touch.clientY - 24 + 'px'
      this.draggedElement.style.zIndex = '1000'
      this.draggedElement.style.transform = 'scale(1.1)'
    }
  }
  
  handleTouchEnd(event) {
    if (this.draggedElement) {
      event.preventDefault()
      
      const touch = event.changedTouches[0]
      const elementBelow = document.elementFromPoint(touch.clientX, touch.clientY)
      
      // Reset styles
      this.draggedElement.style.position = ''
      this.draggedElement.style.left = ''
      this.draggedElement.style.top = ''
      this.draggedElement.style.zIndex = ''
      this.draggedElement.style.transform = ''
      
      // Check if dropped on answer area
      const answerArea = document.getElementById('answer-tiles')
      if (answerArea && (elementBelow === answerArea || answerArea.contains(elementBelow))) {
        this.addToAnswer(this.draggedElement)
      }
      
      this.draggedElement = null
    }
  }
  
  selectLetter(event) {
    this.addToAnswer(event.currentTarget)
  }
  
  addToAnswer(letterElement) {
    const letter = letterElement.dataset.letter
    const answerArea = this.answerTilesTarget
    
    // Create a new tile for the answer area
    const answerTile = document.createElement('div')
    answerTile.className = 'letter-tile bg-green-100 border-2 border-green-300 w-12 h-12 flex items-center justify-center text-xl font-bold text-green-900 rounded cursor-pointer hover:bg-green-200 transition'
    answerTile.textContent = letter.toUpperCase()
    answerTile.dataset.letter = letter
    answerTile.dataset.action = 'click->scramble#removeFromAnswer'
    
    answerArea.appendChild(answerTile)
    
    // Hide the original tile
    letterElement.style.visibility = 'hidden'
    letterElement.dataset.used = 'true'
  }
  
  removeFromAnswer(event) {
    const answerTile = event.currentTarget
    const letter = answerTile.dataset.letter
    
    // Find the original tile and show it again
    const originalTiles = this.element.querySelectorAll('.letter-tile[data-letter="' + letter + '"][data-used="true"]')
    for (let tile of originalTiles) {
      if (tile.style.visibility === 'hidden') {
        tile.style.visibility = 'visible'
        tile.dataset.used = 'false'
        break
      }
    }
    
    // Remove from answer area
    answerTile.remove()
  }
  
  clearAnswer() {
    const answerArea = this.answerTilesTarget
    const answerTiles = answerArea.querySelectorAll('.letter-tile')
    
    answerTiles.forEach(tile => {
      // Create a fake event object for the removeFromAnswer method
      const fakeEvent = { currentTarget: tile }
      this.removeFromAnswer(fakeEvent)
    })
  }
  
  submitAnswer() {
    const answerArea = this.answerTilesTarget
    const answerTiles = answerArea.querySelectorAll('.letter-tile')
    const answer = Array.from(answerTiles).map(tile => tile.dataset.letter).join('')
    
    if (answer.length === 0) {
      alert('Please form a word before submitting!')
      return
    }
    
    if (!this.gameIdValue || !this.playerIdValue) {
      alert('Unable to submit answer. Please refresh the page.')
      return
    }
    
    // Submit via fetch
    fetch(`/games/${this.gameIdValue}/players/${this.playerIdValue}/submit_answer`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({ answer: answer })
    })
    .then(response => {
      if (response.ok) {
        // Clear the answer after successful submission
        this.clearAnswer()
      } else {
        alert('Failed to submit answer. Please try again.')
      }
    })
    .catch(error => {
      console.error('Error:', error)
      alert('Failed to submit answer. Please try again.')
    })
  }
  
  markReady() {
    if (!this.gameIdValue || !this.playerIdValue) {
      alert('Unable to mark ready. Please refresh the page.')
      return
    }
    
    fetch(`/games/${this.gameIdValue}/players/${this.playerIdValue}/ready`, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      }
    })
    .then(response => {
      if (!response.ok) {
        alert('Failed to mark ready. Please try again.')
      }
    })
    .catch(error => {
      console.error('Error:', error)
      alert('Failed to mark ready. Please try again.')
    })
  }
  
}
