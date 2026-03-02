import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Restore state from DOM element (survives Turbo permanent preservation)
    this._roomElement = this.element._roomElement || null
    this._toolPath = this.element._toolPath || ""
    this._active = this.element._active || false

    this._onBeforeRender = this._handleBeforeRender.bind(this)
    this._onRender = this._handleRender.bind(this)
    this._onBeforeUnload = this._handleBeforeUnload.bind(this)

    document.addEventListener("turbo:before-render", this._onBeforeRender)
    document.addEventListener("turbo:render", this._onRender)
    window.addEventListener("beforeunload", this._onBeforeUnload)

    // Re-apply sidebar indicator if active
    if (this._active) this._applySidebarIndicator()
  }

  disconnect() {
    document.removeEventListener("turbo:before-render", this._onBeforeRender)
    document.removeEventListener("turbo:render", this._onRender)
    window.removeEventListener("beforeunload", this._onBeforeUnload)
  }

  // Called by room_controller on join
  activate(roomElement, toolPath) {
    // Only one active call at a time
    if (this._active && this._roomElement && this._roomElement !== roomElement) {
      this._forceLeaveExisting()
    }

    this._roomElement = roomElement
    this._toolPath = toolPath
    this._active = true

    // Persist on DOM element
    this.element._roomElement = roomElement
    this.element._toolPath = toolPath
    this.element._active = true

    this._applySidebarIndicator()
  }

  // Called by room_controller on leave
  deactivate() {
    this._active = false
    this._roomElement = null
    this._toolPath = ""

    this.element._active = false
    this.element._roomElement = null
    this.element._toolPath = ""

    this.element.hidden = true
    this._removeReturnBanner()
    this._removeSidebarIndicator()
  }

  get active() {
    return this._active
  }

  get roomElement() {
    return this._roomElement
  }

  // ── Private ──────────────────────────────────────────────────────────

  _handleBeforeRender(event) {
    if (!this._active || !this._roomElement) return

    const newBody = event.detail.newBody
    const placeholder = newBody.querySelector("[data-persistent-room-placeholder]")

    if (placeholder && this.element.contains(this._roomElement)) {
      // Navigating BACK to the room page — move element into the new body
      this._roomElement.classList.remove("persistent-room-pip")
      placeholder.replaceWith(this._roomElement)
      this._removeReturnBanner()
      this.element.hidden = true
    } else if (!this.element.contains(this._roomElement)) {
      // Room element is still in <main> — navigating AWAY from the room page
      this._roomElement.classList.add("persistent-room-pip")
      this.element.appendChild(this._roomElement)
      this._addReturnBanner()
      this.element.hidden = false
    }
  }

  _handleRender() {
    // Re-apply sidebar indicator after each render (Turbo replaces sidebar HTML)
    if (this._active) this._applySidebarIndicator()
  }

  _handleBeforeUnload(event) {
    if (!this._active) return
    event.preventDefault()
  }

  _addReturnBanner() {
    if (this.element.querySelector("[data-return-banner]")) return

    const banner = document.createElement("a")
    banner.href = this._toolPath
    banner.dataset.returnBanner = ""
    banner.className = "persistent-room-return-banner"
    banner.textContent = "Return to call"
    this.element.insertBefore(banner, this.element.firstChild)
  }

  _removeReturnBanner() {
    this.element.querySelector("[data-return-banner]")?.remove()
  }

  _applySidebarIndicator() {
    if (!this._toolPath) return
    const link = document.querySelector(`a.sidebar-tool-item[href="${this._toolPath}"]`)
    if (link) link.dataset.inCall = "true"
  }

  _removeSidebarIndicator() {
    document.querySelectorAll("[data-in-call]").forEach(el => delete el.dataset.inCall)
  }

  _forceLeaveExisting() {
    if (!this._roomElement) return
    const roomCtrl = this.application.getControllerForElementAndIdentifier(
      this._roomElement, "room"
    )
    roomCtrl?.leave()
  }
}
