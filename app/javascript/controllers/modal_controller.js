import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.classList.add("is-active")
    this.previousActiveElement = document.activeElement
    // document.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    this.element.classList.remove("is-active")
    // document.removeEventListener("keydown", this.handleKeydown)
    this.restoreFocus()
  }

  close(event) {
    if (event) event.preventDefault()
    this.element.remove()
  }

  // handleKeydown = (event) => {
  //   if (event.key === "Escape") {
  //     this.close(event)
  //   }
  // }

  restoreFocus() {
    if (this.previousActiveElement && document.body.contains(this.previousActiveElement)) {
      this.previousActiveElement.focus()
    }
  }
}
