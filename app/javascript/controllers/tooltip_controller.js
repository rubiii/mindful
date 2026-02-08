import { Controller } from "@hotwired/stimulus"
import tippy from "tippy.js"

export default class extends Controller {
  // https://atomiks.github.io/tippyjs/v6/all-props/
  DEFAULT_OPTIONS = {
    animation: "shift-away-subtle",
    theme: "app",
    hideOnClick: false,
    allowHTML: true,
  }

  static targets = ["trigger"]

  tippyInstances = {}

  triggerTargetConnected(trigger) {
    const content = trigger.dataset.tooltipContent
    const placement = trigger.dataset.tooltipPlacement || "left"

    const instance = tippy(trigger, { ...this.DEFAULT_OPTIONS, content, placement })
    trigger.id = `tooltip${instance.id}`

    this.tippyInstances[trigger.id] = instance
  }

  triggerTargetDisconnected(trigger) {
    this.tippyInstances[trigger.id]?.destroy()
  }
}
