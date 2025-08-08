import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["overlay", "dialog"];

	connect() {
		// Close modal on Escape key
		this.handleEscape = this.handleEscape.bind(this);
		document.addEventListener("keydown", this.handleEscape);

		// Handle quick amount buttons
		this.setupQuickAmounts();
	}

	disconnect() {
		document.removeEventListener("keydown", this.handleEscape);
	}

	open(event) {
		const modalId = event.currentTarget.dataset.modalTarget;
		const modal = document.getElementById(modalId);
		if (modal) {
			modal.classList.add("active");
			// Focus on the amount input
			const amountInput = modal.querySelector(".amount-input");
			if (amountInput) {
				setTimeout(() => amountInput.focus(), 100);
			}
		}
	}

	close() {
		this.element.classList.remove("active");
		// Clear the form
		const form = this.element.querySelector("form");
		if (form) {
			form.reset();
			this.clearQuickAmountSelection();
		}
	}

	closeOnOverlay(event) {
		if (event.target === this.overlayTarget) {
			this.close();
		}
	}

	handleEscape(event) {
		if (event.key === "Escape" && this.element.classList.contains("active")) {
			this.close();
		}
	}

	setupQuickAmounts() {
		const quickAmountBtns = this.element.querySelectorAll(".quick-amount-btn");
		const amountInput = this.element.querySelector(".amount-input");

		quickAmountBtns.forEach((btn) => {
			btn.addEventListener("click", (event) => {
				// Clear previous selections
				this.clearQuickAmountSelection();

				// Mark current button as selected
				btn.classList.add("selected");

				// Set the amount in the input
				const amount = btn.dataset.amount;
				if (amountInput) {
					amountInput.value = amount;
				}
			});
		});

		// Clear selection when user types in input
		if (amountInput) {
			amountInput.addEventListener("input", () => {
				this.clearQuickAmountSelection();
			});
		}
	}

	clearQuickAmountSelection() {
		const quickAmountBtns = this.element.querySelectorAll(".quick-amount-btn");
		quickAmountBtns.forEach((btn) => btn.classList.remove("selected"));
	}
}
