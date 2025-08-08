import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	connect() {
		console.log("Modal opener controller connected");
	}

	openModal(event) {
		console.log("openModal called", event);
		console.log("event.currentTarget.dataset", event.currentTarget.dataset);
		const modalId = event.currentTarget.dataset.modalId;
		console.log("Modal ID:", modalId);
		if (modalId) {
			const modal = document.getElementById(modalId);
			console.log("Modal element found:", modal);
			if (modal) {
				modal.classList.add("active");

				// Clear and focus on the modal
				this.clearModalState(modal);
				setTimeout(() => {
					const amountInput = modal.querySelector('input[type="number"]');
					if (amountInput) {
						amountInput.focus();
					}
				}, 100);
			}
		}
	}

	clearModalState(modal) {
		// Clear form
		const form = modal.querySelector("form");
		if (form) form.reset();

		// Clear quick amount selections
		const quickAmountBtns = modal.querySelectorAll(".quick-amount-btn");
		quickAmountBtns.forEach((btn) => btn.classList.remove("selected"));
	}
}
