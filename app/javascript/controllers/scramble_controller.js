import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["scrambledWord", "answerArea", "letterTile", "answerTiles", "feedback"]
  static values = { gameId: String, playerId: String }
  
  connect() {
    this.selectedLetters = []
  }
  
  selectLetter(event) {
    this.addToAnswer(event.currentTarget)
  }
  
  addToAnswer(letterElement) {
    const letter = letterElement.dataset.letter
    const answerArea = this.answerTilesTarget
    
    // Create a new tile for the answer area
    const answerTile = document.createElement('div')
    answerTile.className = 'letter-tile bg-green-100 border-2 border-green-300 w-16 h-16 lg:w-20 lg:h-20 flex items-center justify-center text-2xl lg:text-3xl font-bold text-green-900 rounded-xl cursor-pointer hover:bg-green-200 transition-all duration-200 shadow-md hover:shadow-lg'
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
        return response.json()
      } else {
        throw new Error('Failed to submit answer')
      }
    })
    .then(data => {
      if (data.correct) {
        // Clear the answer after correct submission
        this.clearAnswer()
        this.showFeedback(data.message, 'success')
      } else {
        // Show wrong answer feedback but don't clear the answer
        this.showFeedback(data.message, 'error')
      }
    })
    .catch(error => {
      console.error('Error:', error)
      this.showFeedback('Failed to submit answer. Please try again.', 'error')
    })
  }
  
  showFeedback(message, type) {
    if (this.hasFeedbackTarget) {
      this.feedbackTarget.textContent = message
      
      // Clear existing classes and set base classes
      this.feedbackTarget.className = 'mt-2 p-2 rounded text-center'
      
      if (type === 'success') {
        this.feedbackTarget.classList.add('bg-green-100', 'border', 'border-green-400', 'text-green-700')
      } else {
        this.feedbackTarget.classList.add('bg-red-100', 'border', 'border-red-400', 'text-red-700')
      }
      
      // Show the feedback
      this.feedbackTarget.style.display = 'block'
      
      // Auto-hide feedback after 3 seconds
      setTimeout(() => {
        if (this.hasFeedbackTarget) {
          this.feedbackTarget.style.display = 'none'
        }
      }, 3000)
    }
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
