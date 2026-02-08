import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["lightIcon", "darkIcon"]

  connect() {
    const theme = localStorage.getItem("theme")
    if (!theme) return

    this.setTheme(theme)
  }

  toggle(event) {
    // When triggered on mousedown instead of on click, prevents the
    // toggle from gaining focus and keeps the focus on the currently
    // selected element.
    event.preventDefault()

    const theme = document.documentElement.getAttribute("data-theme")
    const newTheme = theme === "dark" ? "light" : "dark"

    this.setTheme(newTheme)
    localStorage.setItem("theme", newTheme)
  }

  setTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme)

    if (theme === "light") {
      this.lightIconTarget.classList.remove("is-hidden")
      this.darkIconTarget.classList.add("is-hidden")
    } else {
      this.lightIconTarget.classList.add("is-hidden")
      this.darkIconTarget.classList.remove("is-hidden")
    }
  }
}
