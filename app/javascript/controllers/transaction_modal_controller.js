import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["form", "amountInput", "submitButton"];
	static values = { transactionType: String };

	connect() {
		console.log(
			"Transaction modal controller connected for:",
			this.transactionTypeValue,
			"Element:",
			this.element
		);
		this.setupEscapeKeyHandler();
	}

	disconnect() {
		this.removeEscapeKeyHandler();
	}

	open(event) {
		// If called from a button, get the modal ID from data attribute
		if (event && event.currentTarget.dataset.modalId) {
			const modalId = event.currentTarget.dataset.modalId;
			const modal = document.getElementById(modalId);
			if (modal) {
				modal.classList.add("active");
				this.focusAmountInput(modal);
				return;
			}
		}

		// Default behavior - open this controller's modal
		this.element.classList.add("active");
		this.clearModalState();
		this.focusAmountInput(this.element);
	}

	close() {
		this.element.classList.remove("active");
		this.clearModalState();
	}

	focusAmountInput(modal) {
		setTimeout(() => {
			const amountInput = modal.querySelector('input[type="number"]');
			if (amountInput) {
				amountInput.focus();
			}
		}, 100);
	}

	selectQuickAmount(event) {
		event.preventDefault();
		event.stopPropagation();

		const amount = event.currentTarget.dataset.amount;
		console.log("Quick amount selected:", amount);

		// Clear previous selections
		this.clearQuickAmountSelections();

		// Mark current button as selected
		event.currentTarget.classList.add("selected");

		// Set the amount in the input
		if (this.hasAmountInputTarget) {
			this.amountInputTarget.value = amount;
		}
	}

	clearSelection() {
		this.clearQuickAmountSelections();
	}

	submit(event) {
		event.preventDefault();

		if (!this.validateAmount()) {
			return;
		}

		const formData = new FormData(this.formTarget);

		// Use unified transactions endpoint
		const actionPath = "/transactions";

		this.submitButton.disabled = true;
		this.submitButton.textContent = "Processing...";

		fetch(actionPath, {
			method: "POST",
			body: formData,
			headers: {
				"X-Requested-With": "XMLHttpRequest",
				"X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
					.content,
			},
		})
			.then((response) => response.json())
			.then((data) => {
				if (data.success) {
					this.handleSuccess(data);
				} else {
					this.handleError(data.error || "Transaction failed");
				}
			})
			.catch((error) => {
				console.error("Transaction error:", error);
				this.handleError("An unexpected error occurred. Please try again.");
			})
			.finally(() => {
				this.submitButton.disabled = false;
				this.submitButton.textContent =
					this.transactionTypeValue === "debit"
						? "Withdraw Cash"
						: "Deposit Cash";
			});
	}

	validateAmount() {
		if (!this.hasAmountInputTarget) {
			this.showError("Amount input not found.");
			return false;
		}

		const amount = parseFloat(this.amountInputTarget.value);

		if (!amount || amount <= 0) {
			this.showError("Please enter a valid amount.");
			this.amountInputTarget.focus();
			return false;
		}

		if (this.transactionTypeValue === "debit") {
			const maxAmount = parseFloat(this.amountInputTarget.max);
			if (amount > maxAmount) {
				this.showError(
					`Insufficient funds. Your available balance is $${maxAmount.toFixed(
						2
					)}.`
				);
				this.amountInputTarget.focus();
				return false;
			}
		}

		// Confirm the transaction
		const actionText =
			this.transactionTypeValue === "debit" ? "withdraw" : "deposit";
		if (
			!confirm(`Are you sure you want to ${actionText} $${amount.toFixed(2)}?`)
		) {
			return false;
		}

		return true;
	}

	handleSuccess(data) {
		this.close();
		this.showSuccessMessage(data.message);

		// Refresh the page to update balance
		if (data.redirect_url) {
			window.location.href = data.redirect_url;
		} else {
			window.location.reload();
		}
	}

	handleError(message) {
		this.showError(message);
	}

	showError(message) {
		alert(message); // For now, we'll use alert. Could be replaced with a toast system later
	}

	showSuccessMessage(message) {
		alert(message); // For now, we'll use alert. Could be replaced with a toast system later
	}

	clearModalState() {
		// Clear form
		if (this.hasFormTarget) {
			this.formTarget.reset();
		}

		// Clear quick amount selections
		this.clearQuickAmountSelections();
	}

	clearQuickAmountSelections() {
		const quickAmountBtns = this.element.querySelectorAll(".quick-amount-btn");
		quickAmountBtns.forEach((btn) => btn.classList.remove("selected"));
	}

	setupEscapeKeyHandler() {
		this.escapeKeyHandler = (event) => {
			if (event.key === "Escape" && this.element.classList.contains("active")) {
				this.close();
			}
		};
		document.addEventListener("keydown", this.escapeKeyHandler);
	}

	removeEscapeKeyHandler() {
		if (this.escapeKeyHandler) {
			document.removeEventListener("keydown", this.escapeKeyHandler);
		}
	}

	get submitButton() {
		return this.hasSubmitButtonTarget
			? this.submitButtonTarget
			: this.element.querySelector('input[type="submit"]');
	}
}
