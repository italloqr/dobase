// Configure your import map in config/importmap.rb
import "@hotwired/turbo-rails"
import "controllers"

// Rich text editor (Rhino Editor — TipTap-based, ActionText compatible)
import "rhino-editor"

// Close open dialogs and popovers before Turbo morphs them
// (morph preserves top-layer state, so they'd stay stuck open)
document.addEventListener("turbo:before-morph-element", (event) => {
  if (event.target instanceof HTMLDialogElement && event.target.open) {
    event.target.close()
  }
  if (event.target.popover && event.target.matches(":popover-open")) {
    event.target.hidePopover()
  }
})

// Custom confirmation dialog (replaces browser confirm())
Turbo.config.forms.confirm = (message, element, submitter) => {
  const dialog = document.getElementById("turbo-confirm-dialog")
  if (!dialog) return Promise.resolve(confirm(message))

  dialog.querySelector("#turbo-confirm-message").textContent = message

  const confirmBtn = dialog.querySelector("button[value='confirm']")
  confirmBtn.textContent = submitter?.dataset.turboConfirmButton || element?.dataset.turboConfirmButton || "Confirm"

  dialog.showModal()

  return new Promise((resolve) => {
    dialog.addEventListener("close", () => {
      resolve(dialog.returnValue === "confirm")
    }, { once: true })
  })
}

// Register service worker for PWA support
if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("/service-worker.js", { scope: "/" })
}
