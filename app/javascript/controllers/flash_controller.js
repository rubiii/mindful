import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.dismiss()
    }, 6000)
  }

  dismiss() {
    this.element.classList.add("fade-out")

    this.element.addEventListener("transitionend", () => {
      this.element.remove()
    }, { once: true })
  }
}
