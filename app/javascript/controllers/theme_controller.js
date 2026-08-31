import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]

  connect() {
    const saved = localStorage.getItem("theme") || "teal"
    if (this.hasSelectTarget) this.selectTarget.value = saved
  }

  switchFromSelect(event) {
    const theme = event.target.value
    this.apply(theme)
    localStorage.setItem("theme", theme)
  }

  apply(theme) {
    document.documentElement.classList.remove("theme-amber", "theme-blue", "theme-teal", "theme-green", "theme-rose", "theme-purple", "theme-slate")
    document.documentElement.classList.add(`theme-${theme}`)
  }
}
