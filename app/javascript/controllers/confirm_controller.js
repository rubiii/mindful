import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["title", "message", "confirm", "cancel"]
  static values = {
    defaultTitle: String,
    defaultConfirmLabel: String,
    defaultCancelLabel: String
  }

  connect() {
    this.originalConfirm = Turbo.confirm
    Turbo.setConfirmMethod(this.showConfirmDialog.bind(this))

    // this.handleKeydown = this.handleKeydown.bind(this)
    // window.addEventListener("keydown", this.handleKeydown)
  }

  disconnect() {
    Turbo.setConfirmMethod(this.originalConfirm)
    // window.removeEventListener("keydown", this.handleKeydown)
  }

  showConfirmDialog(message, element) {
    this.messageTarget.textContent = message
    this.titleTarget.textContent = element.dataset.confirmTitle || this.defaultTitleValue

    const confirmLabel = element.dataset.confirmLabel || this.defaultConfirmLabelValue
    this.confirmTarget.textContent = confirmLabel

    const cancelLabel = element.dataset.cancelLabel || this.defaultCancelLabelValue
    this.cancelTarget.textContent = cancelLabel

    // Style button based on method (destructive vs regular)
    if (element.dataset.turboMethod === "delete") {
      this.confirmTarget.classList.add("is-danger")
      this.confirmTarget.classList.remove("is-primary")
    } else {
      this.confirmTarget.classList.remove("is-danger")
      this.confirmTarget.classList.add("is-primary")
    }

    // Save focused element to restore later
    this.focusedElement = document.activeElement

    this.element.classList.add("is-active")
    this.confirmTarget.focus()

    // Pause Turbo until user proceeds or cancels
    return new Promise((resolve) => {
      this.resolvePromise = resolve
    })
  }

  proceed() {
    this.close(true)
  }

  cancel() {
    this.close(false)
  }

  // handleKeydown(event) {
  //   if (!this.element.classList.contains("is-active")) return

  //   if (event.key === "Escape") {
  //     event.preventDefault()
  //     this.cancel()
  //   }
  // }

  close(result) {
    this.element.classList.remove("is-active")

    if (this.focusedElement) {
      this.focusedElement.focus()
      this.focusedElement = null
    }

    if (this.resolvePromise) {
      this.resolvePromise(result)
      this.resolvePromise = null
    }
  }
}
