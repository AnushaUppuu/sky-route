import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["count", "input", "message"]

  connect() {
    this.countValue = parseInt(this.inputTarget.value || "1")
    this.updateDisplay()
  }

  increment() {
    if (this.countValue >= 6) {
      this.showMessage("Maximum 6 passengers allowed")
      return
    }
    this.countValue++
    this.updateDisplay()
    this.clearMessage()
  }

  decrement() {
    if (this.countValue <= 1) {
      this.showMessage("Minimum 1 passenger required")
      return
    }
    this.countValue--
    this.updateDisplay()
    this.clearMessage()
  }

  updateDisplay() {
    this.countTarget.textContent = this.countValue
    this.inputTarget.value = this.countValue
  }

  showMessage(text) {
    this.messageTarget.textContent = text
  }

  clearMessage() {
    this.messageTarget.textContent = ""
  }
}
